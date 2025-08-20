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
import 'dart:math' as math;

// Retorna uma lista de lugares importantes próximos à localização do usuário (LatLng do FlutterFlow)
Future<List<dynamic>> googlePlacesNearbyImportant(
  BuildContext context,
  String apiKey,
  LatLng userLocation, // <-- LatLng do FlutterFlow
  int? radiusMeters, // ex: 2500
  String? typesCsv, // ex: "airport,hospital,police"
  String? language, // ex: "pt-BR"
  int? maxResults, // ex: 20
) async {
  // ---- Defaults e validação ----
  final key = (apiKey).trim();
  if (key.isEmpty) return <dynamic>[];

  final lang = (language == null || language.isEmpty) ? 'pt-BR' : language!;
  final radius =
      (radiusMeters == null || radiusMeters <= 0) ? 2500 : radiusMeters!;
  final limit = (maxResults == null || maxResults <= 0) ? 20 : maxResults!;

  final lat = userLocation.latitude;
  final lng = userLocation.longitude;

  // Tipos importantes padrão (se não passar typesCsv)
  final defaultImportantTypes = <String>{
    'airport',
    'hospital',
    'police',
    'fire_station',
    'pharmacy',
    'supermarket',
    'shopping_mall',
    'bank',
    'atm',
    'train_station',
    'subway_station',
    'bus_station',
    'university',
    'school',
    'museum',
    'tourist_attraction',
    'park',
    'stadium',
    'city_hall',
    'embassy',
  };

  final pickedTypes = (typesCsv == null || typesCsv.trim().isEmpty)
      ? defaultImportantTypes
      : typesCsv
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toSet();

  // Nearby Search aceita 1 type por chamada: vamos iterar limitando para controlar custo/latência
  final typesToQuery = pickedTypes.take(10).toList();

  // Helpers
  String? photoUrl(Map<String, dynamic> place) {
    final photos = (place['photos'] as List?)?.cast<Map<String, dynamic>>();
    if (photos == null || photos.isEmpty) return null;
    final ref = (photos.first['photo_reference'] ?? '').toString();
    if (ref.isEmpty) return null;
    final p = {
      'maxwidth': '800',
      'photoreference': ref,
      'key': key,
    };
    final u = Uri.https('maps.googleapis.com', '/maps/api/place/photo', p);
    return u.toString();
  }

  num distanceMeters(num lat1, num lon1, num lat2, num lon2) {
    const R = 6371000;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  final seen = <String>{};
  final aggregated = <Map<String, dynamic>>[];

  Future<void> fetchByType(String type) async {
    String? pageToken;

    // Até 2 páginas por tipo (controle de custo)
    for (int page = 0; page < 2; page++) {
      final params = <String, String>{
        'location': '$lat,$lng',
        'radius': radius.toString(),
        'language': lang,
        'type': type,
        'key': key,
        if (pageToken != null) 'pagetoken': pageToken!,
      };

      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/nearbysearch/json',
        params,
      );

      final res = await http.get(uri);
      if (res.statusCode != 200) break;

      final data = json.decode(res.body) as Map<String, dynamic>;
      final status = (data['status'] ?? '').toString();
      if (status == 'OVER_QUERY_LIMIT' || status == 'REQUEST_DENIED') break;
      if (status != 'OK' && status != 'ZERO_RESULTS') break;

      final results =
          (data['results'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

      for (final m in results) {
        final placeId = (m['place_id'] ?? '').toString();
        if (placeId.isEmpty || seen.contains(placeId)) continue;
        seen.add(placeId);

        final geo =
            ((m['geometry'] ?? {}) as Map)['location'] as Map<String, dynamic>?;

        final placeLat =
            (geo?['lat'] is num) ? (geo?['lat'] as num).toDouble() : null;
        final placeLng =
            (geo?['lng'] is num) ? (geo?['lng'] as num).toDouble() : null;

        final dist = (placeLat != null && placeLng != null)
            ? distanceMeters(lat, lng, placeLat, placeLng).round()
            : null;

        aggregated.add({
          'placeId': placeId,
          'name': (m['name'] ?? '').toString(),
          'address': (m['vicinity'] ?? m['formatted_address'] ?? '').toString(),
          'types': (m['types'] as List?)?.map((e) => e.toString()).toList() ??
              const <String>[],
          'rating':
              (m['rating'] is num) ? (m['rating'] as num).toDouble() : null,
          'userRatingsTotal': (m['user_ratings_total'] is num)
              ? (m['user_ratings_total'] as num).toInt()
              : null,
          'openNow': (((m['opening_hours'] ?? {}) as Map)['open_now']) is bool
              ? ((m['opening_hours'] as Map)['open_now'] as bool)
              : null,
          'lat': placeLat,
          'lng': placeLng,
          'distanceMeters': dist,
          'icon': (m['icon'] ?? '').toString(),
          'photoUrl': photoUrl(m) ?? '',
          'sourceType': type,
        });

        if (aggregated.length >= limit) return;
      }

      final tok = (data['next_page_token'] ?? '').toString();
      if (tok.isEmpty) break;
      pageToken = tok;

      // Se quiser paginar de verdade em uma única chamada:
      // await Future.delayed(const Duration(seconds: 2));
    }
  }

  try {
    for (final t in typesToQuery) {
      await fetchByType(t);
      if (aggregated.length >= limit) break;
    }

    // Ordena por distância asc, empate por rating desc
    aggregated.sort((a, b) {
      final da = (a['distanceMeters'] ?? 1 << 30) as int;
      final db = (b['distanceMeters'] ?? 1 << 30) as int;
      if (da != db) return da.compareTo(db);
      final ra = (a['rating'] ?? 0.0) as double;
      final rb = (b['rating'] ?? 0.0) as double;
      return -ra.compareTo(rb);
    });

    return aggregated.take(limit).toList();
  } catch (_) {
    return <dynamic>[];
  }
}
