// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roster_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RosterEntry _$RosterEntryFromJson(Map<String, dynamic> json) => _RosterEntry(
  traineeId: json['trainee_id'] as String,
  fullName: json['full_name'] as String,
  photoPath: json['photo_path'] as String?,
  status: _statusFromWire(json['status'] as String?),
  markedAt: json['marked_at'] == null
      ? null
      : DateTime.parse(json['marked_at'] as String),
);

Map<String, dynamic> _$RosterEntryToJson(_RosterEntry instance) =>
    <String, dynamic>{
      'trainee_id': instance.traineeId,
      'full_name': instance.fullName,
      'photo_path': instance.photoPath,
      'status': _statusToWire(instance.status),
      'marked_at': instance.markedAt?.toIso8601String(),
    };
