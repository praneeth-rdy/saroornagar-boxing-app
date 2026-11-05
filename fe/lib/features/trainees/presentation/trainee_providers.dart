import 'dart:typed_data';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/trainee_status.dart';
import '../../../core/utils/india_date.dart';
import '../../today/presentation/today_providers.dart';
import '../domain/attendance_record.dart';
import '../domain/trainee.dart';
import '../domain/trainee_input.dart';

/// How many days the detail screen's attendance section covers, today included.
const recentAttendanceDays = 30;

// The bucket caps a photo at 2 MiB; 1600 px at quality 80 stays well under it.
const _photoMaxSide = 1600.0;
const _photoQuality = 80;

/// A photo chosen on the device, ready to upload.
typedef PickedPhoto = ({Uint8List bytes, String fileName});

/// One trainee's attendance for the month starting at [month] (a first of the month).
typedef TraineeMonth = ({String traineeId, DateTime month});

/// Opens the camera or the gallery; tests override it to skip the platform picker.
final photoPickerProvider =
    Provider<Future<PickedPhoto?> Function(ImageSource source)>(
      (ref) => pickTraineePhoto,
    );

final traineeListProvider = FutureProvider.autoDispose
    .family<List<Trainee>, TraineeStatus>(
      (ref, status) =>
          ref.watch(traineeRepositoryProvider).list(status: status),
    );

final traineeProvider = FutureProvider.autoDispose.family<Trainee, String>(
  (ref, id) => ref.watch(traineeRepositoryProvider).byId(id),
);

final traineePhotoUrlProvider = FutureProvider.autoDispose
    .family<String?, String?>(
      (ref, photoPath) =>
          ref.watch(traineeRepositoryProvider).photoUrl(photoPath),
    );

/// The last [recentAttendanceDays] days of marks, newest first.
final recentAttendanceProvider = FutureProvider.autoDispose
    .family<List<AttendanceRecord>, String>((ref, traineeId) {
      final today = dateOnly(ref.watch(clockProvider)());
      final from = DateTime(
        today.year,
        today.month,
        today.day - (recentAttendanceDays - 1),
      );
      return ref
          .watch(traineeRepositoryProvider)
          .history(traineeId, from, today);
    });

final monthAttendanceProvider = FutureProvider.autoDispose
    .family<List<AttendanceRecord>, TraineeMonth>((ref, key) {
      final first = DateTime(key.month.year, key.month.month);
      final last = DateTime(key.month.year, key.month.month + 1, 0);
      return ref
          .watch(traineeRepositoryProvider)
          .history(key.traineeId, first, last);
    });

final traineeFormControllerProvider =
    NotifierProvider.autoDispose<TraineeFormController, AsyncValue<void>>(
      TraineeFormController.new,
    );

final traineeStatusControllerProvider = NotifierProvider.autoDispose
    .family<TraineeStatusController, AsyncValue<void>, String>(
      TraineeStatusController.new,
    );

final traineePhotoControllerProvider = NotifierProvider.autoDispose
    .family<TraineePhotoController, AsyncValue<void>, String>(
      TraineePhotoController.new,
    );

/// Trainees whose name contains [query] in any case, or whose phone contains its digits.
List<Trainee> filterTrainees(List<Trainee> trainees, String query) {
  final text = query.trim().toLowerCase();
  if (text.isEmpty) return trainees;
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  return [
    for (final trainee in trainees)
      if (trainee.fullName.toLowerCase().contains(text) ||
          (digits.isNotEmpty && (trainee.phone ?? '').contains(digits)))
        trainee,
  ];
}

/// The platform picker, resized and re-encoded before upload.
Future<PickedPhoto?> pickTraineePhoto(ImageSource source) async {
  final XFile? file;
  try {
    file = await ImagePicker().pickImage(
      source: source,
      maxWidth: _photoMaxSide,
      maxHeight: _photoMaxSide,
      imageQuality: _photoQuality,
    );
  } on PlatformException {
    throw const UnknownException(
      'Could not open the camera or gallery. Try again.',
    );
  }
  if (file == null) return null;
  return (bytes: await file.readAsBytes(), fileName: file.name);
}

/// Adds a trainee or saves an edit.
class TraineeFormController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns the saved trainee, or null when it failed (the error is in state).
  Future<Trainee?> save(String? traineeId, TraineeInput input) async {
    if (state.isLoading) return null;
    state = const AsyncLoading();
    try {
      final repository = ref.read(traineeRepositoryProvider);
      final saved = traineeId == null
          ? await repository.create(input)
          : await repository.update(traineeId, input);
      if (!ref.mounted) return saved;
      state = const AsyncData(null);
      _refreshTrainee(ref, saved.id);
      return saved;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(_appError(error), stackTrace);
      return null;
    }
  }
}

/// Sets one trainee active or inactive.
class TraineeStatusController extends Notifier<AsyncValue<void>> {
  TraineeStatusController(this.traineeId);

  final String traineeId;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> setStatus(TraineeStatus status) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    try {
      await ref.read(traineeRepositoryProvider).setStatus(traineeId, status);
      if (!ref.mounted) return;
      state = const AsyncData(null);
      _refreshTrainee(ref, traineeId);
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(_appError(error), stackTrace);
    }
  }
}

/// Takes, chooses or removes one trainee's photo; loading means an upload is running.
class TraineePhotoController extends Notifier<AsyncValue<void>> {
  TraineePhotoController(this.traineeId);

  final String traineeId;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> pick(ImageSource source) async {
    if (state.isLoading) return;
    final PickedPhoto? photo;
    try {
      photo = await ref.read(photoPickerProvider)(source);
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(_appError(error), stackTrace);
      return;
    }
    if (photo == null || !ref.mounted) return;
    final (:bytes, :fileName) = photo;
    await _run(
      () => ref
          .read(traineeRepositoryProvider)
          .uploadPhoto(traineeId, bytes, fileName),
    );
  }

  Future<void> remove() =>
      _run(() => ref.read(traineeRepositoryProvider).removePhoto(traineeId));

  Future<void> _run(Future<Trainee> Function() action) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    try {
      await action();
      if (!ref.mounted) return;
      state = const AsyncData(null);
      _refreshTrainee(ref, traineeId);
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(_appError(error), stackTrace);
    }
  }
}

// The Today tab stays mounted beside this one, so its roster is refreshed as well.
void _refreshTrainee(Ref ref, String traineeId) {
  ref.invalidate(traineeProvider(traineeId));
  ref.invalidate(traineeListProvider);
  ref.invalidate(rosterProvider);
}

AppException _appError(Object error) =>
    error is AppException ? error : const UnknownException();
