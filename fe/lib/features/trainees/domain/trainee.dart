import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/trainee_status.dart';
import '../../../core/utils/india_date.dart';

part 'trainee.freezed.dart';
part 'trainee.g.dart';

// Same tier rule as `private.fee_tier_amount`: under 15 on the day pays the junior fee.
const _seniorAge = 15;
const _juniorFee = 500;
const _seniorFee = 1000;

/// A trainee on the club's roster, from `public.trainees`.
@freezed
abstract class Trainee with _$Trainee {
  const Trainee._();

  const factory Trainee({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,

    /// Stored as `91XXXXXXXXXX`.
    String? phone,

    /// Object name in the `trainee-photos` bucket, not a URL.
    @JsonKey(name: 'photo_path') String? photoPath,
    @JsonKey(
      name: 'date_of_birth',
      fromJson: _optionalDateFromWire,
      toJson: _optionalDateToWire,
    )
    DateTime? dateOfBirth,
    @JsonKey(
      name: 'joined_on',
      fromJson: _optionalDateFromWire,
      toJson: _optionalDateToWire,
    )
    DateTime? joinedOn,
    @JsonKey(fromJson: TraineeStatus.fromWire, toJson: _statusToWire)
    required TraineeStatus status,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Trainee;

  factory Trainee.fromJson(Map<String, dynamic> json) =>
      _$TraineeFromJson(json);

  bool get isActive => status == TraineeStatus.active;

  /// Whole years on the calendar date of [on]; null without a date of birth.
  int? ageOn(DateTime on) => ageFrom(dateOfBirth, on);

  /// The monthly fee on [on]: 500 under 15, 1000 from 15; null without a date of birth.
  int? feeTierOn(DateTime on) => feeTierFrom(dateOfBirth, on);

  /// The monthly fee today in India; see [feeTierOn].
  int? get feeTier => feeTierOn(indiaNow());

  /// Up to two upper-case initials, first and last word.
  String get initials {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    final first = String.fromCharCode(words.first.runes.first);
    final last = words.length > 1
        ? String.fromCharCode(words.last.runes.first)
        : '';
    return (first + last).toUpperCase();
  }
}

/// Whole years from [dateOfBirth] to the calendar date of [on], as Postgres `age()`.
int? ageFrom(DateTime? dateOfBirth, DateTime on) {
  if (dateOfBirth == null) return null;
  final hadBirthday =
      on.month > dateOfBirth.month ||
      (on.month == dateOfBirth.month && on.day >= dateOfBirth.day);
  return on.year - dateOfBirth.year - (hadBirthday ? 0 : 1);
}

/// 500 under 15 on [on], 1000 from 15; null without a date of birth.
int? feeTierFrom(DateTime? dateOfBirth, DateTime on) {
  final age = ageFrom(dateOfBirth, on);
  if (age == null) return null;
  return age < _seniorAge ? _juniorFee : _seniorFee;
}

/// `Junior` for the under-15 fee, `Senior` for the other.
String feeTierLabel(int tier) => tier == _juniorFee ? 'Junior' : 'Senior';

DateTime? _optionalDateFromWire(String? value) =>
    value == null ? null : parseWireDate(value);

String? _optionalDateToWire(DateTime? date) =>
    date == null ? null : wireDate(date);

String _statusToWire(TraineeStatus status) => status.wire;
