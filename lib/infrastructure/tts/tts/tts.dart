import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool isMuted = false;

  SpeechService._internal();

  Future<void> _init() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage("en-GB");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(.8);
    _isInitialized = true;
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
