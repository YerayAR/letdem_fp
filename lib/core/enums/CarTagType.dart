import 'package:letdem/core/constants/assets.dart';

enum CarTagType {
  zero,
  eco,
  c,
  b,
  none,
}

String geTagTypeIcon(CarTagType type) {
  switch (type) {
    case CarTagType.zero:
      return AppAssets.carTagZero;
    case CarTagType.eco:
      return AppAssets.carTagEco;
    case CarTagType.c:
      return AppAssets.carTagC;
    case CarTagType.b:
      return AppAssets.carTagB;
    case CarTagType.none:
      return AppAssets.carTagNone;
  }
}
