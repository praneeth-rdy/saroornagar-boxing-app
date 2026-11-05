import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/session_slot.dart';
import '../../../core/utils/india_date.dart';

part 'club_session.freezed.dart';
part 'club_session.g.dart';

/// One training session from `public.sessions`; times are `HH:mm:ss` India wall clock.
@freezed
abstract class ClubSession with _$ClubSession {
  const ClubSession._();

  const factory ClubSession({
    required String id,
    @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)
    required DateTime sessionDate,
    @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)
    required SessionSlot slot,
    @JsonKey(name: 'starts_at') required String startsAt,
    @JsonKey(name: 'ends_at') required String endsAt,
    @JsonKey(name: 'created_by') String? createdBy,
  }) = _ClubSession;

  factory ClubSession.fromJson(Map<String, dynamic> json) =>
      _$ClubSessionFromJson(json);

  bool get isExtra => slot == SessionSlot.extra;

  /// `6:00 to 8:30 am`, or `11:30 am to 1:00 pm` across noon.
  String get timeLabel {
    final start = _clockOf(startsAt);
    final end = _clockOf(endsAt);
    final startText = formatClockTime(start);
    final endText = formatClockTime(end);
    if ((start.hour < 12) == (end.hour < 12)) {
      return '${startText.split(' ').first} to $endText';
    }
    return '$startText to $endText';
  }

  /// `4:00 pm`.
  String get startLabel => formatClockTime(_clockOf(startsAt));

  /// The end of the session in India wall-clock time, comparable with `indiaNow()`.
  DateTime get endsAtMoment {
    final end = _clockOf(endsAt);
    return DateTime.utc(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      end.hour,
      end.minute,
      end.second,
    );
  }
}

String _slotToWire(SessionSlot slot) => slot.wire;

DateTime _clockOf(String time) {
  final parts = time.split(':').map(int.parse).toList();
  return DateTime.utc(
    2000,
    1,
    1,
    parts[0],
    parts.length > 1 ? parts[1] : 0,
    parts.length > 2 ? parts[2] : 0,
  );
}
