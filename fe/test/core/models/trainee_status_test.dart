import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/models/trainee_status.dart';

void main() {
  group('TraineeStatus', () {
    test('fromWire parses a known wire value', () {
      expect(TraineeStatus.fromWire('inactive'), TraineeStatus.inactive);
    });

    test('fromWire returns unknown for null', () {
      expect(TraineeStatus.fromWire(null), TraineeStatus.unknown);
    });

    test('fromWire returns unknown for an unmatched value', () {
      expect(TraineeStatus.fromWire('nonsense'), TraineeStatus.unknown);
    });

    test(
      'fromWire does not parse the literal unknown wire as a real value',
      () {
        expect(TraineeStatus.fromWire('unknown'), TraineeStatus.unknown);
      },
    );

    test('wire round trips for every real value', () {
      for (final item in TraineeStatus.values.where(
        (item) => item != TraineeStatus.unknown,
      )) {
        expect(TraineeStatus.fromWire(item.wire), item);
      }
    });
  });
}
