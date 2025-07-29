import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool isMuted = false;
  String _currentLanguage = "en-GB"; // Track current language

  SpeechService._internal();

  Future<void> _init() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage("en-GB");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(.8);
    _isInitialized = true;
  }

  // Add method to set language
  Future<void> setLanguage(String languageCode) async {
    // Map common language codes to TTS supported codes
    String ttsLanguageCode;
    
    switch (languageCode.toLowerCase()) {
      case 'es':
      case 'es-es':
      case 'es-mx':
        ttsLanguageCode = "es-ES"; // Spanish (Spain)
        break;
      case 'en':
      case 'en-us':
      case 'en-gb':
        ttsLanguageCode = "en-GB"; // English (UK)
        break;
      default:
        ttsLanguageCode = "en-GB"; // Default fallback
    }

    _currentLanguage = ttsLanguageCode;
    
    // If already initialized, update the language immediately
    if (_isInitialized) {
      await _flutterTts.setLanguage(_currentLanguage);
    }
    
    print('🗣️ SpeechService language set to: $_currentLanguage');
  }

  Future<void> speak(String text) async {
    if (isMuted) return;
    await _init();
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
