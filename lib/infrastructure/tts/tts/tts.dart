import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:letdem/notifiers/locale.notifier.dart';
import 'dart:io' show Platform;

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool isMuted = false;
  String _currentLanguage = "en-GB"; // Track current language

  SpeechService._internal();

  Future<void> _applyVoiceTuning() async {
    double rate;
    double pitch;

    // Basic language buckets (extend if you add more)
    final isEs = _currentLanguage.toLowerCase().startsWith('es');
    final isEn = _currentLanguage.toLowerCase().startsWith('en');

    if (Platform.isAndroid) {
      // Android TTS tends a bit fast by default
      if (isEs) {
        rate = 0.50; // clear and natural for Spanish
        pitch = 1.0;
      } else if (isEn) {
        rate = 0.52; // slightly quicker for English clarity
        pitch = 1.0;
      } else {
        rate = 0.50;
        pitch = 1.0;
      }
    } else if (Platform.isIOS) {
      // iOS voices often need a touch slower to avoid robotic cadence
      if (isEs) {
        rate = 0.48;
        pitch = 1.0;
      } else if (isEn) {
        rate = 0.50;
        pitch = 1.0;
      } else {
        rate = 0.50;
        pitch = 1.0;
      }
    } else {
      // Fallback (other platforms)
      rate = 0.50;
      pitch = 1.0;
    }

    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);

    if (kDebugMode) {
      debugPrint(
        '🗣️ Applied voice tuning => rate: $rate, pitch: $pitch, lang: $_currentLanguage',
      );
    }
  }

  Future<void> _init(BuildContext context) async {
    if (_isInitialized) return;
    final language = Localizations.localeOf(context).languageCode;

    // Normalize and store language using our mapping logic
    setLanguage(language);

    // Now actually apply to engine since we're initializing
    await _flutterTts.setLanguage(_currentLanguage);
    await _applyVoiceTuning();

    _isInitialized = true;
  }

  // Add method to set language
  void setLanguage(String languageCode) {
    // Map common language codes to TTS supported codes
    String ttsLanguageCode = switch (languageCode.toLowerCase()) {
      'es' || 'es-es' || 'es-mx' => 'es-ES', // Spanish (Spain)
      'en' || 'en-us' || 'en-gb' => 'en-GB', // English (UK)
      _ => 'en-GB', // Default fallback
    };

    _currentLanguage = ttsLanguageCode;

    // If already initialized, update the language immediately
    if (_isInitialized) {
      _flutterTts.setLanguage(_currentLanguage);
      _applyVoiceTuning();
    }

    if (kDebugMode) {
      debugPrint('🗣️ SpeechService language set to: $_currentLanguage');
    }
  }

  Future<void> speak(String text, BuildContext context) async {
    if (isMuted) return;
    await _init(context);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void mute() {
    isMuted = true;
    stop();
  }

  void unmute() {
    isMuted = false;
  }

  bool get isSpeaking => !isMuted;
}
