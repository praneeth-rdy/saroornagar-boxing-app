import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/config/app_config.dart';
import 'package:saroornagar_boxing/features/startup/presentation/misconfigured_app.dart';

void main() {
  testWidgets(
    'a build without defines is unconfigured and shows the misconfigured screen',
    (tester) async {
      final config = AppConfig.fromEnvironment();

      await tester.pumpWidget(const MisconfiguredApp());

      expect(config.isConfigured, isFalse);
      expect(find.text('App not configured'), findsOneWidget);
      expect(
        find.text('Run with --dart-define-from-file=config/dev.json.'),
        findsOneWidget,
      );
    },
  );
}
