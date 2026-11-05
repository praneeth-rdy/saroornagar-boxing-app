import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../auth/domain/staff_profile.dart';
import '../domain/staff_input.dart';

final staffListProvider = FutureProvider.autoDispose<List<StaffProfile>>(
  (ref) => ref.watch(staffRepositoryProvider).list(),
);

/// One staff member from the list; there is no single-row call to make.
final staffMemberProvider = FutureProvider.autoDispose
    .family<StaffProfile, String>((ref, userId) async {
      final staff = await ref.watch(staffListProvider.future);
      for (final member in staff) {
        if (member.id == userId) return member;
      }
      throw const NotFoundException('Staff member not found');
    });

final staffFormControllerProvider =
    NotifierProvider.autoDispose<StaffFormController, AsyncValue<void>>(
      StaffFormController.new,
    );

final staffBlockControllerProvider = NotifierProvider.autoDispose
    .family<StaffBlockController, AsyncValue<void>, String>(
      StaffBlockController.new,
    );

final resetPasswordControllerProvider = NotifierProvider.autoDispose
    .family<ResetPasswordController, AsyncValue<void>, String>(
      ResetPasswordController.new,
    );

/// Adds a staff member or saves an edit of their name and role.
class StaffFormController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns the saved profile, or null when it failed (the error is in state).
  Future<StaffProfile?> save(String? userId, StaffInput input) async {
    if (state.isLoading) return null;
    state = const AsyncLoading();
    try {
      final repository = ref.read(staffRepositoryProvider);
      final saved = userId == null
          ? await repository.create(
              fullName: input.fullName,
              phone: input.phone ?? '',
              password: input.password ?? '',
              role: input.role,
            )
          : await repository.update(
              userId,
              fullName: input.fullName,
              role: input.role,
            );
      if (!ref.mounted) return saved;
      state = const AsyncData(null);
      ref.invalidate(staffListProvider);
      return saved;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(_appError(error), stackTrace);
      return null;
    }
  }
}

/// Blocks or unblocks one staff member.
class StaffBlockController extends Notifier<AsyncValue<void>> {
  StaffBlockController(this.userId);

  final String userId;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> setBlocked(bool blocked) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    try {
      await ref.read(staffRepositoryProvider).setBlocked(userId, blocked);
      if (!ref.mounted) return;
      state = const AsyncData(null);
      ref.invalidate(staffListProvider);
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(_appError(error), stackTrace);
    }
  }
}

/// Sets a new password for one staff member.
class ResetPasswordController extends Notifier<AsyncValue<void>> {
  ResetPasswordController(this.userId);

  final String userId;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Whether the password was reset; a failure stays in state.
  Future<bool> reset(String password) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    try {
      await ref.read(staffRepositoryProvider).resetPassword(userId, password);
      if (ref.mounted) state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(_appError(error), stackTrace);
      return false;
    }
  }
}

AppException _appError(Object error) =>
    error is AppException ? error : const UnknownException();
