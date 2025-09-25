import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'how_drive_do12_model.dart';
export 'how_drive_do12_model.dart';

class HowDriveDo12Widget extends StatefulWidget {
  const HowDriveDo12Widget({super.key});

  static String routeName = 'HowDriveDo12';
  static String routePath = '/howDriveDo12';

  @override
  State<HowDriveDo12Widget> createState() => _HowDriveDo12WidgetState();
}

class _HowDriveDo12WidgetState extends State<HowDriveDo12Widget> {
  late HowDriveDo12Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HowDriveDo12Model());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'HowDriveDo12'});
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).tertiary,
        body: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/ChatGPT_Image_14_de_ago._de_2025,_13_29_15.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
          ],
        ),
      ),
    );
  }
}
