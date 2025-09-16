// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Imports extras para esta action:
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> geocodeAddress(
  BuildContext context,
  String apiKey,
  String address,
) async {
  // Validação
  final key = apiKey.trim();
  final query = address.trim();
  if (key.isEmpty) {
    throw Exception('Missing Google API Key.');
  }
  if (query.isEmpty) {
    throw Exception('Address is empty.');
  }

  // Monta request (language=en, sem country)
  final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
    'address': query,
    'language': 'en',
    'key': key,
  });

  // Chamada com timeout
  late http.Response res;
  try {
    res = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(
        const Duration(seconds: 12));
  } catch (e) {
    throw Exception('Network/Timeout: $e');
  }

  if (res.statusCode != 200) {
    throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase ?? 'error'}');
  }

  // Parse do JSON
  Map<String, dynamic> data;
  try {
    data = jsonDecode(res.body) as Map<String, dynamic>;
  } catch (_) {
    throw Exception('Invalid JSON from Geocoding API.');
  }

  final status = (data['status'] ?? '').toString();

  // Tratativas comuns
  if (status == 'ZERO_RESULTS') return null;
  if (status == 'OVER_QUERY_LIMIT') {
    throw Exception('Over query limit (billing/quota).');
  }
  if (status == 'REQUEST_DENIED') {
    final msg = (data['error_message'] ?? '').toString();
    throw Exception('Request denied. $msg');
  }
  if (status != 'OK') {
    final msg = (data['error_message'] ?? '').toString();
    // Não quebra o fluxo: loga e retorna null
    print('Geocode status=$status message=$msg');
    return null;
  }

  final results = (data['results'] as List).cast<Map<String, dynamic>>();
  if (results.isEmpty) return null;

  final best = results.first;
  final loc = (best['geometry']?['location'] ?? {}) as Map<String, dynamic>;
  if (!loc.containsKey('lat') || !loc.containsKey('lng')) return null;

  final double lat = (loc['lat'] as num).toDouble();
  final double lng = (loc['lng'] as num).toDouble();
  final String formattedAddress = (best['formatted_address'] ?? '').toString();
  final String placeId = (best['place_id'] ?? '').toString();

  // Retorno mapeado aos Outputs da Action
  return {
    'lat': lat,
    'lng': lng,
    'formattedAddress': formattedAddress,
    'placeId': placeId,
  };
}
