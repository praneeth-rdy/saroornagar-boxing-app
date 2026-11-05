import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/attendance_status.dart';
import '../../../core/models/session_slot.dart';
import '../../../core/utils/india_date.dart';
import 'attendance_record.dart';

part 'attendance_day.freezed.dart';

/// One date a student attended, with the batches they were present in.
@freezed
abstract class AttendanceDay with _$AttendanceDay {
  const AttendanceDay._();

  const factory AttendanceDay({
    required DateTime date,

    /// Present batches in day order: morning, evening, then extras.
    required List<SessionSlot> slots,
  }) = _AttendanceDay;

  /// `Morning and evening`, `Morning`, `Morning and extra`, `Morning, evening and 2 extras`.
  String get label {
    final extras = slots.where((slot) => slot == SessionSlot.extra).length;
    final parts = [
      for (final slot in slots)
        if (slot != SessionSlot.extra) slot.label.toLowerCase(),
      if (extras == 1) 'extra',
      if (extras > 1) '$extras extras',
    ];
    if (parts.isEmpty) return '';
    final text = parts.length == 1
        ? parts.single
        : '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}

/// Present marks grouped by date, newest date first; dates with no present mark are left out.
List<AttendanceDay> groupAttendanceByDate(List<AttendanceRecord> records) {
  final byDate = <DateTime, List<SessionSlot>>{};
  for (final record in records) {
    if (record.status != AttendanceStatus.present) continue;
    byDate.putIfAbsent(dateOnly(record.sessionDate), () => []).add(record.slot);
  }
  final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final date in dates)
      AttendanceDay(
        date: date,
        slots: byDate[date]!..sort((a, b) => a.index.compareTo(b.index)),
      ),
  ];
}
