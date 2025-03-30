import 'package:flutter/material.dart';
import 'package:letdem/l10n/locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? defaultLocale;

  Locale? get getDefaultLocale => defaultLocale;

  bool _isJapan = false;

  bool get isJapan => _isJapan;

  LocaleProvider({this.defaultLocale});

  void setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("locale", locale.languageCode);
    defaultLocale = locale;
    _isJapan = (locale.languageCode == "ja");
    notifyListeners();
  }

  Future<String?> getLocale() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String? languageCode = sharedPreferences.getString('locale');
    _isJapan = languageCode == "ja";
    notifyListeners();
    return languageCode;
  }
}
