// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Trainee _$TraineeFromJson(Map<String, dynamic> json) => _Trainee(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String?,
  photoPath: json['photo_path'] as String?,
  dateOfBirth: _optionalDateFromWire(json['date_of_birth'] as String?),
  joinedOn: _optionalDateFromWire(json['joined_on'] as String?),
  status: TraineeStatus.fromWire(json['status'] as String?),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TraineeToJson(_Trainee instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'phone': instance.phone,
  'photo_path': instance.photoPath,
  'date_of_birth': _optionalDateToWire(instance.dateOfBirth),
  'joined_on': _optionalDateToWire(instance.joinedOn),
  'status': _statusToWire(instance.status),
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
