import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/router/route_guards.dart';
import 'package:saroornagar_boxing/core/router/routes.dart';

void main() {
  group('redirectFor', () {
    test('sends a signed-out visitor on a staff tab to sign-in', () {
      expect(
        redirectFor(hasSession: false, location: Routes.today),
        Routes.signIn,
      );
      expect(
        redirectFor(hasSession: false, location: Routes.trials),
        Routes.signIn,
      );
    });

    test('keeps a signed-out visitor on the public locations', () {
      expect(redirectFor(hasSession: false, location: Routes.trial), isNull);
      expect(
        redirectFor(hasSession: false, location: '${Routes.trial}/confirmed'),
        isNull,
      );
      expect(redirectFor(hasSession: false, location: Routes.signIn), isNull);
    });

    test('sends a signed-in user on sign-in to today', () {
      expect(
        redirectFor(hasSession: true, location: Routes.signIn),
        Routes.today,
      );
    });

    test('leaves a signed-in user on any other location', () {
      expect(redirectFor(hasSession: true, location: Routes.more), isNull);
      expect(redirectFor(hasSession: true, location: Routes.trial), isNull);
    });
  });
}
