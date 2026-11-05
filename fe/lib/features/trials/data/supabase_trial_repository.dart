import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/session_slot.dart';
import '../../../core/supabase/supabase_errors.dart';
import '../../../core/utils/india_date.dart';
import '../domain/trial_booking.dart';
import '../domain/trial_request.dart';
import 'trial_repository.dart';

class SupabaseTrialRepository implements TrialRepository {
  SupabaseTrialRepository(this.client);

  final SupabaseClient client;

  @override
  Future<TrialBooking> book(TrialRequest request, String deviceKey) async {
    // The enum cast would fail as an unmapped error; the server's message is the same.
    if (request.slot == SessionSlot.unknown) {
      throw const ValidationException('Pick the morning or the evening batch');
    }
    final dateOfBirth = request.dateOfBirth;
    return guardSupabase(
      () async => TrialBooking.fromJson(
        _row(
          await client.rpc<dynamic>(
            'book_trial',
            params: {
              'p_full_name': request.fullName,
              'p_phone': request.phone,
              'p_session_date': wireDate(request.sessionDate),
              'p_slot': request.slot.wire,
              'p_device_key': deviceKey,
              'p_date_of_birth': dateOfBirth == null
                  ? null
                  : wireDate(dateOfBirth),
              'p_age': request.age,
              'p_note': request.note,
            },
          ),
        ),
      ),
    );
  }

  @override
  Future<List<TrialBooking>> mine(String deviceKey) => guardSupabase(
    () async => _rows(
      await client.rpc<dynamic>(
        'my_trial_bookings',
        params: {'p_device_key': deviceKey},
      ),
    ).map(TrialBooking.fromJson).toList(),
  );

  @override
  Future<List<TrialBooking>> between(DateTime from, DateTime to) =>
      guardSupabase(
        () async => _rows(
          await client.rpc<dynamic>(
            'trial_bookings_between',
            params: {'p_from': wireDate(from), 'p_to': wireDate(to)},
          ),
        ).map(TrialBooking.fromJson).toList(),
      );
}

// A set-returning function comes back as a JSON array of row objects.
List<Map<String, dynamic>> _rows(dynamic result) => [
  for (final row in result as List) Map<String, dynamic>.from(row as Map),
];

// A function returning one composite row comes back as a single JSON object.
Map<String, dynamic> _row(dynamic result) =>
    Map<String, dynamic>.from(result as Map);
