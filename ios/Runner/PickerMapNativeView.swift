import Flutter
import UIKit
import GoogleMaps

class PickerMapNativeView: NSObject, FlutterPlatformView {
  private var mapView: GMSMapView
  private var channel: FlutterMethodChannel

  init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
    mapView = GMSMapView(frame: frame)
    channel = FlutterMethodChannel(name: "picker_map_native_\(viewId)", binaryMessenger: messenger)
    super.init()
    mapView.settings.compassButton = false
    mapView.settings.myLocationButton = false
    mapView.delegate = self
    channel.setMethodCallHandler(handle)
  }

  func view() -> UIView {
    return mapView
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "updateConfig" {
      if let dict = call.arguments as? [String: Any],
         let user = dict["userLocation"] as? [String: Any],
         let lat = user["latitude"] as? Double,
         let lng = user["longitude"] as? Double {
        let camera = GMSCameraPosition(latitude: lat, longitude: lng, zoom: 14)
        mapView.camera = camera
      }
      result(nil)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}

extension PickerMapNativeView: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    channel.invokeMethod("onTap", arguments: [
      "latitude": coordinate.latitude,
      "longitude": coordinate.longitude,
    ])
  }

  func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    channel.invokeMethod("onLongPress", arguments: [
      "latitude": coordinate.latitude,
      "longitude": coordinate.longitude,
    ])
  }
}

