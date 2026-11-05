// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_summary_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceSummaryRow _$AttendanceSummaryRowFromJson(
  Map<String, dynamic> json,
) => _AttendanceSummaryRow(
  traineeId: json['trainee_id'] as String,
  fullName: json['full_name'] as String,
  photoPath: json['photo_path'] as String?,
  presentCount: (json['present_count'] as num).toInt(),
  absentCount: (json['absent_count'] as num).toInt(),
  sessionCount: (json['session_count'] as num).toInt(),
);

Map<String, dynamic> _$AttendanceSummaryRowToJson(
  _AttendanceSummaryRow instance,
) => <String, dynamic>{
  'trainee_id': instance.traineeId,
  'full_name': instance.fullName,
  'photo_path': instance.photoPath,
  'present_count': instance.presentCount,
  'absent_count': instance.absentCount,
  'session_count': instance.sessionCount,
};
