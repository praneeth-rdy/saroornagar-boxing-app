import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// A small upper-case section label above a group.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text.toUpperCase(), style: AppTypography.eyebrow),
    );
  }
}
