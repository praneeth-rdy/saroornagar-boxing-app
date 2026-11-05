import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/core/utils/india_date.dart';
import 'package:saroornagar_boxing/core/utils/phone_format.dart';
import 'package:saroornagar_boxing/features/trials/data/trial_repository.dart';
import 'package:saroornagar_boxing/features/trials/domain/trial_booking.dart';
import 'package:saroornagar_boxing/features/trials/domain/trial_request.dart';

import '../scenario.dart';
import 'mock_device_key_store.dart';

/// The device key of the seeded [MockTrialRepository.bookings], booked from another phone.
const otherDeviceKey = 'OTHERDEVICEKEY456789ABCDEFGHJKLM';

/// In-memory [TrialRepository] that follows `book_trial`, `my_trial_bookings` and
/// `trial_bookings_between` (`20261105080014_attendance_trials`): same order of checks,
/// same messages.
class MockTrialRepository implements TrialRepository {
  MockTrialRepository({
    this.scenario = MockScenario.success,
    List<TrialBooking> bookings = const [],
    List<TrialBooking> myBookings = const [],
    DateTime Function()? clock,
  }) : clock = clock ?? indiaNow {
    for (final booking in bookings) {
      _stored.add((booking: booking, deviceKey: otherDeviceKey));
    }
    for (final booking in myBookings) {
      _stored.add((booking: booking, deviceKey: mockDeviceKey));
    }
  }

  MockScenario scenario;

  /// India wall-clock time, as `clockProvider`; decides what "today" is.
  final DateTime Function() clock;

  final _stored = <({TrialBooking booking, String deviceKey})>[];
  var _created = 0;

  /// Every stored booking, for assertions.
  List<TrialBooking> get stored => [for (final row in _stored) row.booking];

  @override
  Future<TrialBooking> book(TrialRequest request, String deviceKey) =>
      applyScenario(scenario, success: () => _book(request, deviceKey));

  @override
  Future<List<TrialBooking>> mine(String deviceKey) => applyScenario(
    scenario,
    success: () {
      final today = dateOnly(clock());
      return _sorted([
        for (final row in _stored)
          if (row.deviceKey == deviceKey &&
              !dateOnly(row.booking.sessionDate).isBefore(today))
            row.booking,
      ]);
    },
    empty: () => const [],
  );

  @override
  Future<List<TrialBooking>> between(DateTime from, DateTime to) =>
      applyScenario(
        scenario,
        success: () {
          final first = dateOnly(from);
          final last = dateOnly(to);
          if (last.isBefore(first)) {
            throw const ValidationException(
              'The end date is before the start date',
            );
          }
          return _sorted([
            for (final row in _stored)
              if (!dateOnly(row.booking.sessionDate).isBefore(first) &&
                  !dateOnly(row.booking.sessionDate).isAfter(last))
                row.booking,
          ]);
        },
        empty: () => const [],
      );

  TrialBooking _book(TrialRequest request, String deviceKey) {
    final today = dateOnly(clock());
    final fullName = request.fullName.trim();
    final nameLength = fullName.runes.length;
    if (nameLength < 2 || nameLength > 80) {
      throw const ValidationException('Enter your name');
    }
    final phone = normalizePhone(request.phone);
    if (phone == null) {
      throw const ValidationException('Enter a 10-digit mobile number');
    }
    final slot = request.slot;
    if (slot != SessionSlot.morning && slot != SessionSlot.evening) {
      throw const ValidationException('Pick the morning or the evening batch');
    }
    final sessionDate = dateOnly(request.sessionDate);
    if (sessionDate.isBefore(today)) {
      throw const ValidationException('Pick today or a later day');
    }
    if (sessionDate.isAfter(
      DateTime(today.year, today.month, today.day + 30),
    )) {
      throw const ValidationException(
        'Trials can be booked up to 30 days ahead',
      );
    }
    if (sessionDate.weekday == DateTime.sunday) {
      throw const ValidationException('The club is closed on Sundays');
    }
    _checkAge(request, today);
    final trimmedNote = request.note?.trim();
    final note = trimmedNote == null || trimmedNote.isEmpty
        ? null
        : trimmedNote;
    if (note != null && note.runes.length > 300) {
      throw const ValidationException(
        'Keep the note to 300 characters or fewer',
      );
    }
    if (deviceKey.length < 16 || deviceKey.length > 128) {
      throw const ValidationException('Invalid device key');
    }
    final isTaken = _stored.any(
      (row) =>
          row.booking.phone == phone &&
          dateOnly(row.booking.sessionDate) == sessionDate &&
          row.booking.slot == slot,
    );
    if (isTaken) {
      throw const DuplicateException(
        'This number already has a trial booked for that batch',
      );
    }
    _created++;
    final booking = TrialBooking(
      id: 'trial-mock-$_created',
      fullName: fullName,
      phone: phone,
      dateOfBirth: request.dateOfBirth,
      age: request.age,
      sessionDate: sessionDate,
      slot: slot,
      note: note,
      createdAt: DateTime.now().toUtc(),
    );
    _stored.add((booking: booking, deviceKey: deviceKey));
    return booking;
  }

  void _checkAge(TrialRequest request, DateTime today) {
    final dateOfBirth = request.dateOfBirth;
    final age = request.age;
    if (dateOfBirth == null && age == null) {
      throw const ValidationException('Tell us your age or date of birth');
    }
    if (dateOfBirth != null) {
      if (dateOnly(dateOfBirth).isAfter(today)) {
        throw const ValidationException(
          'Date of birth cannot be in the future',
        );
      }
      if (!dateOnly(dateOfBirth).isAfter(DateTime(1900))) {
        throw const ValidationException('Enter a valid date of birth');
      }
    }
    if (age != null && (age < 3 || age > 99)) {
      throw const ValidationException('Enter an age between 3 and 99');
    }
  }
}

// The server's order: date, then batch (morning before evening), then booking time.
List<TrialBooking> _sorted(List<TrialBooking> bookings) =>
    bookings..sort((a, b) {
      final byDate = a.sessionDate.compareTo(b.sessionDate);
      if (byDate != 0) return byDate;
      final bySlot = a.slot.index.compareTo(b.slot.index);
      if (bySlot != 0) return bySlot;
      return a.createdAt.compareTo(b.createdAt);
    });
