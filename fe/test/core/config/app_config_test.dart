import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/config/app_config.dart';

void main() {
  group('AppConfig.isConfigured', () {
    test('is true when url and key are set', () {
      const config = AppConfig(
        env: AppEnv.dev,
        supabaseUrl: 'https://example.supabase.co',
        supabaseAnonKey: 'publishable-key',
      );

      expect(config.isConfigured, isTrue);
    });

    test('is false when the url is empty', () {
      const config = AppConfig(
        env: AppEnv.dev,
        supabaseUrl: '',
        supabaseAnonKey: 'publishable-key',
      );

      expect(config.isConfigured, isFalse);
    });

    test('is false when the key is blank', () {
      const config = AppConfig(
        env: AppEnv.dev,
        supabaseUrl: 'https://example.supabase.co',
        supabaseAnonKey: '  ',
      );

      expect(config.isConfigured, isFalse);
    });

    test('fromEnvironment without defines is not configured and is dev', () {
      final config = AppConfig.fromEnvironment();

      expect(config.isConfigured, isFalse);
      expect(config.env, AppEnv.dev);
    });
  });

  group('AppEnv.parse', () {
    test('reads prod', () => expect(AppEnv.parse('prod'), AppEnv.prod));
    test('reads dev', () => expect(AppEnv.parse('dev'), AppEnv.dev));
    test('defaults null to dev', () => expect(AppEnv.parse(null), AppEnv.dev));
    test(
      'defaults a typo to dev',
      () => expect(AppEnv.parse('prd'), AppEnv.dev),
    );
  });
}
