// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeePayment _$FeePaymentFromJson(Map<String, dynamic> json) => _FeePayment(
  id: json['id'] as String,
  traineeId: json['trainee_id'] as String,
  amount: (json['amount'] as num).toInt(),
  method: PaymentMethod.fromWire(json['method'] as String?),
  paidOn: parseWireDate(json['paid_on'] as String),
  periodMonth: parseWireDate(json['period_month'] as String),
  note: json['note'] as String?,
  recordedBy: json['recorded_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$FeePaymentToJson(_FeePayment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trainee_id': instance.traineeId,
      'amount': instance.amount,
      'method': _methodToWire(instance.method),
      'paid_on': wireDate(instance.paidOn),
      'period_month': wireDate(instance.periodMonth),
      'note': instance.note,
      'recorded_by': instance.recordedBy,
      'created_at': instance.createdAt.toIso8601String(),
    };
