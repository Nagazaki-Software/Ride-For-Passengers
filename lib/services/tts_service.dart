import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter/material.dart';
import '../app_state.dart';
import '../flutter_flow/flutter_flow_util.dart';

class TtsService {
  TtsService._internal();
  static final TtsService instance = TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  String? _lastLanguageCode;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      // Wait for completion to prevent overlapping announcements
      await _tts.awaitSpeakCompletion(true);
      // Reasonable defaults
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      // Don't force language; let system/locale drive it. If desired,
      // enable next line and pass a locale, e.g. 'pt-BR'.
      // await _tts.setLanguage('pt-BR');
      _initialized = true;
    } catch (_) {
      // Silently ignore init errors to avoid impacting UI
    }
  }

  String _mapLocaleToTtsCode(String code) {
    switch (code) {
      case 'pt':
        return 'pt-BR';
      case 'en':
        return 'en-US';
      case 'es':
        return 'es-ES';
      case 'de':
        return 'de-DE';
      case 'fr':
        return 'fr-FR';
      default:
        return code; // Try raw code; platform may accept it
    }
  }

  Future<void> _ensureLanguageForContext(BuildContext context) async {
    final code = FFLocalizations.of(context).languageCode;
    if (_lastLanguageCode == code) return;
    _lastLanguageCode = code;
    try {
      await _tts.setLanguage(_mapLocaleToTtsCode(code));
    } catch (_) {
      // ignore; if not supported, platform fallback applies
    }
  }

  bool get _audioEnabled => FFAppState().prefs.getBool('ff_accessibilityAudioFeedback') ?? FFAppState().accessibilityAudioFeedback;

  Future<void> speak(String text, {bool force = false, BuildContext? context}) async {
    try {
      // Only speak when audio feedback is enabled, unless forced
      if (!force && !_audioEnabled) return;
      await _ensureInitialized();
      if (context != null) {
        await _ensureLanguageForContext(context);
      }
      if (text.trim().isEmpty) return;
      // Stop any ongoing utterance to keep it snappy for UI actions
      try {
        await _tts.stop();
      } catch (_) {}
      await _tts.speak(text);
    } catch (_) {
      // no-op: TTS errors should never break flows
    }
  }

  Future<void> announceAction(String label, {BuildContext? context}) async {
    // Keep it short and immediate; don't block UI
    unawaited(speak(label, context: context));
  }
}
