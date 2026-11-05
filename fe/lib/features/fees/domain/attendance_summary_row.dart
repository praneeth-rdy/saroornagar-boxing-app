import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_summary_row.freezed.dart';
part 'attendance_summary_row.g.dart';

/// One active trainee's marks for a month, from `public.monthly_attendance_summary`.
@freezed
abstract class AttendanceSummaryRow with _$AttendanceSummaryRow {
  const factory AttendanceSummaryRow({
    @JsonKey(name: 'trainee_id') required String traineeId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'photo_path') String? photoPath,
    @JsonKey(name: 'present_count') required int presentCount,
    @JsonKey(name: 'absent_count') required int absentCount,

    /// Sessions dated in the month; the same on every row.
    @JsonKey(name: 'session_count') required int sessionCount,
  }) = _AttendanceSummaryRow;

  factory AttendanceSummaryRow.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSummaryRowFromJson(json);
}
