import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home5_widget.dart' show Home5Widget;
import 'package:flutter/material.dart';

class Home5Model extends FlutterFlowModel<Home5Widget> {
  ///  Local state fields for this page.

  String? rideChoose;

  bool rideForConfirm = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - googlePlacesNearbyImportant] action in Home5 widget.
  List<dynamic>? locationPerto;
  // Stores action output result for [Custom Action - localGreetingAction] action in Home5 widget.
  String? fraseInicial;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - googlePlacesAutocomplete] action in TextField widget.
  List<dynamic>? googlemaps;
  // Stores action output result for [Custom Action - geocodeAddress] action in TextField widget.
  dynamic geolocatoraddress;
  // Stores action output result for [Custom Action - geocodeAddress] action in Container widget.
  dynamic geolocatoraddressonchoose;
  // Stores action output result for [Custom Action - geocodeAddress] action in Container widget.
  dynamic geolocatoraddressontap;
  // Model for navbar component.
  late NavbarModel navbarModel;

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();

    navbarModel.dispose();
  }
}
