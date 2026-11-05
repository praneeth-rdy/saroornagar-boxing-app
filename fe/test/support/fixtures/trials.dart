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

const _visitorNames = [
  'Rahul Verma',
  'Priya Nair',
  'Faisal Ahmed',
  'Sneha Reddy',
  'Arjun Rao',
  'Kavya Iyer',
  'Mohammed Irfan',
  'Ananya Das',
  'Vikram Singh',
  'Lavanya Goud',
  'Sai Teja',
  'Divya Menon',
  'Imran Khan',
  'Pooja Shetty',
  'Karan Mehta',
  'Swathi Naidu',
  'Ravi Kumar',
  'Nisha Patel',
  'Aditya Joshi',
  'Meghana Rao',
  'Tarun Varma',
  'Fatima Begum',
  'Manoj Yadav',
  'Shruti Kulkarni',
];

// Bookings per club day cycle through 3, 1, 2 so the list shows uneven days.
const _bookingsPerDay = [3, 1, 2];

/// Bookings on [days] club days from [from] on, skipping Sundays: 1 to 3 per day, every
/// visitor a different person.
List<TrialBooking> fixtureTrialDays(DateTime from, {int days = 10}) {
  final bookings = <TrialBooking>[];
  var clubDays = 0;
  for (var offset = 0; clubDays < days; offset++) {
    final date = DateTime(from.year, from.month, from.day + offset);
    if (date.weekday == DateTime.sunday) continue;
    final count = _bookingsPerDay[clubDays % _bookingsPerDay.length];
    for (var i = 0; i < count; i++) {
      final index = bookings.length;
      bookings.add(
        TrialBooking(
          id: 'trial-day-${index + 1}',
          fullName: _visitorNames[index % _visitorNames.length],
          phone: '91970000${(index + 10000).toString().substring(1)}',
          age: 10 + index % 15,
          sessionDate: date,
          slot: i.isEven ? SessionSlot.morning : SessionSlot.evening,
          note: index % 4 == 0 ? 'First time in a boxing gym' : null,
          createdAt: DateTime.utc(2026, 11, 3, 8 + i),
        ),
      );
    }
    clubDays++;
  }
  return bookings;
}
