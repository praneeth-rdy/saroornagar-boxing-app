import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'misconfigured_screen.dart';

/// The whole app when configuration is missing: no Supabase, no router, no mock backend.
class MisconfiguredApp extends StatelessWidget {
  const MisconfiguredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saroornagar Boxing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MisconfiguredScreen(),
    );
  }
}
