import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _locationStatus = prefs.getString('ff_locationStatus') ?? _locationStatus;
    });
    _safeInit(() {
      _currentLat = prefs.getDouble('ff_currentLat') ?? _currentLat;
    });
    _safeInit(() {
      _currentLng = prefs.getDouble('ff_currentLng') ?? _currentLng;
    });
    _safeInit(() {
      _locationTimestamp = prefs.containsKey('ff_locationTimestamp')
          ? DateTime.fromMillisecondsSinceEpoch(
              prefs.getInt('ff_locationTimestamp')!)
          : _locationTimestamp;
    });
    _safeInit(() {
      _fraseInicial = prefs.getString('ff_fraseInicial') ?? _fraseInicial;
    });
    _safeInit(() {
      _locationsPorPerto =
          prefs.getStringList('ff_locationsPorPerto') ?? _locationsPorPerto;
    });
    _safeInit(() {
      _pagesNavBar = prefs.getString('ff_pagesNavBar') ?? _pagesNavBar;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _appVersion = '';
  String get appVersion => _appVersion;
  set appVersion(String value) {
    _appVersion = value;
  }

  String _locationStatus = 'idle';
  String get locationStatus => _locationStatus;
  set locationStatus(String value) {
    _locationStatus = value;
    prefs.setString('ff_locationStatus', value);
  }

  double _currentLat = 0.0;
  double get currentLat => _currentLat;
  set currentLat(double value) {
    _currentLat = value;
    prefs.setDouble('ff_currentLat', value);
  }

  double _currentLng = 0.0;
  double get currentLng => _currentLng;
  set currentLng(double value) {
    _currentLng = value;
    prefs.setDouble('ff_currentLng', value);
  }

  DateTime? _locationTimestamp =
      DateTime.fromMillisecondsSinceEpoch(1755633600000);
  DateTime? get locationTimestamp => _locationTimestamp;
  set locationTimestamp(DateTime? value) {
    _locationTimestamp = value;
    value != null
        ? prefs.setInt('ff_locationTimestamp', value.millisecondsSinceEpoch)
        : prefs.remove('ff_locationTimestamp');
  }

  String _fraseInicial = 'Welcome to Ride';
  String get fraseInicial => _fraseInicial;
  set fraseInicial(String value) {
    _fraseInicial = value;
    prefs.setString('ff_fraseInicial', value);
  }

  List<String> _locationsPorPerto = [];
  List<String> get locationsPorPerto => _locationsPorPerto;
  set locationsPorPerto(List<String> value) {
    _locationsPorPerto = value;
    prefs.setStringList('ff_locationsPorPerto', value);
  }

  void addToLocationsPorPerto(String value) {
    locationsPorPerto.add(value);
    prefs.setStringList('ff_locationsPorPerto', _locationsPorPerto);
  }

  void removeFromLocationsPorPerto(String value) {
    locationsPorPerto.remove(value);
    prefs.setStringList('ff_locationsPorPerto', _locationsPorPerto);
  }

  void removeAtIndexFromLocationsPorPerto(int index) {
    locationsPorPerto.removeAt(index);
    prefs.setStringList('ff_locationsPorPerto', _locationsPorPerto);
  }

  void updateLocationsPorPertoAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    locationsPorPerto[index] = updateFn(_locationsPorPerto[index]);
    prefs.setStringList('ff_locationsPorPerto', _locationsPorPerto);
  }

  void insertAtIndexInLocationsPorPerto(int index, String value) {
    locationsPorPerto.insert(index, value);
    prefs.setStringList('ff_locationsPorPerto', _locationsPorPerto);
  }

  String _pagesNavBar = 'home';
  String get pagesNavBar => _pagesNavBar;
  set pagesNavBar(String value) {
    _pagesNavBar = value;
    prefs.setString('ff_pagesNavBar', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
