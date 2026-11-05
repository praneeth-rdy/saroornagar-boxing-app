import 'package:flutter/painting.dart';

/// Corner radii for direction A.
abstract final class AppRadius {
  static const double card = 16;
  static const double control = 12;
  static const double chip = 999;

  static const cardAll = BorderRadius.all(Radius.circular(card));
  static const controlAll = BorderRadius.all(Radius.circular(control));
  static const chipAll = BorderRadius.all(Radius.circular(chip));
}
