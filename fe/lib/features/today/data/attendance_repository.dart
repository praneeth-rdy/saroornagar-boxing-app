import 'package:flutter/material.dart' show TimeOfDay;

import '../../../core/models/attendance_status.dart';
import '../../trials/domain/trial_booking.dart';
import '../domain/attendance_mark.dart';
import '../domain/club_session.dart';
import '../domain/roster_entry.dart';

/// Sessions of a day and their attendance; failures surface as `AppException`s.
abstract class AttendanceRepository {
  /// Every session of [date], creating the regular batches on a non-Sunday.
  Future<List<ClubSession>> sessionsFor(DateTime date);

  Future<ClubSession> addExtraSession(
    DateTime date,
    TimeOfDay start,
    TimeOfDay end,
  );

  Future<void> deleteExtraSession(String sessionId);

  /// Every active trainee with their mark for the session, by name.
  Future<List<RosterEntry>> roster(String sessionId);

  /// Inserts or corrects one mark; the same status leaves the stored mark as it was.
  Future<AttendanceMark> mark(
    String sessionId,
    String traineeId,
    AttendanceStatus status,
  );

  /// Removes one trainee's mark; `NotFoundException` when there is none.
  Future<void> unmark(String sessionId, String traineeId);

  /// Removes every mark of the session and returns how many were removed.
  Future<int> resetSession(String sessionId);

  /// Trial bookings dated [from] to [to], both inclusive.
  Future<List<TrialBooking>> trialsBetween(DateTime from, DateTime to);
}
