import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/features/trials/domain/trial_request.dart';

import '../fixtures/trials.dart';
import '../scenario.dart';
import 'mock_device_key_store.dart';
import 'mock_trial_repository.dart';

// Thursday.
final _today = DateTime(2026, 11, 5);

TrialRequest _request({
  String fullName = 'Rahul Verma',
  String phone = '9876543210',
  DateTime? sessionDate,
  SessionSlot slot = SessionSlot.morning,
  DateTime? dateOfBirth,
  int? age = 14,
  String? note,
}) => TrialRequest(
  fullName: fullName,
  phone: phone,
  sessionDate: sessionDate ?? DateTime(2026, 11, 6),
  slot: slot,
  dateOfBirth: dateOfBirth,
  age: age,
  note: note,
);

MockTrialRepository _repository({
  MockScenario scenario = MockScenario.success,
}) => MockTrialRepository(
  scenario: scenario,
  clock: () => DateTime.utc(2026, 11, 5, 7),
);

Future<void> _expectRejected(
  TrialRequest request,
  String message, {
  String deviceKey = mockDeviceKey,
}) => expectLater(
  _repository().book(request, deviceKey),
  throwsA(
    isA<ValidationException>().having((e) => e.message, 'message', message),
  ),
);

void main() {
  group('book', () {
    test(
      'stores the booking with a normalized phone and trimmed fields',
      () async {
        final repository = _repository();
        final booking = await repository.book(
          _request(fullName: '  Rahul Verma ', note: '   '),
          mockDeviceKey,
        );

        expect(booking.fullName, 'Rahul Verma');
        expect(booking.phone, '919876543210');
        expect(booking.note, isNull);
        expect(repository.stored, [booking]);
      },
    );

    test('rejects each invalid field with the server message', () async {
      await _expectRejected(_request(fullName: 'A'), 'Enter your name');
      await _expectRejected(
        _request(phone: '12345'),
        'Enter a 10-digit mobile number',
      );
      await _expectRejected(
        _request(sessionDate: DateTime(2026, 11, 4)),
        'Pick today or a later day',
      );
      await _expectRejected(
        _request(sessionDate: DateTime(2026, 12, 6)),
        'Trials can be booked up to 30 days ahead',
      );
      await _expectRejected(
        _request(sessionDate: DateTime(2026, 11, 8)),
        'The club is closed on Sundays',
      );
      await _expectRejected(
        _request(age: null),
        'Tell us your age or date of birth',
      );
      await _expectRejected(_request(age: 2), 'Enter an age between 3 and 99');
      await _expectRejected(
        _request(age: null, dateOfBirth: DateTime(2026, 11, 6)),
        'Date of birth cannot be in the future',
      );
      await _expectRejected(
        _request(note: 'x' * 301),
        'Keep the note to 300 characters or fewer',
      );
      await _expectRejected(
        _request(),
        'Invalid device key',
        deviceKey: 'short',
      );
    });

    test(
      'a second booking for the same phone, day and batch is a duplicate',
      () async {
        final repository = _repository();
        await repository.book(_request(), mockDeviceKey);

        await expectLater(
          repository.book(_request(), mockDeviceKey),
          throwsA(
            isA<DuplicateException>().having(
              (e) => e.message,
              'message',
              'This number already has a trial booked for that batch',
            ),
          ),
        );
        // Another batch on the same day is allowed.
        await repository.book(
          _request(slot: SessionSlot.evening),
          mockDeviceKey,
        );
        expect(repository.stored, hasLength(2));
      },
    );

    test('the error scenario throws an unknown error', () async {
      await expectLater(
        _repository(scenario: MockScenario.error)
            .book(_request(), mockDeviceKey),
        throwsA(isA<UnknownException>()),
      );
    });
  });

  group('mine', () {
    test('returns only this device\'s bookings from today on', () async {
      final repository = MockTrialRepository(
        clock: () => DateTime.utc(2026, 11, 5, 7),
        bookings: fixtureTrials(DateTime(2026, 11, 6)),
        myBookings: [
          ...fixtureTrials(DateTime(2026, 11, 4)).take(1),
          ...fixtureTrials(DateTime(2026, 11, 7)).skip(2),
        ],
      );

      final mine = await repository.mine(mockDeviceKey);

      expect(mine.map((b) => b.id), ['trial-003']);
      expect(mine.single.sessionDate, DateTime(2026, 11, 7));
      expect(await repository.mine('SOMEOTHERKEY23456789ABCDEFGHJKL'), isEmpty);
    });
  });

  group('between', () {
    test('lists the window in date, batch and booking order', () async {
      final repository = MockTrialRepository(
        clock: () => DateTime.utc(2026, 11, 5, 7),
        bookings: [
          ...fixtureTrials(DateTime(2026, 11, 7)),
          ...fixtureTrials(DateTime(2026, 11, 6)).reversed,
          ...fixtureTrials(DateTime(2026, 12, 20)),
        ],
      );

      final found = await repository.between(_today, DateTime(2026, 12, 5));

      expect(found.map((b) => b.id), [
        'trial-001',
        'trial-002',
        'trial-003',
        'trial-001',
        'trial-002',
        'trial-003',
      ]);
      expect(found.first.sessionDate, DateTime(2026, 11, 6));
      expect(found.last.sessionDate, DateTime(2026, 11, 7));
    });

    test('an end before the start is rejected', () async {
      await expectLater(
        _repository().between(DateTime(2026, 11, 6), _today),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'The end date is before the start date',
          ),
        ),
      );
    });
  });
}
