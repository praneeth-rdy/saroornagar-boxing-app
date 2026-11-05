// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    _AttendanceRecord(
      sessionId: json['session_id'] as String,
      sessionDate: parseWireDate(json['session_date'] as String),
      slot: SessionSlot.fromWire(json['slot'] as String?),
      status: AttendanceStatus.fromWire(json['status'] as String?),
      markedAt: DateTime.parse(json['marked_at'] as String),
    );

Map<String, dynamic> _$AttendanceRecordToJson(_AttendanceRecord instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'session_date': wireDate(instance.sessionDate),
      'slot': _slotToWire(instance.slot),
      'status': _statusToWire(instance.status),
      'marked_at': instance.markedAt.toIso8601String(),
    };
