// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trial_booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrialBooking _$TrialBookingFromJson(Map<String, dynamic> json) =>
    _TrialBooking(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      dateOfBirth: _optionalDateFromWire(json['date_of_birth'] as String?),
      age: (json['age'] as num?)?.toInt(),
      sessionDate: parseWireDate(json['session_date'] as String),
      slot: SessionSlot.fromWire(json['slot'] as String?),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TrialBookingToJson(_TrialBooking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'date_of_birth': _optionalDateToWire(instance.dateOfBirth),
      'age': instance.age,
      'session_date': wireDate(instance.sessionDate),
      'slot': _slotToWire(instance.slot),
      'note': instance.note,
      'created_at': instance.createdAt.toIso8601String(),
    };
