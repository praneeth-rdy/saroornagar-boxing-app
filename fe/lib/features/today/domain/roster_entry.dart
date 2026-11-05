import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/attendance_status.dart';

part 'roster_entry.freezed.dart';
part 'roster_entry.g.dart';

/// One active trainee in a session's roster, from `public.session_roster`.
@freezed
abstract class RosterEntry with _$RosterEntry {
  const factory RosterEntry({
    @JsonKey(name: 'trainee_id') required String traineeId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'photo_path') String? photoPath,

    /// Null while the trainee is not marked for the session.
    @JsonKey(fromJson: _statusFromWire, toJson: _statusToWire)
    AttendanceStatus? status,
    @JsonKey(name: 'marked_at') DateTime? markedAt,
  }) = _RosterEntry;

  factory RosterEntry.fromJson(Map<String, dynamic> json) =>
      _$RosterEntryFromJson(json);
}

AttendanceStatus? _statusFromWire(String? value) =>
    value == null ? null : AttendanceStatus.fromWire(value);

String? _statusToWire(AttendanceStatus? status) => status?.wire;
