import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which backend a build talks to.
enum AppEnv {
  dev,
  prod;

  /// Anything other than `prod` is treated as dev so a typo never reaches production.
  static AppEnv parse(String? value) => value == 'prod' ? prod : dev;
}

/// Runtime configuration read from `--dart-define-from-file=config/<env>.json`.
class AppConfig {
  const AppConfig({
    required this.env,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  factory AppConfig.fromEnvironment() {
    const env = String.fromEnvironment('APP_ENV');
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    return AppConfig(
      env: AppEnv.parse(env),
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );
  }

  final AppEnv env;
  final String supabaseUrl;

  /// The publishable (anon) key only; the service role key never reaches the app.
  final String supabaseAnonKey;

  bool get isConfigured =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}

/// Overridden in `main` with the config the app booted with.
final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);
