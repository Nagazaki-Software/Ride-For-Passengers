import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/auth/firebase_auth/auth_util.dart';

List<String> nationalityList() {
  // all nationality list
  return [
    'Afghan',
    'Albanian',
    'Algerian',
    'American',
    'Andorran',
    'Angolan',
    'Antiguans',
    'Argentine',
    'Armenian',
    'Australian',
    'Austrian',
    'Azerbaijani',
    'Bahamian',
    'Bahraini',
    'Bangladeshi',
    'Barbadian',
    'Barber',
    'Belarusian',
    'Belgian',
    'Belizean',
    'Beninese',
    'Bhutanese',
    'Bolivian',
    'Bosnian',
    'Brazilian',
    'British',
    'Bruneian',
    'Bulgarian',
    'Burkinabe',
    'Burmese',
    'Burundian',
    'Cabo Verdean',
    'Cambodian',
    'Cameroonian',
    'Canadian',
    'Central African',
    'Chadian',
    'Chilean',
    'Chinese',
    'Colombian',
    'Comoran',
    'Congolese',
    'Costa Rican',
    'Croatian',
    'Cuban',
    'Cypriot',
    'Czech',
    'Danish',
    'Djiboutian',
    'Dominican',
    'Dutch',
    'Ecuadorian',
    'Egyptian',
    'Salvadoran',
    'Equatorial Guinean',
    'Eritrean',
    'Estonian',
    'Eswatini',
    'Ethiopian',
    'Fijian',
    'Finnish',
    'French',
    'Gabonese',
    'Gambian',
    'Georgian',
    'German',
    'Ghanaian',
    'Greek',
    'Grenadian',
    'Guatemalan',
    'Guinean',
    'Guyanese',
    'Haitian',
    'Honduran',
    'Hungarian',
    'Icelandic',
    'Indian',
    'Indonesian',
    'Iranian',
    'Iraqi',
    'Irish',
    'Israeli',
    'Italian',
    'Jamaican',
    'Japanese',
    'Jordanian',
    'Kazakhstani',
    'Kenyan',
    'Kiribati',
    'Kuwaiti',
    'Kyrgyz',
    'Laotian',
    'Latvian',
    'Lebanese',
    'Lesotho',
    'Liberian',
    'Libyan',
    'Liechtenstein',
    'Lithuanian',
    'Luxembourgish',
    'Malagasy',
    'Malawian',
    'Malaysian',
    'Maldivian',
    'Malian',
    'Maltese',
    'Marshallese',
    'Mauritanian',
    'Mauritian',
    'Mexican',
    'Micronesian',
    'Moldovan',
    'Monacan',
    'Mongolian',
    'Montenegrin',
    'Moroccan',
    'Mozambican',
    'Namibian',
    'Nauruan',
    'Nepalese',
    'Dutch',
    'New Zealander',
    'Nicaraguan',
    'Nigerien',
    'Nigerian',
    'North Korean',
    'Norwegian',
    'Omani',
    'Pakistani',
    'Palauan',
    'Palestinian',
    'Panamanian',
    'Papua New Guinean',
    'Paraguayan',
    'Peruvian',
    'Philippine',
    'Polish',
    'Portuguese',
    'Qatari',
    'Romanian',
    'Russian',
    'Rwandan',
    'Saint Lucian',
    'Saint Vincentian',
    'Samoan',
    'San Marinese',
    'Sao Tomean',
    'Saudi',
    'Scottish',
    'Senegalese',
    'Serbian',
    'Seychellois',
    'Sierra Leonean',
    'Singaporean',
    'Slovak',
    'Slovenian',
    'Solomon Islander',
    'Somali',
    'South African',
    'South Korean',
    'Spanish',
    'Sri Lankan',
    'Sudanese',
    'Surinamese',
    'Swedish',
    'Swiss',
    'Syrian',
    'Taiwanese',
    'Tajik',
    'Tanzanian',
    'Thai',
    'Togolese',
    'Tongan',
    'Trinidadian',
    'Tunisian',
    'Turkish',
    'Turkmen',
    'Tuvaluan',
    'Ugandan',
  ];
}

List<String> stateUsList() {
  // all state us
  return [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming',
  ];
}

String partesDoName(String name) {
  // se o nome do usuario for com uma palavra retorne as 2 primeiras letras se for composto os 2 primeiros do composto
  List<String> nameParts = name.split(' ');
  if (nameParts.length == 1) {
    return nameParts[0].substring(0, 2);
  } else {
    return nameParts[0].substring(0, 2) + nameParts[1].substring(0, 2);
  }
}

LatLng formatStringToLantLng(
  String lat,
  String lng,
) {
  // format string to latlng
  return LatLng(double.parse(lat), double.parse(lng));
}

String latlngForKm(
  LatLng latlngAtual,
  LatLng latlngWhereTo,
) {
  const double earthRadius = 6371.0;

  double degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  final double dLat =
      degreesToRadians(latlngWhereTo.latitude - latlngAtual.latitude);
  final double dLng =
      degreesToRadians(latlngWhereTo.longitude - latlngAtual.longitude);

  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(degreesToRadians(latlngAtual.latitude)) *
          math.cos(degreesToRadians(latlngWhereTo.latitude)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);

  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  final double distance = earthRadius * c;

  return '${distance.toStringAsFixed(1)} km';
}

int quantasRidesNesteMes(
  List<RideOrdersRecord> rides,
  DateTime diaAtual,
) {
  // retorne quantas rides no mes baseado em rides.dia
  int count = 0;
  for (var ride in rides) {
    if (ride.hasDia() &&
        ride.dia!.year == diaAtual.year &&
        ride.dia!.month == diaAtual.month) {
      count++;
    }
  }
  return count;
}

double progressBarRidePoints(int ridePoints) {
  // Defina os limites para cada fase
  const int bronzeLimit = 1000;
  const int silverLimit = 2300;
  const int goldLimit = 3400;
  const int platinumLimit = 4500;

  // Cálculo progressivo para cada fase
  if (ridePoints <= bronzeLimit) {
    return ridePoints / bronzeLimit; // Bronze
  } else if (ridePoints <= silverLimit) {
    return (ridePoints - bronzeLimit) / (silverLimit - bronzeLimit); // Silver
  } else if (ridePoints <= goldLimit) {
    return (ridePoints - silverLimit) / (goldLimit - silverLimit); // Gold
  } else if (ridePoints <= platinumLimit) {
    return (ridePoints - goldLimit) / (platinumLimit - goldLimit); // Platinum
  } else {
    return 1.0; // Após Platinum, o progresso chega a 1
  }
}

LatLng? stringToLatlng(String txt) {
  // string to latlng if txt no latlng return null
  final regex = RegExp(r'([-+]?[0-9]*\.?[0-9]+),\s*([-+]?[0-9]*\.?[0-9]+)');
  final match = regex.firstMatch(txt);
  if (match != null) {
    final latitude = double.tryParse(match.group(1)!);
    final longitude = double.tryParse(match.group(2)!);
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }
  }
  return null;
}

String esconderCreditCard(String creditCard) {
  // 1) Mantém só os dígitos (remove espaços, traços, etc.)
  final onlyDigits = creditCard.replaceAll(RegExp(r'\D'), '');

  // 2) Se não sobrou nada, retorna só a máscara
  if (onlyDigits.isEmpty) return '****';

  // 3) Pega os últimos até 4 dígitos (se tiver menos de 4, mostra o que tiver)
  final end = onlyDigits.length;
  final start = math.max(0, end - 4);
  final last4 = onlyDigits.substring(start, end);

  // 4) Formato final: **** 1234
  return '**** $last4';
}

double mediaCorridaNesseKm(
  LatLng laltngOrigem,
  LatLng latlngDestino,
  List<RideOrdersRecord> order,
) {
  // --- Parâmetros ajustáveis ---
  const double toleranciaRelativa = 0.20; // ±20% da distância alvo
  const double raioTerraKm = 6371.0; // Haversine
  const double minDistKm = 0.05; // Evita divisão por zero (~50m)

  double _deg2rad(double deg) => deg * (math.pi / 180.0);

  // Distância Haversine em km entre dois LatLng
  double _distanciaKm(LatLng a, LatLng b) {
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final la1 = _deg2rad(a.latitude);
    final la2 = _deg2rad(b.latitude);

    final hav = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) * math.sin(dLon / 2) * math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(hav), math.sqrt(1 - hav));
    return raioTerraKm * c;
  }

  // Distância do trecho solicitado
  final alvoKm = _distanciaKm(laltngOrigem, latlngDestino);
  if (alvoKm < minDistKm) {
    // Trecho muito curto (ou pontos iguais) — não dá para estimar preço por km.
    return 0.0;
  }

  // Coleta preço/km de cada corrida válida
  final List<double> precoPorKmTodas = [];
  final List<double> precoPorKmSemelhantes = [];

  for (final o in order) {
    // Proteções contra nulos / dados incompletos
    final origem = o.latlngAtual; // origem histórica
    final destino = o.latlng; // destino histórico
    final valor = o.rideValue; // preço total da corrida

    if (origem == null || destino == null || valor == null) continue;
    if (valor <= 0) continue;

    final distKm = _distanciaKm(origem, destino);
    if (distKm < minDistKm) continue; // ignora corridas com ~0 km

    final ppk = valor / distKm; // preço por km dessa corrida
    precoPorKmTodas.add(ppk);

    final delta = (distKm - alvoKm).abs();
    if (delta <= alvoKm * toleranciaRelativa) {
      precoPorKmSemelhantes.add(ppk);
    }
  }

  // Se houver corridas com distância semelhante, usa a média delas.
  // Caso contrário, usa média geral como fallback.
  double _media(List<double> xs) =>
      xs.isEmpty ? 0.0 : xs.reduce((a, b) => a + b) / xs.length;

  final mediaPpkSemelhantes = _media(precoPorKmSemelhantes);
  final mediaPpkGeral = _media(precoPorKmTodas);

  final ppkUsado =
      mediaPpkSemelhantes > 0 ? mediaPpkSemelhantes : mediaPpkGeral;

  if (ppkUsado <= 0) return 0.0; // Sem dados suficientes

  // Estimativa final: preço médio por km * distância alvo
  return ppkUsado * alvoKm;
}
