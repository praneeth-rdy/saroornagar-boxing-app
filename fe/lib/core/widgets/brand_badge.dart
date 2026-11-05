import 'package:flutter/widgets.dart';

/// The club's L5a Classic badge, centred, for the public entry screens.
class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key});

  static const double size = 120;

  @override
  Widget build(BuildContext context) {
    // Height is fixed so the layout does not jump while the asset decodes.
    return Center(
      child: Image.asset(
        'assets/brand/badge.png',
        width: size,
        height: size,
        semanticLabel: 'Saroornagar Boxing',
      ),
    );
  }
}
