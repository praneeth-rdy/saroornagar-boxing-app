import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/core/utils/india_date.dart';
import 'package:saroornagar_boxing/features/today/domain/club_session.dart';

/// A Thursday; the design artboards show this day.
final fixtureDay = DateTime(2026, 11, 5);

/// The Sunday of the same week: no regular batches.
final fixtureSunday = DateTime(2026, 11, 8);

/// Regular batch ids are derived from the date so tests can seed marks before the mock
/// creates the day.
String regularSessionId(DateTime date, SessionSlot slot) =>
    'session-${wireDate(date)}-${slot.wire}';

/// 06:00 to 08:30, as `ensure_day_sessions` creates it.
ClubSession morningSession(DateTime date) => ClubSession(
  id: regularSessionId(date, SessionSlot.morning),
  sessionDate: dateOnly(date),
  slot: SessionSlot.morning,
  startsAt: '06:00:00',
  endsAt: '08:30:00',
);

/// 17:30 to 20:00, as `ensure_day_sessions` creates it.
ClubSession eveningSession(DateTime date) => ClubSession(
  id: regularSessionId(date, SessionSlot.evening),
  sessionDate: dateOnly(date),
  slot: SessionSlot.evening,
  startsAt: '17:30:00',
  endsAt: '20:00:00',
);

ClubSession extraSession(
  DateTime date, {
  String id = 'session-extra-fixture',
  String startsAt = '16:00:00',
  String endsAt = '17:00:00',
  String? createdBy = '00000000-0000-4000-8000-000000000001',
}) => ClubSession(
  id: id,
  sessionDate: dateOnly(date),
  slot: SessionSlot.extra,
  startsAt: startsAt,
  endsAt: endsAt,
  createdBy: createdBy,
);
