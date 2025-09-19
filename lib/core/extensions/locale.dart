import 'package:flutter/material.dart';
import 'package:letdem/l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n {
    return AppLocalizations.of(this)!;
  }

  bool get isSpanish {
    return Localizations.localeOf(this).languageCode == 'es';
  }
}
