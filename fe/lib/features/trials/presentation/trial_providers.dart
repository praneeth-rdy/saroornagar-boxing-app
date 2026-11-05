import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/india_date.dart';
import '../../today/presentation/today_providers.dart';
import '../domain/trial_booking.dart';
import '../domain/trial_request.dart';

/// How many days ahead the staff list reaches; the server books up to the same limit.
const trialWindowDays = 30;

/// How many bookable days the form offers.
const trialDayChoices = 7;

/// This device's upcoming bookings, so a returning visitor sees what they booked.
final myTrialBookingsProvider = FutureProvider.autoDispose<List<TrialBooking>>((
  ref,
) async {
  final deviceKey = await ref.watch(deviceKeyStoreProvider).key();
  return ref.watch(trialRepositoryProvider).mine(deviceKey);
});

/// Every booking from today to [trialWindowDays] ahead, for the staff tab.
final upcomingTrialsProvider = FutureProvider.autoDispose<List<TrialBooking>>((
  ref,
) {
  final today = dateOnly(ref.watch(clockProvider)());
  final last = DateTime(today.year, today.month, today.day + trialWindowDays);
  return ref.watch(trialRepositoryProvider).between(today, last);
});

final bookTrialControllerProvider =
    NotifierProvider.autoDispose<BookTrialController, AsyncValue<void>>(
      BookTrialController.new,
    );

/// The next [trialDayChoices] days from [today] on, skipping Sundays (the club is closed).
List<DateTime> trialDaysFrom(DateTime today) {
  final days = <DateTime>[];
  for (var offset = 0; days.length < trialDayChoices; offset++) {
    final day = DateTime(today.year, today.month, today.day + offset);
    if (day.weekday != DateTime.sunday) days.add(day);
  }
  return days;
}

/// [bookings] by session date, in date order; each day keeps the server's order.
Map<DateTime, List<TrialBooking>> trialsByDay(List<TrialBooking> bookings) {
  final days = <DateTime, List<TrialBooking>>{};
  for (final booking in bookings) {
    days.putIfAbsent(dateOnly(booking.sessionDate), () => []).add(booking);
  }
  final dates = days.keys.toList()..sort();
  return {for (final date in dates) date: days[date]!};
}

/// Books a trial for this device's visitor.
class BookTrialController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns the booking, or null when it failed (the error is in state).
  Future<TrialBooking?> book(TrialRequest request) async {
    if (state.isLoading) return null;
    state = const AsyncLoading();
    try {
      final deviceKey = await ref.read(deviceKeyStoreProvider).key();
      final booking = await ref
          .read(trialRepositoryProvider)
          .book(request, deviceKey);
      if (!ref.mounted) return booking;
      state = const AsyncData(null);
      // Staff can book while signed in, so their trial lists refresh as well.
      ref.invalidate(myTrialBookingsProvider);
      ref.invalidate(upcomingTrialsProvider);
      ref.invalidate(dayTrialsProvider);
      return booking;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(_appError(error), stackTrace);
      return null;
    }
  }
}

AppException _appError(Object error) =>
    error is AppException ? error : const UnknownException();
