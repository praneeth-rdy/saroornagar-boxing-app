import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/session_slot.dart';
import '../../../core/utils/india_date.dart';

part 'trial_booking.freezed.dart';
part 'trial_booking.g.dart';

/// A visitor's trial booking from `public.trial_bookings`; the device key is never read.
@freezed
abstract class TrialBooking with _$TrialBooking {
  const factory TrialBooking({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String phone,
    @JsonKey(
      name: 'date_of_birth',
      fromJson: _optionalDateFromWire,
      toJson: _optionalDateToWire,
    )
    DateTime? dateOfBirth,
    int? age,
    @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)
    required DateTime sessionDate,
    @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)
    required SessionSlot slot,
    String? note,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TrialBooking;

  factory TrialBooking.fromJson(Map<String, dynamic> json) =>
      _$TrialBookingFromJson(json);
}

DateTime? _optionalDateFromWire(String? value) =>
    value == null ? null : parseWireDate(value);

String? _optionalDateToWire(DateTime? date) =>
    date == null ? null : wireDate(date);

String _slotToWire(SessionSlot slot) => slot.wire;
