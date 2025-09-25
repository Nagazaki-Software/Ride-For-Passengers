import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    // Sensible defaults; platforms may clamp values.
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.45);
    _initialized = true;
  }

  static Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _ensureInitialized();
    try {
      await _tts.stop();
    } catch (_) {}
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

