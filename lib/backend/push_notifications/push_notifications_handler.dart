import 'dart:async';

import 'serialization_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


final _handledMessageIds = <String?>{};

class PushNotificationsHandler extends StatefulWidget {
  const PushNotificationsHandler({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  _PushNotificationsHandlerState createState() =>
      _PushNotificationsHandlerState();
}

class _PushNotificationsHandlerState extends State<PushNotificationsHandler> {
  bool _loading = false;

  Future handleOpenedPushNotification() async {
    if (isWeb) {
      return;
    }

    final notification = await FirebaseMessaging.instance.getInitialMessage();
    if (notification != null) {
      await _handlePushNotification(notification);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushNotification);
  }

  Future _handlePushNotification(RemoteMessage message) async {
    if (_handledMessageIds.contains(message.messageId)) {
      return;
    }
    _handledMessageIds.add(message.messageId);

    safeSetState(() => _loading = true);
    try {
      final initialPageName = message.data['initialPageName'] as String;
      final initialParameterData = getInitialParameterData(message.data);
      final parametersBuilder = parametersBuilderMap[initialPageName];
      if (parametersBuilder != null) {
        final parameterData = await parametersBuilder(initialParameterData);
        if (mounted) {
          context.pushNamed(
            initialPageName,
            pathParameters: parameterData.pathParameters,
            extra: parameterData.extra,
          );
        } else {
          appNavigatorKey.currentContext?.pushNamed(
            initialPageName,
            pathParameters: parameterData.pathParameters,
            extra: parameterData.extra,
          );
        }
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      safeSetState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      handleOpenedPushNotification();
    });
  }

  @override
  Widget build(BuildContext context) => _loading
      ? Container(
          color: FlutterFlowTheme.of(context).primaryText,
          child: Image.asset(
            'assets/images/ChatGPT_Image_19_de_ago._de_2025,_10_05_00.png',
            fit: BoxFit.contain,
          ),
        )
      : widget.child;
}

class ParameterData {
  const ParameterData(
      {this.requiredParams = const {}, this.allParams = const {}});
  final Map<String, String?> requiredParams;
  final Map<String, dynamic> allParams;

  Map<String, String> get pathParameters => Map.fromEntries(
        requiredParams.entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
  Map<String, dynamic> get extra => Map.fromEntries(
        allParams.entries.where((e) => e.value != null),
      );

  static Future<ParameterData> Function(Map<String, dynamic>) none() =>
      (data) async => ParameterData();
}

final parametersBuilderMap =
    <String, Future<ParameterData> Function(Map<String, dynamic>)>{
  'GetStarted00': ParameterData.none(),
  'ContinueAs1': ParameterData.none(),
  'CreateProfile2': (data) async => ParameterData(
        allParams: {
          'quickyPlataform': getParameter<String>(data, 'quickyPlataform'),
        },
      ),
  'VerifyAccount3': (data) async => ParameterData(
        allParams: {
          'plataform': getParameter<String>(data, 'plataform'),
        },
      ),
  'Home5': ParameterData.none(),
  'ChoosePass4': ParameterData.none(),
  'RideShare6': ParameterData.none(),
  'PaymentRide7': (data) async => ParameterData(
        allParams: {
          'estilo': getParameter<String>(data, 'estilo'),
          'latlngAtual': getParameter<LatLng>(data, 'latlngAtual'),
          'latlngWhereTo': getParameter<LatLng>(data, 'latlngWhereTo'),
          'value': getParameter<double>(data, 'value'),
        },
      ),
  'FindingDrive8': (data) async => ParameterData(
        allParams: {
          'rideOrder': getParameter<DocumentReference>(data, 'rideOrder'),
        },
      ),
  'PickingYou9': (data) async => ParameterData(
        allParams: {
          'order': getParameter<DocumentReference>(data, 'order'),
        },
      ),
  'Login0': ParameterData.none(),
  'RideProgress10': ParameterData.none(),
  'RideProgressCopy11': ParameterData.none(),
  'HowDriveDo12': ParameterData.none(),
  'Rewards13': ParameterData.none(),
  'ScheduleRide14': ParameterData.none(),
  'Profile15': ParameterData.none(),
  'PaymentMothods16': ParameterData.none(),
  'Rewards17': ParameterData.none(),
  'Activity18': ParameterData.none(),
  'Preferences19': ParameterData.none(),
  'Activity20': ParameterData.none(),
  'SafetyToolkit21': ParameterData.none(),
  'Support22': ParameterData.none(),
  'Legal23': ParameterData.none(),
  'MyPass24': ParameterData.none(),
  'CreateProfile2Copy': (data) async => ParameterData(
        allParams: {
          'quickyPlataform': getParameter<String>(data, 'quickyPlataform'),
        },
      ),
  'viewDetalhes': (data) async => ParameterData(
        allParams: {
          'order': getParameter<DocumentReference>(data, 'order'),
        },
      ),
  'Support22Copy': ParameterData.none(),
  'Notification27': ParameterData.none(),
  'help': ParameterData.none(),
  'CustomerSupport26': ParameterData.none(),
  'FrequentlyAskedQuestions25': ParameterData.none(),
  'Reportaproblem28': ParameterData.none(),
  'chatSupport': (data) async => ParameterData(
        allParams: {
          'chat': getParameter<DocumentReference>(data, 'chat'),
        },
      ),
  'PrivacyPolicy29': ParameterData.none(),
  'TermsofService30': ParameterData.none(),
  'Licenses31': ParameterData.none(),
  'a1': ParameterData.none(),
};

Map<String, dynamic> getInitialParameterData(Map<String, dynamic> data) {
  try {
    final parameterDataStr = data['parameterData'];
    if (parameterDataStr == null ||
        parameterDataStr is! String ||
        parameterDataStr.isEmpty) {
      return {};
    }
    return jsonDecode(parameterDataStr) as Map<String, dynamic>;
  } catch (e) {
    print('Error parsing parameter data: $e');
    return {};
  }
}
