import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'navbar_model.dart';
export 'navbar_model.dart';

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({super.key});

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  late NavbarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: double.infinity,
      height: 60.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 5.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlutterFlowIconButton(
              borderRadius: 8.0,
              buttonSize: 40.0,
              icon: FaIcon(
                FontAwesomeIcons.gift,
                color: FFAppState().pagesNavBar == 'rewards'
                    ? FlutterFlowTheme.of(context).accent1
                    : FlutterFlowTheme.of(context).alternate,
                size: 24.0,
              ),
              onPressed: () async {
                FFAppState().pagesNavBar = 'rewards';
                safeSetState(() {});

                context.goNamed(
                  Rewards13Widget.routeName,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );
              },
            ),
            FlutterFlowIconButton(
              borderRadius: 8.0,
              buttonSize: 40.0,
              icon: FaIcon(
                FontAwesomeIcons.calendarDay,
                color: FFAppState().pagesNavBar == 'calendar'
                    ? FlutterFlowTheme.of(context).accent1
                    : FlutterFlowTheme.of(context).alternate,
                size: 24.0,
              ),
              onPressed: () async {
                FFAppState().pagesNavBar = 'calendar';
                safeSetState(() {});

                context.goNamed(
                  ScheduleRide14Widget.routeName,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );
              },
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                FFAppState().pagesNavBar = 'home';
                safeSetState(() {});

                context.goNamed(
                  Home5Widget.routeName,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );
              },
              child: Container(
                width: 50.0,
                height: 50.0,
                child: Stack(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  children: [
                    FlutterFlowIconButton(
                      borderRadius: 8.0,
                      buttonSize: 40.0,
                      icon: FaIcon(
                        FontAwesomeIcons.mapMarker,
                        color: FFAppState().pagesNavBar == 'home'
                            ? FlutterFlowTheme.of(context).accent1
                            : FlutterFlowTheme.of(context).alternate,
                        size: 24.0,
                      ),
                      onPressed: () {
                        print('IconButton pressed ...');
                      },
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: Image.asset(
                          'assets/images/ChatGPT_Image_21_de_ago._de_2025,_11_59_29.png',
                          width: 20.0,
                          height: 25.0,
                          fit: BoxFit.cover,
                          alignment: Alignment(0.0, 0.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FlutterFlowIconButton(
              borderRadius: 8.0,
              buttonSize: 40.0,
              icon: FaIcon(
                FontAwesomeIcons.fileInvoice,
                color: FFAppState().pagesNavBar == 'activity'
                    ? FlutterFlowTheme.of(context).accent1
                    : FlutterFlowTheme.of(context).alternate,
                size: 24.0,
              ),
              onPressed: () async {
                FFAppState().pagesNavBar = 'activity';
                safeSetState(() {});

                context.goNamed(
                  Activity20Widget.routeName,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );
              },
            ),
            FlutterFlowIconButton(
              borderRadius: 8.0,
              buttonSize: 40.0,
              icon: FaIcon(
                FontAwesomeIcons.solidUserCircle,
                color: FFAppState().pagesNavBar == 'profile'
                    ? FlutterFlowTheme.of(context).accent1
                    : FlutterFlowTheme.of(context).alternate,
                size: 24.0,
              ),
              onPressed: () async {
                FFAppState().pagesNavBar = 'profile';
                safeSetState(() {});

                context.goNamed(
                  Profile15Widget.routeName,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );
              },
            ),
          ].divide(SizedBox(width: 14.0)).around(SizedBox(width: 14.0)),
        ),
      ),
    );
  }
}
