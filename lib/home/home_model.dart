import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home_widget.dart' show HomeWidget;
import 'package:flutter/material.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
  ///  Local state fields for this page.

  String? rideChoose;

  bool rideForConfirm = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - googlePlacesNearbyImportant] action in Home widget.
  List<dynamic>? locationPerto;
  // Stores action output result for [Custom Action - localGreetingAction] action in Home widget.
  String? fraseInicial;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - googlePlacesAutocomplete] action in TextField widget.
  List<dynamic>? googlemaps;
  // Stores action output result for [Custom Action - geocodeAddress] action in TextField widget.
  dynamic geolocatoraddress;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
