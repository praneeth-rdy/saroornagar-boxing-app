// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeeStatus _$FeeStatusFromJson(Map<String, dynamic> json) => _FeeStatus(
  traineeId: json['trainee_id'] as String,
  fullName: json['full_name'] as String,
  photoPath: json['photo_path'] as String?,
  tierAmount: (json['tier_amount'] as num?)?.toInt(),
  paidAmount: (json['paid_amount'] as num).toInt(),
  lastPaidOn: _optionalDateFromWire(json['last_paid_on'] as String?),
);

Map<String, dynamic> _$FeeStatusToJson(_FeeStatus instance) =>
    <String, dynamic>{
      'trainee_id': instance.traineeId,
      'full_name': instance.fullName,
      'photo_path': instance.photoPath,
      'tier_amount': instance.tierAmount,
      'paid_amount': instance.paidAmount,
      'last_paid_on': _optionalDateToWire(instance.lastPaidOn),
    };
