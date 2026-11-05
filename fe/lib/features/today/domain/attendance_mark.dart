import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/attendance_status.dart';

part 'attendance_mark.freezed.dart';
part 'attendance_mark.g.dart';

/// A stored `public.attendance` row, as `mark_attendance` returns it.
@freezed
abstract class AttendanceMark with _$AttendanceMark {
  const factory AttendanceMark({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'trainee_id') required String traineeId,
    @JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire)
    required AttendanceStatus status,
    @JsonKey(name: 'marked_by') String? markedBy,
    @JsonKey(name: 'marked_at') required DateTime markedAt,
  }) = _AttendanceMark;

  factory AttendanceMark.fromJson(Map<String, dynamic> json) =>
      _$AttendanceMarkFromJson(json);
}

String _statusToWire(AttendanceStatus status) => status.wire;
