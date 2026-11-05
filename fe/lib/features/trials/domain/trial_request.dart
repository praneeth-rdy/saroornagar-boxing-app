import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/session_slot.dart';

part 'trial_request.freezed.dart';

/// What a visitor fills in to book a trial, sent to `book_trial`; one of age or date of
/// birth is required.
@freezed
abstract class TrialRequest with _$TrialRequest {
  const factory TrialRequest({
    required String fullName,
    required String phone,
    required DateTime sessionDate,
    required SessionSlot slot,
    DateTime? dateOfBirth,
    int? age,
    String? note,
  }) = _TrialRequest;
}
