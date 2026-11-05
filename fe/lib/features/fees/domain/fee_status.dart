import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/india_date.dart';

part 'fee_status.freezed.dart';
part 'fee_status.g.dart';

/// One active trainee's fee position for a month, from `public.fee_status_list`.
@freezed
abstract class FeeStatus with _$FeeStatus {
  const FeeStatus._();

  const factory FeeStatus({
    @JsonKey(name: 'trainee_id') required String traineeId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'photo_path') String? photoPath,

    /// The monthly fee on the month's first day; null without a date of birth.
    @JsonKey(name: 'tier_amount') int? tierAmount,

    /// The sum of the month's payments, 0 when none.
    @JsonKey(name: 'paid_amount') required int paidAmount,
    @JsonKey(
      name: 'last_paid_on',
      fromJson: _optionalDateFromWire,
      toJson: _optionalDateToWire,
    )
    DateTime? lastPaidOn,
  }) = _FeeStatus;

  factory FeeStatus.fromJson(Map<String, dynamic> json) =>
      _$FeeStatusFromJson(json);

  /// Any payment counts, as in the server's unpaid-first order.
  bool get isPaid => paidAmount > 0;

  /// What is left of the tier, never below 0; null when the tier is unknown.
  int? get outstanding {
    final tier = tierAmount;
    if (tier == null) return null;
    final left = tier - paidAmount;
    return left > 0 ? left : 0;
  }
}

DateTime? _optionalDateFromWire(String? value) =>
    value == null ? null : parseWireDate(value);

String? _optionalDateToWire(DateTime? date) =>
    date == null ? null : wireDate(date);
