import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'activity20_model.dart';
export 'activity20_model.dart';

class Activity20Widget extends StatefulWidget {
  const Activity20Widget({super.key});

  static String routeName = 'Activity20';
  static String routePath = '/activity20';

  @override
  State<Activity20Widget> createState() => _Activity20WidgetState();
}

class _Activity20WidgetState extends State<Activity20Widget> {
  late Activity20Model _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Activity20Model());
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
        backgroundColor: FlutterFlowTheme.of(context).primary,
        body: SafeArea(
          child: Center(
            child: Text(
              FFLocalizations.of(context).getText('65mjue8s' /* Activity */),
              style: FlutterFlowTheme.of(context).headlineMedium,
            ),
          ),
        ),
        bottomNavigationBar: const NavbarWidget(),
      ),
    );
  }
}

