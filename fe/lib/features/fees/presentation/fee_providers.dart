import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/payment_method.dart';
import '../domain/attendance_summary_row.dart';
import '../domain/fee_payment.dart';
import '../domain/fee_status.dart';

/// The first day of [date]'s month, the shape every month parameter takes.
DateTime monthOf(DateTime date) => DateTime(date.year, date.month);

final feeHistoryProvider = FutureProvider.autoDispose
    .family<List<FeePayment>, String>(
      (ref, traineeId) => ref.watch(feeRepositoryProvider).history(traineeId),
    );

final feeStatusProvider = FutureProvider.autoDispose
    .family<List<FeeStatus>, DateTime>(
      (ref, month) => ref.watch(feeRepositoryProvider).statusFor(month),
    );

final attendanceSummaryProvider = FutureProvider.autoDispose
    .family<List<AttendanceSummaryRow>, DateTime>(
      (ref, month) => ref.watch(feeRepositoryProvider).attendanceSummary(month),
    );

final recordPaymentControllerProvider =
    NotifierProvider.autoDispose<RecordPaymentController, AsyncValue<void>>(
      RecordPaymentController.new,
    );

final deletePaymentControllerProvider = NotifierProvider.autoDispose
    .family<DeletePaymentController, AsyncValue<void>, String>(
      DeletePaymentController.new,
    );

/// Records one payment.
class RecordPaymentController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns the stored payment, or null when it failed (the error is in state).
  Future<FeePayment?> record({
    required String traineeId,
    required int amount,
    required PaymentMethod method,
    required DateTime paidOn,
    required DateTime periodMonth,
    String? note,
  }) async {
    if (state.isLoading) return null;
    state = const AsyncLoading();
    try {
      final payment = await ref
          .read(feeRepositoryProvider)
          .record(
            traineeId: traineeId,
            amount: amount,
            method: method,
            paidOn: paidOn,
            periodMonth: periodMonth,
            note: note,
          );
      if (!ref.mounted) return payment;
      state = const AsyncData(null);
      _refreshFees(ref, traineeId);
      return payment;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(_appError(error), stackTrace);
      return null;
    }
  }
}

/// Removes payments from one trainee's history.
class DeletePaymentController extends Notifier<AsyncValue<void>> {
  DeletePaymentController(this.traineeId);

  final String traineeId;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> delete(String paymentId) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    try {
      await ref.read(feeRepositoryProvider).delete(paymentId);
      if (!ref.mounted) return;
      state = const AsyncData(null);
      _refreshFees(ref, traineeId);
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(_appError(error), stackTrace);
    }
  }
}

void _refreshFees(Ref ref, String traineeId) {
  ref.invalidate(feeHistoryProvider(traineeId));
  ref.invalidate(feeStatusProvider);
}

AppException _appError(Object error) =>
    error is AppException ? error : const UnknownException();
