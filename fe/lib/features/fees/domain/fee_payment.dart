import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/payment_method.dart';
import '../../../core/utils/india_date.dart';

part 'fee_payment.freezed.dart';
part 'fee_payment.g.dart';

/// How long after recording a payment `delete_fee_payment` still removes it.
const feePaymentDeleteWindow = Duration(days: 7);

/// One monthly fee payment, from `public.fee_payments`.
@freezed
abstract class FeePayment with _$FeePayment {
  const FeePayment._();

  const factory FeePayment({
    required String id,
    @JsonKey(name: 'trainee_id') required String traineeId,
    required int amount,
    @JsonKey(fromJson: PaymentMethod.fromWire, toJson: _methodToWire)
    required PaymentMethod method,
    @JsonKey(name: 'paid_on', fromJson: parseWireDate, toJson: wireDate)
    required DateTime paidOn,

    /// The first day of the month the payment is for.
    @JsonKey(name: 'period_month', fromJson: parseWireDate, toJson: wireDate)
    required DateTime periodMonth,
    String? note,
    @JsonKey(name: 'recorded_by') String? recordedBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _FeePayment;

  factory FeePayment.fromJson(Map<String, dynamic> json) =>
      _$FeePaymentFromJson(json);

  /// Whether the server still removes it at [now], India wall-clock time as `clockProvider`
  /// gives it; the last moment allowed is exactly [feePaymentDeleteWindow] after recording.
  bool canDeleteAt(DateTime now) =>
      !now.isAfter(toIndiaTime(createdAt).add(feePaymentDeleteWindow));
}

/// `Cash`, `UPI`, or `Other` for a method this build does not know.
String paymentMethodLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => 'Cash',
  PaymentMethod.upi => 'UPI',
  PaymentMethod.unknown => 'Other',
};

String _methodToWire(PaymentMethod method) => method.wire;
