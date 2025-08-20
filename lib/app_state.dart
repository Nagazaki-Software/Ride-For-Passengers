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
