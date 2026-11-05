import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';

import 'scenario.dart';

void main() {
  group('applyScenario', () {
    test('success returns the success value', () async {
      expect(
        await applyScenario(
          MockScenario.success,
          success: () => 1,
          empty: () => 0,
        ),
        1,
      );
    });

    test('empty returns the empty value', () async {
      expect(
        await applyScenario(
          MockScenario.empty,
          success: () => 1,
          empty: () => 0,
        ),
        0,
      );
    });

    test('empty falls back to success when no empty is given', () async {
      expect(await applyScenario(MockScenario.empty, success: () => 1), 1);
    });

    test('error throws UnknownException', () {
      expect(
        applyScenario(MockScenario.error, success: () => 1),
        throwsA(isA<UnknownException>()),
      );
    });

    test('permissionDenied throws PermissionException', () {
      expect(
        applyScenario(MockScenario.permissionDenied, success: () => 1),
        throwsA(isA<PermissionException>()),
      );
    });

    test('offline throws OfflineException', () {
      expect(
        applyScenario(MockScenario.offline, success: () => 1),
        throwsA(isA<OfflineException>()),
      );
    });

    testWidgets('slow succeeds only after two seconds', (tester) async {
      int? result;
      applyScenario(
        MockScenario.slow,
        success: () => 1,
      ).then((value) => result = value);

      await tester.pump(const Duration(milliseconds: 1900));
      expect(result, isNull);

      await tester.pump(const Duration(milliseconds: 200));
      expect(result, 1);
    });
  });
}
