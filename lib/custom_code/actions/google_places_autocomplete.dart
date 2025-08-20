// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> googlePlacesAutocomplete(
  BuildContext context,
  String apiKey,
  String input,
  String? components,
  int? minLength,
  String? sessionToken,
  String? language,
) async {
  // Defaults e validação
  final key = (apiKey).trim();
  final q = (input).trim();
  final lang = (language == null || language.isEmpty) ? 'pt-BR' : language;
  final minLen = (minLength == null || minLength <= 0) ? 2 : minLength;

  if (key.isEmpty || q.length < minLen) {
    return <dynamic>[];
  }

  // Monta query
  final params = <String, String>{
    'input': q,
    'language': lang,
    'types': 'geocode',
    'key': key,
  };
  if (components != null && components.isNotEmpty) {
    params['components'] = components; // ex: "country:br|country:us"
  }
  if (sessionToken != null && sessionToken.isNotEmpty) {
    params['sessiontoken'] = sessionToken;
  }

  final uri = Uri.https(
    'maps.googleapis.com',
    '/maps/api/place/autocomplete/json',
    params,
  );

  try {
    final res = await http.get(uri);
    if (res.statusCode != 200) return <dynamic>[];

    final data = json.decode(res.body) as Map<String, dynamic>;
    final status = (data['status'] ?? '').toString();
    if (status != 'OK' && status != 'ZERO_RESULTS') return <dynamic>[];

    final preds = (data['predictions'] as List?) ?? const [];
    // Normaliza pro formato fácil de bindar no FF
    return preds.map((p) {
      final m = (p as Map).cast<String, dynamic>();
      final fmt =
          (m['structured_formatting'] as Map?)?.cast<String, dynamic>() ??
              const {};
      return {
        'placeId': (m['place_id'] ?? '').toString(),
        'description': (m['description'] ?? '').toString(),
        'mainText': (fmt['main_text'] ?? m['description'] ?? '').toString(),
        'secondaryText': (fmt['secondary_text'] ?? '').toString(),
      };
    }).toList();
  } catch (_) {
    // Em caso de erro, retorna lista vazia para não quebrar o fluxo
    return <dynamic>[];
  }
}
