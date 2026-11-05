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

    /// `HH:mm:ss` starts of the present extras that carry one, earliest first.
    @Default(<String>[]) List<String> extraStarts,
  }) = _AttendanceDay;

  /// `Morning and evening`, `Morning and extra 4:00 pm`, `Morning, evening and 2 extras`.
  String get label {
    final extras = slots.where((slot) => slot == SessionSlot.extra).length;
    // Extras without a start time (an older server) are counted, not named.
    final untimed = extras - extraStarts.length;
    final parts = [
      for (final slot in slots)
        if (slot != SessionSlot.extra) slot.label.toLowerCase(),
      for (final start in extraStarts) 'extra ${formatWireTime(start)}',
      if (untimed == 1) 'extra',
      if (untimed > 1) '$untimed extras',
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
  final byDate = <DateTime, List<AttendanceRecord>>{};
  for (final record in records) {
    if (record.status != AttendanceStatus.present) continue;
    byDate.putIfAbsent(dateOnly(record.sessionDate), () => []).add(record);
  }
  final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
  return [for (final date in dates) _dayOf(date, byDate[date]!)];
}

AttendanceDay _dayOf(DateTime date, List<AttendanceRecord> present) {
  final slots = [for (final record in present) record.slot]
    ..sort((a, b) => a.index.compareTo(b.index));
  // `HH:mm:ss` text sorts in clock order.
  final extraStarts = [
    for (final record in present)
      if (record.slot == SessionSlot.extra && record.startsAt != null)
        record.startsAt!,
  ]..sort();
  return AttendanceDay(date: date, slots: slots, extraStarts: extraStarts);
}
