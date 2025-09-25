import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../flutter_flow/nav/nav.dart';

class RideStepNotifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _kRideNotifId = 1001;
  static const String _kRideChannelId = 'ride_status';
  static const String _kRideChannelName = 'Ride Status';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    // iOS: allow banners while app is foreground
    if (!kIsWeb && Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    const AndroidInitializationSettings initAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: initAndroid,
      iOS: initIOS,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload ?? '';
        if (payload.startsWith('rate:')) {
          // Open rating/review flow if available
          appNavigatorKey.currentState?.pushNamed('DriverReviews32');
        }
      },
    );

    // Create Android channel eagerly
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _kRideChannelId,
      _kRideChannelName,
      importance: Importance.max,
      description: 'Live ride status updates',
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    // Android 13+: require runtime permission to post notifications
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    _initialized = true;
  }

  static NotificationDetails _details({
    bool ongoing = false,
    bool alertOnce = true,
    String? bigText,
  }) {
    final style = bigText != null
        ? BigTextStyleInformation(bigText, htmlFormatBigText: false)
        : const DefaultStyleInformation(true, true);
    final android = AndroidNotificationDetails(
      _kRideChannelId,
      _kRideChannelName,
      channelDescription: 'Live ride status updates',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: ongoing,
      autoCancel: !ongoing,
      onlyAlertOnce: alertOnce,
      category: AndroidNotificationCategory.transport,
      styleInformation: style,
    );
    final ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return NotificationDetails(android: android, iOS: ios);
  }

  static Future<void> _show(String title, String body,
      {bool ongoing = false, String? payload, String? bigText}) async {
    await init();
    await _plugin.show(
      _kRideNotifId,
      title,
      body,
      _details(ongoing: ongoing, bigText: bigText ?? body),
      payload: payload,
    );
  }

  // Public helpers
  static Future<void> showFinding({String? rideNumber}) => _show(
        'Searching driver',
        rideNumber == null ? 'Looking for a nearby driver' : 'Ride #$rideNumber',
        ongoing: true,
      );

  static Future<void> showPickingYou({String? driver}) => _show(
        'Picking you',
        driver == null ? 'Driver on the way' : 'Driver $driver on the way',
        ongoing: true,
      );

  static Future<void> showInProgress({String? eta}) => _show(
        'Em viagem',
        eta == null ? 'Aproveite o trajeto' : 'Tempo restante: $eta',
        ongoing: true,
      );

  static Future<void> showFinished({String? total}) => _show(
        'Finish',
        total == null ? 'Avaliate ride' : 'Total $total — Avaliate ride',
        ongoing: false,
        payload: 'rate:now',
      );

  // Detailed variants used by PickingYou9 with ride id/valor/ETA
  static Future<void> showRidePickingDetail({
    required String title,
    required String body,
  }) => _show(title, body, ongoing: true, bigText: body);

  static Future<void> showRideInProgressDetail({
    required String title,
    required String body,
  }) => _show(title, body, ongoing: true, bigText: body);

  static Future<void> showRideFinishedDetail({
    required String title,
    required String body,
  }) => _show(title, body, ongoing: false, bigText: body, payload: 'rate:now');

  static Future<void> cancel() async {
    await _plugin.cancel(_kRideNotifId);
  }

  static Future<void> updateForMode(String mode) async {
    switch (mode) {
      case 'pickingyou':
        await showPickingYou();
        break;
      case 'progress':
        await showInProgress();
        break;
      case 'finish':
        await showFinished();
        break;
      default:
        break;
    }
  }
}



