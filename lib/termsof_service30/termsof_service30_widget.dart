import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'termsof_service30_model.dart';
export 'termsof_service30_model.dart';

/// Create a page Terms of Service
class TermsofService30Widget extends StatefulWidget {
  const TermsofService30Widget({super.key});

  static String routeName = 'TermsofService30';
  static String routePath = '/termsofService30';

  @override
  State<TermsofService30Widget> createState() => _TermsofService30WidgetState();
}

class _TermsofService30WidgetState extends State<TermsofService30Widget> {
  late TermsofService30Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TermsofService30Model());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'TermsofService30'});
    _model.expandableExpandableController1 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController2 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController3 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController4 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController5 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController6 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController7 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController8 =
        ExpandableController(initialExpanded: false);
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
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'TERMSOF_SERVICE30_Text_3alwwwqn_ON_TAP');
                        logFirebaseEvent('Text_navigate_back');
                        context.safePop();
                      },
                      child: Text(
                        FFLocalizations.of(context).getText(
                          'ra6hewkk' /* Terms of Service */,
                        ),
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                              color: FlutterFlowTheme.of(context).alternate,
                              fontSize: 22.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              lineHeight: 1.4,
                            ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF1B1B1C),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: double.infinity,
                                color: Color(0x00000000),
                                child: ExpandableNotifier(
                                  controller:
                                      _model.expandableExpandableController1,
                                  child: ExpandablePanel(
                                    header: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  8.0, 8.0, 0.0, 0.0),
                                          child: Text(
                                            FFLocalizations.of(context).getText(
                                              'ssubq09y' /* App Use */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 6.0)),
                                    ),
                                    collapsed: Container(),
                                    expanded: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'l3rbgns8' /* Use the app to request rides w... */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ),
                                    theme: ExpandableThemeData(
                                      tapHeaderToExpand: true,
                                      tapBodyToExpand: false,
                                      tapBodyToCollapse: false,
                                      headerAlignment:
                                          ExpandablePanelHeaderAlignment.top,
                                      hasIcon: true,
                                      expandIcon:
                                          Icons.keyboard_arrow_down_rounded,
                                      collapseIcon:
                                          Icons.keyboard_arrow_up_rounded,
                                      iconColor: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1.0,
                                thickness: 0.5,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              Container(
                                width: double.infinity,
                                color: Color(0x00000000),
                                child: ExpandableNotifier(
                                  controller:
                                      _model.expandableExpandableController2,
                                  child: ExpandablePanel(
                                    header: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  8.0, 8.0, 0.0, 0.0),
                                          child: Text(
                                            FFLocalizations.of(context).getText(
                                              'hyneyff1' /* Account & Eligibility */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    collapsed: Container(),
                                    expanded: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'xz7q5oqy' /* You must be 18+, provide accur... */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ),
                                    theme: ExpandableThemeData(
                                      tapHeaderToExpand: true,
                                      tapBodyToExpand: false,
                                      tapBodyToCollapse: false,
                                      headerAlignment:
                                          ExpandablePanelHeaderAlignment.top,
                                      hasIcon: true,
                                      expandIcon:
                                          Icons.keyboard_arrow_down_rounded,
                                      collapseIcon:
                                          Icons.keyboard_arrow_up_rounded,
                                      iconColor: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1.0,
                                thickness: 0.5,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              Container(
                                width: double.infinity,
                                color: Color(0x00000000),
                                child: ExpandableNotifier(
                                  controller:
                                      _model.expandableExpandableController3,
                                  child: ExpandablePanel(
                                    header: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'o49590hu' /* Rides & Fares */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                    collapsed: Container(),
                                    expanded: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'iq3q0eua' /* We show a fare estimate before... */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ),
                                    theme: ExpandableThemeData(
                                      tapHeaderToExpand: true,
                                      tapBodyToExpand: false,
                                      tapBodyToCollapse: false,
                                      headerAlignment:
                                          ExpandablePanelHeaderAlignment.top,
                                      hasIcon: true,
                                      expandIcon:
                                          Icons.keyboard_arrow_down_rounded,
                                      collapseIcon:
                                          Icons.keyboard_arrow_up_rounded,
                                      iconColor: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1.0,
                                thickness: 0.5,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              Container(
                                width: double.infinity,
                                color: Color(0x00000000),
                                child: ExpandableNotifier(
                                  controller:
                                      _model.expandableExpandableController4,
                                  child: ExpandablePanel(
                                    header: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'hd9a2nxr' /* Payments (Braintree) */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                    collapsed: Container(),
                                    expanded: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'e0hx8opo' /* We charge credit cards (Apple/... */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ),
                                    theme: ExpandableThemeData(
                                      tapHeaderToExpand: true,
                                      tapBodyToExpand: false,
                                      tapBodyToCollapse: false,
                                      headerAlignment:
                                          ExpandablePanelHeaderAlignment.top,
                                      hasIcon: true,
                                      expandIcon:
                                          Icons.keyboard_arrow_down_rounded,
                                      collapseIcon:
                                          Icons.keyboard_arrow_up_rounded,
                                      iconColor: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1.0,
                                thickness: 0.5,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              Container(
                                width: double.infinity,
                                color: Color(0x00000000),
                                child: ExpandableNotifier(
                                  controller:
                                      _model.expandableExpandableController5,
                                  child: ExpandablePanel(
                                    header: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          '1j9ju4dv' /* Cancellations & Refunds */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                    collapsed: Container(),
                                    expanded: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          '01ra7oy8' /* A fee may apply if the driver ... */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ),
                                    theme: ExpandableThemeData(
                                      tapHeaderToExpand: true,
                                      tapBodyToExpand: false,
                                      tapBodyToCollapse: false,
                                      headerAlignment:
                                          ExpandablePanelHeaderAlignment.top,
                                      hasIcon: true,
                                      expandIcon:
                                          Icons.keyboard_arrow_down_rounded,
                                      collapseIcon:
                                          Icons.keyboard_arrow_up_rounded,
                                      iconColor: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1.0,
                                thickness: 0.5,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              Container(
                                width: double.infinity,
                                color: Color(0x00000000),
                                child: ExpandableNotifier(
                                  controller:
                                      _model.expandableExpandableController6,
                                  child: ExpandablePanel(
                                    header: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          '1co4586b' /* Safety & Conduct */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                    collapsed: Container(),
                                    expanded: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'faa0m7y4' /* Trips have GPS tracking, a Saf... */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ),
                                    theme: ExpandableThemeData(
                                      tapHeaderToExpand: true,
                                      tapBodyToExpand: false,
                                      tapBodyToCollapse: false,
                                      headerAlignment:
                                          ExpandablePanelHeaderAlignment.top,
                                      hasIcon: true,
                                      expandIcon:
                                          Icons.keyboard_arrow_down_rounded,
                                      collapseIcon:
                                          Icons.keyboard_arrow_up_rounded,
                                      iconColor: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1.0,
                                thickness: 0.5,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              Container(
                                width: double.infinity,
                                color: Color(0x00000000),
                                child: ExpandableNotifier(
                                  controller:
                                      _model.expandableExpandableController7,
                                  child: ExpandablePanel(
                                    header: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          '49how4av' /* Data & Privacy */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                    collapsed: Container(),
                                    expanded: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'arxd0mls' /* We use your data to run the ap... */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ),
                                    theme: ExpandableThemeData(
                                      tapHeaderToExpand: true,
                                      tapBodyToExpand: false,
                                      tapBodyToCollapse: false,
                                      headerAlignment:
                                          ExpandablePanelHeaderAlignment.top,
                                      hasIcon: true,
                                      expandIcon:
                                          Icons.keyboard_arrow_down_rounded,
                                      collapseIcon:
                                          Icons.keyboard_arrow_up_rounded,
                                      iconColor: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1.0,
                                thickness: 0.5,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(),
                                child: Container(
                                  width: double.infinity,
                                  color: Color(0x00000000),
                                  child: ExpandableNotifier(
                                    controller:
                                        _model.expandableExpandableController8,
                                    child: ExpandablePanel(
                                      header: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8.0, 8.0, 0.0, 0.0),
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'yhjazte1' /* Liability */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                      collapsed: Container(),
                                      expanded: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 0.0),
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'e5vhmpdf' /* We’re not responsible for traf... */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ),
                                      theme: ExpandableThemeData(
                                        tapHeaderToExpand: true,
                                        tapBodyToExpand: false,
                                        tapBodyToCollapse: false,
                                        headerAlignment:
                                            ExpandablePanelHeaderAlignment.top,
                                        hasIcon: true,
                                        expandIcon:
                                            Icons.keyboard_arrow_down_rounded,
                                        collapseIcon:
                                            Icons.keyboard_arrow_up_rounded,
                                        iconColor: FlutterFlowTheme.of(context)
                                            .secondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(height: 8.0)),
                          ),
                        ),
                      ),
                    ),
                  ]
                      .divide(SizedBox(height: 20.0))
                      .addToEnd(SizedBox(height: 80.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
