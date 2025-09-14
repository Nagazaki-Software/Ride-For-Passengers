import Foundation
import GoogleMaps
import Flutter

final class PickerMapNativeView: NSObject, FlutterPlatformView {

    private let channel: FlutterMethodChannel
    private let mapView: GMSMapView

    private var genericMarkers: [GMSMarker] = []
    private var carMarkers: [String: GMSMarker] = [:]
    private var polylines: [String: GMSPolyline] = [:]
    private var polygons: [String: GMSPolygon] = [:]

    init(frame: CGRect,
         viewIdentifier viewId: Int64,
         arguments args: Any?,
         binaryMessenger messenger: FlutterBinaryMessenger) {

        self.channel = FlutterMethodChannel(name: "picker_map_native/\(viewId)", binaryMessenger: messenger)

        // Camera inicial (fallback = SP/RJ just in case)
        var camera = GMSCameraPosition(latitude: -23.5505, longitude: -46.6333, zoom: 14, bearing: 0, viewingAngle: 0)

        if let dict = args as? [String: Any] {
            let lat = Self.asDouble(dict["initialLat"])
            let lng = Self.asDouble(dict["initialLng"])
            let zoom = Self.asFloat(dict["initialZoom"]) ?? 15
            let bearing = Self.asFloat(dict["initialBearing"]) ?? 0
            let tilt = Self.asFloat(dict["initialTilt"]) ?? 0
            if let lat = lat, let lng = lng {
                camera = GMSCameraPosition(latitude: lat, longitude: lng, zoom: zoom, bearing: bearing, viewingAngle: tilt)
            } else {
                camera = GMSCameraPosition(latitude: -18.8639625, longitude: -41.9752148, zoom: zoom, bearing: bearing, viewingAngle: tilt)
            }
        }

        self.mapView = GMSMapView(frame: frame, camera: camera)
        super.init()

        applyDarkStyle()

        mapView.settings.compassButton = true
        mapView.settings.rotateGestures = true
        mapView.settings.tiltGestures = true
        mapView.settings.myLocationButton = false
        mapView.isMyLocationEnabled = false

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { result(nil); return }
            do {
                switch call.method {
                case "updateConfig":
                    let cfg = (call.arguments as? [String: Any]) ?? [:]
                    self.updateConfig(cfg)
                    result(nil)

                case "setMarkers":
                    let list = (call.arguments as? [[String: Any]]) ?? []
                    self.setMarkers(list)
                    result(nil)

                case "setPolylines":
                    let list = (call.arguments as? [[String: Any]]) ?? []
                    self.setPolylines(list)
                    result(nil)

                case "setPolygons":
                    let list = (call.arguments as? [[String: Any]]) ?? []
                    self.setPolygons(list)
                    result(nil)

                case "cameraTo":
                    let a = (call.arguments as? [String: Any]) ?? [:]
                    let lat = Self.asDouble(a["lat"])
                    let lng = Self.asDouble(a["lng"])
                    let zoom = Self.asFloat(a["zoom"]) ?? 16
                    let bearing = Self.asFloat(a["bearing"]) ?? 0
                    let tilt = Self.asFloat(a["tilt"]) ?? 0
                    if let lat = lat, let lng = lng {
                        self.cameraTo(lat: lat, lng: lng, zoom: zoom, bearing: bearing, tilt: tilt)
                    }
                    result(nil)

                case "fitBounds":
                    let a = (call.arguments as? [String: Any]) ?? [:]
                    let points = (a["points"] as? [[String: Any]]) ?? []
                    let padding = (a["padding"] as? NSNumber)?.doubleValue ?? 80
                    self.fitBounds(points: points, padding: padding)
                    result(nil)

                case "updateCarPosition":
                    let a = (call.arguments as? [String: Any]) ?? [:]
                    let id = (a["id"] as? String) ?? "car"
                    if let lat = Self.asDouble(a["lat"]), let lng = Self.asDouble(a["lng"]) {
                        let rotation = Self.asFloat(a["rotation"]) ?? 0
                        let duration = (a["duration"] as? NSNumber)?.doubleValue ?? 0.8
                        self.updateCarPosition(id: id, target: CLLocationCoordinate2D(latitude: lat, longitude: lng), rotation: rotation, duration: duration)
                    }
                    result(nil)

                default:
                    result(FlutterMethodNotImplemented)
                }
            } catch {
                result(FlutterError(code: "error", message: error.localizedDescription, details: nil))
            }
        }

        // Notifica o Dart que a plataforma está pronta (mesmo comportamento do Android)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.channel.invokeMethod("platformReady", arguments: nil)
        }
    }

    func view() -> UIView {
        return mapView
    }

    // MARK: - Métodos

    private func updateConfig(_ cfg: [String: Any]) {
        let showUser = Self.getBool(cfg, "user", def: true) || Self.getBool(cfg, "showUser", def: false)
        // Requer permissão de localização no app; se não tiver, o Maps apenas ignora.
        mapView.isMyLocationEnabled = showUser
        // (Você pode conectar um CLLocationManager se quiser controlar de fato as permissões.)
    }

    private func setMarkers(_ items: [[String: Any]]) {
        // Limpa os antigos
        genericMarkers.forEach { $0.map = nil }
        genericMarkers.removeAll()

        for it in items {
            guard let lat = Self.asDouble(it["lat"]),
                  let lng = Self.asDouble(it["lng"]) else { continue }

            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: lng))
            marker.title = it["title"] as? String
            if let hue = (it["hue"] as? NSNumber)?.floatValue {
                marker.icon = GMSMarker.markerImage(with: UIColor(hue: CGFloat(hue/360.0), saturation: 0.9, brightness: 0.9, alpha: 1.0))
            }
            marker.map = mapView
            genericMarkers.append(marker)
        }
    }

    private func setPolylines(_ items: [[String: Any]]) {
        var next: [String: GMSPolyline] = [:]

        for it in items {
            let id = (it["id"] as? String) ?? "pl_\(next.count)"
            let points = (it["points"] as? [[String: Any]]) ?? []
            guard !points.isEmpty else { continue }

            polylines[id]?.map = nil

            let path = GMSMutablePath()
            for p in points {
                if let lat = Self.asDouble(p["lat"]), let lng = Self.asDouble(p["lng"]) {
                    path.add(CLLocationCoordinate2D(latitude: lat, longitude: lng))
                }
            }

            let pl = GMSPolyline(path: path)
            let width = (it["width"] as? NSNumber)?.floatValue ?? 8
            let color = Self.parseColor((it["color"] as? String) ?? "#00E5FF", def: UIColor.cyan)
            pl.strokeWidth = CGFloat(width)
            pl.strokeColor = color
            pl.geodesic = true
            pl.map = mapView

            next[id] = pl
        }

        // remove os que não vieram
        for (k, old) in polylines where next[k] == nil { old.map = nil }
        polylines = next
    }

    private func setPolygons(_ items: [[String: Any]]) {
        var next: [String: GMSPolygon] = [:]

        for it in items {
            let id = (it["id"] as? String) ?? "pg_\(next.count)"
            let points = (it["points"] as? [[String: Any]]) ?? []
            guard !points.isEmpty else { continue }

            polygons[id]?.map = nil

            let path = GMSMutablePath()
            for p in points {
                if let lat = Self.asDouble(p["lat"]), let lng = Self.asDouble(p["lng"]) {
                    path.add(CLLocationCoordinate2D(latitude: lat, longitude: lng))
                }
            }

            let pg = GMSPolygon(path: path)
            let strokeColor = Self.parseColor((it["strokeColor"] as? String) ?? "#00E5FF", def: UIColor.cyan)
            let fillColor = Self.parseColor((it["fillColor"] as? String) ?? "#3300E5FF", def: UIColor.cyan.withAlphaComponent(0.2))
            let strokeWidth = (it["strokeWidth"] as? NSNumber)?.floatValue ?? 4

            pg.strokeColor = strokeColor
            pg.strokeWidth = CGFloat(strokeWidth)
            pg.fillColor = fillColor
            pg.map = mapView

            next[id] = pg
        }

        for (k, old) in polygons where next[k] == nil { old.map = nil }
        polygons = next
    }

    private func cameraTo(lat: Double, lng: Double, zoom: Float, bearing: Float, tilt: Float) {
        let cam = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                                    zoom: zoom, bearing: CLLocationDirection(bearing),
                                    viewingAngle: CLLocationDirection(tilt))
        mapView.animate(to: cam)
    }

    private func fitBounds(points: [[String: Any]], padding: Double) {
        var bounds = GMSCoordinateBounds()
        var hasPoint = false
        for p in points {
            if let lat = Self.asDouble(p["lat"]), let lng = Self.asDouble(p["lng"]) {
                bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: lng))
                hasPoint = true
            }
        }
        guard hasPoint else { return }
        let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(padding))
        mapView.animate(with: update)
    }

    private func updateCarPosition(id: String, target: CLLocationCoordinate2D, rotation: Float, duration: Double) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(max(0.1, duration))
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .linear))

        let marker: GMSMarker
        if let existing = carMarkers[id] {
            marker = existing
        } else {
            marker = GMSMarker(position: target)
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.isFlat = true
            marker.icon = GMSMarker.markerImage(with: .systemBlue)
            marker.map = mapView
            carMarkers[id] = marker
        }

        marker.rotation = CLLocationDirection(rotation)
        marker.position = target

        CATransaction.commit()
    }

    // MARK: - Dark Style

    private func applyDarkStyle() {
        let json = """
        [
          {"elementType":"geometry","stylers":[{"color":"#1d2c4d"}]},
          {"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},
          {"elementType":"labels.text.stroke","stylers":[{"color":"#1a3646"}]},
          {"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},
          {"featureType":"administrative.province","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},
          {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#023e58"}]},
          {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#283d6a"}]},
          {"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#023e58"}]},
          {"featureType":"road","elementType":"geometry","stylers":[{"color":"#304a7d"}]},
          {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2c6675"}]},
          {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e1626"}]}
        ]
        """
        if let style = try? GMSMapStyle(jsonString: json) {
            mapView.mapStyle = style
        }
    }

    // MARK: - Utils

    private static func asDouble(_ any: Any?) -> Double? {
        if let n = any as? NSNumber { return n.doubleValue }
        if let s = any as? String { return Double(s) }
        return nil
    }

    private static func asFloat(_ any: Any?) -> Float? {
        if let n = any as? NSNumber { return n.floatValue }
        if let s = any as? String { return Float(s) }
        return nil
    }

    private static func getBool(_ dict: [String: Any], _ key: String, def: Bool) -> Bool {
        if let b = dict[key] as? Bool { return b }
        if let s = dict[key] as? String { return (s as NSString).boolValue }
        return def
    }

    private static func parseColor(_ hex: String, def: UIColor) -> UIColor {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        func c(_ start: Int, _ len: Int) -> CGFloat {
            let st = s.index(s.startIndex, offsetBy: start)
            let en = s.index(st, offsetBy: len)
            let sub = String(s[st..<en])
            return CGFloat((UInt64(sub, radix: 16) ?? 0)) / 255.0
        }
        switch s.count {
        case 6: return UIColor(red: c(0,2), green: c(2,2), blue: c(4,2), alpha: 1.0)
        case 8: return UIColor(red: c(2,2), green: c(4,2), blue: c(6,2), alpha: c(0,2))
        default: return def
        }
    }
}
