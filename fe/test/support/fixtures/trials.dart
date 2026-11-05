import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/features/trials/domain/trial_booking.dart';

/// Two morning visitors (one with an age and a note, one with a date of birth) and one
/// evening visitor on [date].
List<TrialBooking> fixtureTrials(DateTime date) => [
  TrialBooking(
    id: 'trial-001',
    fullName: 'Rahul Verma',
    phone: '919876543210',
    age: 14,
    sessionDate: date,
    slot: SessionSlot.morning,
    note: 'Has done some kickboxing before',
    createdAt: DateTime.utc(2026, 11, 3, 10),
  ),
  TrialBooking(
    id: 'trial-002',
    fullName: 'Priya Nair',
    phone: '919812345678',
    dateOfBirth: DateTime(2012, 3, 5),
    sessionDate: date,
    slot: SessionSlot.morning,
    createdAt: DateTime.utc(2026, 11, 4, 9),
  ),
  TrialBooking(
    id: 'trial-003',
    fullName: 'Faisal Ahmed',
    phone: '919700000003',
    age: 22,
    sessionDate: date,
    slot: SessionSlot.evening,
    createdAt: DateTime.utc(2026, 11, 4, 12),
  ),
];
