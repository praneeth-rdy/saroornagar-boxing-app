import 'package:saroornagar_boxing/core/errors/app_exception.dart';

/// How a mock repository behaves for one test.
enum MockScenario { success, empty, slow, error, permissionDenied, offline }

/// How long the [MockScenario.slow] scenario waits before succeeding.
const slowScenarioDelay = Duration(seconds: 2);

/// Resolves a mock call according to [scenario], throwing the same exceptions a real
/// repository would.
Future<T> applyScenario<T>(
  MockScenario scenario, {
  required T Function() success,
  T Function()? empty,
}) async {
  switch (scenario) {
    case MockScenario.success:
      return success();
    case MockScenario.empty:
      return (empty ?? success)();
    case MockScenario.slow:
      await Future<void>.delayed(slowScenarioDelay);
      return success();
    case MockScenario.error:
      throw const UnknownException();
    case MockScenario.permissionDenied:
      throw const PermissionException();
    case MockScenario.offline:
      throw const OfflineException();
  }
}
