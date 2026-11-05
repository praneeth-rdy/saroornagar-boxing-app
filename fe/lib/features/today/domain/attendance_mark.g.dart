// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_mark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceMark _$AttendanceMarkFromJson(Map<String, dynamic> json) =>
    _AttendanceMark(
      sessionId: json['session_id'] as String,
      traineeId: json['trainee_id'] as String,
      status: AttendanceStatus.fromWire(json['status'] as String?),
      markedBy: json['marked_by'] as String?,
      markedAt: DateTime.parse(json['marked_at'] as String),
    );

Map<String, dynamic> _$AttendanceMarkToJson(_AttendanceMark instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'trainee_id': instance.traineeId,
      'status': _statusToWire(instance.status),
      'marked_by': instance.markedBy,
      'marked_at': instance.markedAt.toIso8601String(),
    };
