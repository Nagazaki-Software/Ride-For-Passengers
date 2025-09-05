import Flutter
import UIKit
import GoogleMaps

class NativeGoogleMap: NSObject, FlutterPlatformView {
  private let mapView: GMSMapView
  private let channel: FlutterMethodChannel

  init(frame: CGRect, viewId: Int64, args: [String: Any]?, messenger: FlutterBinaryMessenger) {
    let lat = args?["lat"] as? Double ?? 0
    let lng = args?["lng"] as? Double ?? 0
    let zoom = args?["zoom"] as? Double ?? 14
    let camera = GMSCameraPosition(latitude: lat, longitude: lng, zoom: Float(zoom))
    mapView = GMSMapView(frame: frame, camera: camera)
    channel = FlutterMethodChannel(name: "native_google_map_\(viewId)" , binaryMessenger: messenger)
    super.init()
    channel.setMethodCallHandler(handle)
  }

  func view() -> UIView {
    return mapView
  }

  private func handle(_ call: FlutterMethodCall, result: FlutterResult) {
    switch call.method {
    case "moveCamera":
      if let args = call.arguments as? [String: Any],
         let lat = args["lat"] as? Double,
         let lng = args["lng"] as? Double,
         let zoom = args["zoom"] as? Double {
        let camera = GMSCameraPosition(latitude: lat, longitude: lng, zoom: Float(zoom))
        mapView.moveCamera(GMSCameraUpdate.setCamera(camera))
      }
      result(nil)
    case "setMarkers":
      mapView.clear()
      if let args = call.arguments as? [String: Any],
         let markers = args["markers"] as? [[String: Any]] {
        for m in markers {
          if let lat = m["lat"] as? Double, let lng = m["lng"] as? Double {
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: lng))
            marker.map = mapView
          }
        }
      }
      result(nil)
    case "setPolylines":
      if let args = call.arguments as? [String: Any],
         let pts = args["polyline"] as? [[Double]] {
        let path = GMSMutablePath()
        for p in pts {
          if p.count == 2 {
            path.add(CLLocationCoordinate2D(latitude: p[0], longitude: p[1]))
          }
        }
        let poly = GMSPolyline(path: path)
        poly.strokeColor = UIColor(red: 0.26, green: 0.52, blue: 0.96, alpha: 1.0)
        poly.strokeWidth = 5
        poly.map = mapView
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
