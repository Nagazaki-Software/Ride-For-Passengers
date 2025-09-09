import Flutter
import UIKit
import GoogleMaps

class PickerMapNativeView: NSObject, FlutterPlatformView {
  private var mapView: GMSMapView
  private var channel: FlutterMethodChannel
  private var userMarker: GMSMarker?
  private var destMarker: GMSMarker?
  private var routePolyline: GMSPolyline?
  private var driverMarkers: [String: GMSMarker] = [:]
  private var iconCache: [String: UIImage] = [:]

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
        let pos = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        mapView.camera = GMSCameraPosition(latitude: lat, longitude: lng, zoom: 14)

        let pad = dict["brandSafePaddingBottom"] as? Double ?? 0
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(pad), right: 0)
        if userMarker == nil {
          userMarker = GMSMarker(position: pos)
          userMarker?.icon = GMSMarker.markerImage(with: .blue)
          userMarker?.map = mapView
        }
        userMarker?.position = pos
        if let url = dict["userPhotoUrl"] as? String {
          loadIcon(url: url) { icon in
            if let icon = icon {
              self.userMarker?.icon = icon
            }
          }
        }

        if let dest = dict["destination"] as? [String: Any],
           let dlat = dest["latitude"] as? Double,
           let dlng = dest["longitude"] as? Double {
          let dpos = CLLocationCoordinate2D(latitude: dlat, longitude: dlng)
          if destMarker == nil {
            destMarker = GMSMarker(position: dpos)
            destMarker?.map = mapView
          }
          destMarker?.position = dpos
        } else {
          destMarker?.map = nil
          destMarker = nil
        }

        // drivers
        var existing = Set(driverMarkers.keys)
        if let drivers = dict["drivers"] as? [[String: Any]] {
          for d in drivers {
            let id = d["id"] as? String ?? UUID().uuidString
            let dlat = d["latitude"] as? Double ?? 0
            let dlng = d["longitude"] as? Double ?? 0
            let rot = d["rotation"] as? Double ?? 0
            let type = d["type"] as? String ?? "driver"
            let posD = CLLocationCoordinate2D(latitude: dlat, longitude: dlng)
            var marker = driverMarkers[id]
            if marker == nil {
              marker = GMSMarker(position: posD)
              marker!.map = mapView
              driverMarkers[id] = marker
              let iconUrl: String?
              if type == "taxi" {
                iconUrl = dict["driverTaxiIconUrl"] as? String
              } else {
                iconUrl = dict["driverDriverIconUrl"] as? String
              }
              let cacheKey = "\(type)_\(iconUrl ?? "")"
              if let icon = iconCache[cacheKey] {
                marker!.icon = icon
              } else if let url = iconUrl {
                loadIcon(url: url) { img in
                  if let img = img {
                    self.iconCache[cacheKey] = img
                    marker!.icon = img
                  }
                }
              }
            }
            marker!.position = posD
            marker!.rotation = rot
            existing.remove(id)
          }
        }
        for id in existing {
          driverMarkers[id]?.map = nil
          driverMarkers.removeValue(forKey: id)
        }

        // route
        if let route = dict["route"] as? [[String: Any]], route.count > 0 {
          var path = GMSMutablePath()
          for p in route {
            if let la = p["latitude"] as? Double, let lo = p["longitude"] as? Double {
              path.add(CLLocationCoordinate2D(latitude: la, longitude: lo))
            }
          }
          let colorInt = dict["routeColor"] as? Int ?? 0xFFFFC107
          let width = dict["routeWidth"] as? Int ?? 4
          if routePolyline == nil {
            routePolyline = GMSPolyline(path: path)
            routePolyline?.map = mapView
          } else {
            routePolyline?.path = path
          }
          routePolyline?.strokeWidth = CGFloat(width)
          routePolyline?.strokeColor = UIColor(
            red: CGFloat((colorInt >> 16) & 0xff) / 255.0,
            green: CGFloat((colorInt >> 8) & 0xff) / 255.0,
            blue: CGFloat(colorInt & 0xff) / 255.0,
            alpha: 1.0)
        } else {
          routePolyline?.map = nil
          routePolyline = nil
        }
      }
      result(nil)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func imageFromUrl(url: String) -> UIImage? {
    guard let u = URL(string: url), let data = try? Data(contentsOf: u) else {
      return nil
    }
    return UIImage(data: data)
  }

  private func loadIcon(url: String, completion: @escaping (UIImage?) -> Void) {
    if let cached = iconCache[url] {
      completion(cached)
      return
    }
    DispatchQueue.global().async {
      let img = self.imageFromUrl(url: url)
      if let img = img {
        self.iconCache[url] = img
      }
      DispatchQueue.main.async {
        completion(img)
      }
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

