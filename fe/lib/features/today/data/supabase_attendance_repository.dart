import 'package:flutter/material.dart' show TimeOfDay;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/attendance_status.dart';
import '../../../core/supabase/supabase_errors.dart';
import '../../../core/utils/india_date.dart';
import '../../trials/domain/trial_booking.dart';
import '../domain/attendance_mark.dart';
import '../domain/club_session.dart';
import '../domain/roster_entry.dart';
import 'attendance_repository.dart';

class SupabaseAttendanceRepository implements AttendanceRepository {
  SupabaseAttendanceRepository(this.client);

  final SupabaseClient client;

  @override
  Future<List<ClubSession>> sessionsFor(DateTime date) => guardSupabase(
    () async => _rows(
      await client.rpc<dynamic>(
        'ensure_day_sessions',
        params: {'p_date': wireDate(date)},
      ),
    ).map(ClubSession.fromJson).toList(),
  );

  @override
  Future<ClubSession> addExtraSession(
    DateTime date,
    TimeOfDay start,
    TimeOfDay end,
  ) => guardSupabase(
    () async => ClubSession.fromJson(
      _row(
        await client.rpc<dynamic>(
          'add_extra_session',
          params: {
            'p_date': wireDate(date),
            'p_starts_at': _wireTime(start),
            'p_ends_at': _wireTime(end),
          },
        ),
      ),
    ),
  );

  @override
  Future<void> deleteExtraSession(String sessionId) => guardSupabase(
    () => client.rpc<dynamic>(
      'delete_extra_session',
      params: {'p_session_id': sessionId},
    ),
  );

  @override
  Future<List<RosterEntry>> roster(String sessionId) => guardSupabase(
    () async => _rows(
      await client.rpc<dynamic>(
        'session_roster',
        params: {'p_session_id': sessionId},
      ),
    ).map(RosterEntry.fromJson).toList(),
  );

  @override
  Future<AttendanceMark> mark(
    String sessionId,
    String traineeId,
    AttendanceStatus status,
  ) async {
    // The enum cast would fail as an unmapped error; the server's message is the same.
    if (status == AttendanceStatus.unknown) {
      throw const ValidationException('Choose present or absent');
    }
    return guardSupabase(
      () async => AttendanceMark.fromJson(
        _row(
          await client.rpc<dynamic>(
            'mark_attendance',
            params: {
              'p_session_id': sessionId,
              'p_trainee_id': traineeId,
              'p_status': status.wire,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<void> unmark(String sessionId, String traineeId) => guardSupabase(
    () => client.rpc<dynamic>(
      'unmark_attendance',
      params: {'p_session_id': sessionId, 'p_trainee_id': traineeId},
    ),
  );

  @override
  Future<int> resetSession(String sessionId) => guardSupabase(
    () async => (await client.rpc<dynamic>(
      'reset_session_attendance',
      params: {'p_session_id': sessionId},
    ) as num).toInt(),
  );

  @override
  Future<List<TrialBooking>> trialsBetween(DateTime from, DateTime to) =>
      guardSupabase(
        () async => _rows(
          await client.rpc<dynamic>(
            'trial_bookings_between',
            params: {'p_from': wireDate(from), 'p_to': wireDate(to)},
          ),
        ).map(TrialBooking.fromJson).toList(),
      );
}

// A set-returning function comes back as a JSON array of row objects.
List<Map<String, dynamic>> _rows(dynamic result) => [
  for (final row in result as List) Map<String, dynamic>.from(row as Map),
];

// A function returning one composite row comes back as a single JSON object.
Map<String, dynamic> _row(dynamic result) =>
    Map<String, dynamic>.from(result as Map);

String _wireTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}:00';
