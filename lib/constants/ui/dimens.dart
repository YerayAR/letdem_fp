import 'package:gap/gap.dart';

class Dimens {
  static double baseSize = 8;
  static double defaultMargin = 20;
  static double defaultMarginSM = 16;

  static double defaultRadius = 15;
  static double defaultRadiusLarge = 15;

  // ==
  static Gap space(double multiplier) => Gap(baseSize * multiplier);
}
