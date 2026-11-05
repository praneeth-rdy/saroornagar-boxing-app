import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/attendance_status.dart';
import '../../../core/models/session_slot.dart';
import '../../../core/utils/india_date.dart';

part 'attendance_record.freezed.dart';
part 'attendance_record.g.dart';

/// One of a trainee's marks, from `public.trainee_attendance_history`.
@freezed
abstract class AttendanceRecord with _$AttendanceRecord {
  const factory AttendanceRecord({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)
    required DateTime sessionDate,
    @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)
    required SessionSlot slot,
    @JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire)
    required AttendanceStatus status,
    @JsonKey(name: 'marked_at') required DateTime markedAt,

    /// `HH:mm:ss` India wall clock; null from a server older than the time columns.
    @JsonKey(name: 'starts_at') String? startsAt,
    @JsonKey(name: 'ends_at') String? endsAt,
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);
}

String _slotToWire(SessionSlot slot) => slot.wire;

String _statusToWire(AttendanceStatus status) => status.wire;
