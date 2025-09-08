import Flutter
import UIKit
import GoogleMaps

class NativeGoogleMap: NSObject, FlutterPlatformView, GMSMapViewDelegate {
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
    mapView.delegate = self
    channel.invokeMethod("mapReady", arguments: nil)
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
            if let rotation = m["rotation"] as? Double {
              marker.rotation = rotation
            }
            if let bytes = m["icon"] as? FlutterStandardTypedData {
              marker.icon = UIImage(data: bytes.data)
              marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            }
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
        let color = (args["color"] as? NSNumber)?.intValue ?? 0xff4285F4
        poly.strokeColor = UIColor(rgb: UInt(color))
        poly.strokeWidth = CGFloat(args["width"] as? Double ?? 5.0)
        poly.map = mapView
      }
      result(nil)
    case "setPolygons":
      if let args = call.arguments as? [String: Any],
         let polys = args["polygons"] as? [[[Double]]] {
        for poly in polys {
          let path = GMSMutablePath()
          for p in poly { if p.count == 2 { path.add(CLLocationCoordinate2D(latitude: p[0], longitude: p[1])) } }
          let gPoly = GMSPolygon(path: path)
          let strokeColor = (args["strokeColor"] as? NSNumber)?.intValue ?? 0xff4285F4
          let fillColor = (args["fillColor"] as? NSNumber)?.intValue ?? 0x554285F4
          gPoly.strokeColor = UIColor(rgb: UInt(strokeColor))
          gPoly.fillColor = UIColor(rgb: UInt(fillColor))
          gPoly.strokeWidth = CGFloat(args["strokeWidth"] as? Double ?? 1.0)
          gPoly.map = mapView
        }
      }
      result(nil)
    case "setMapStyle":
      if let args = call.arguments as? [String: Any],
         let style = args["style"] as? String {
        _ = mapView.mapStyle(withJsonString: style)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - GMSMapViewDelegate
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    channel.invokeMethod("onTap", arguments: ["lat": coordinate.latitude, "lng": coordinate.longitude])
  }

  func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    channel.invokeMethod("onLongPress", arguments: ["lat": coordinate.latitude, "lng": coordinate.longitude])
  }
}

private extension UIColor {
  convenience init(rgb: UInt) {
    self.init(
      red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
      green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
      blue: CGFloat(rgb & 0xFF) / 255.0,
      alpha: 1.0)
  }
}
