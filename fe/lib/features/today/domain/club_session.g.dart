// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClubSession _$ClubSessionFromJson(Map<String, dynamic> json) => _ClubSession(
  id: json['id'] as String,
  sessionDate: parseWireDate(json['session_date'] as String),
  slot: SessionSlot.fromWire(json['slot'] as String?),
  startsAt: json['starts_at'] as String,
  endsAt: json['ends_at'] as String,
  createdBy: json['created_by'] as String?,
);

Map<String, dynamic> _$ClubSessionToJson(_ClubSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_date': wireDate(instance.sessionDate),
      'slot': _slotToWire(instance.slot),
      'starts_at': instance.startsAt,
      'ends_at': instance.endsAt,
      'created_by': instance.createdBy,
    };
