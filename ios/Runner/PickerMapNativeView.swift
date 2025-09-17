import Foundation
import GoogleMaps
import Flutter

<<<<<<< HEAD
<<<<<<< HEAD
final class PickerMapNativeView: NSObject, FlutterPlatformView {

    private let channel: FlutterMethodChannel
    private let mapView: GMSMapView

    private var genericMarkers: [GMSMarker] = []
    private var carMarkers: [String: GMSMarker] = [:]
    private var polylines: [String: GMSPolyline] = [:]
    private var polygons: [String: GMSPolygon] = [:]

=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
final class PickerMapNativeView: NSObject, FlutterPlatformView, GMSMapViewDelegate {

    private let channel: FlutterMethodChannel
    private let mapView: GMSMapView
    private let snapshotOverlay: UIImageView

    private var genericMarkers: [GMSMarker] = []
    private var carMarkers: [String: GMSMarker] = [:]
    private var pendingDriverPositions: [String: CLLocationCoordinate2D] = [:]
    private var polylines: [String: GMSPolyline] = [:]
    private var polygons: [String: GMSPolygon] = [:]

    // Snapshots cache
    private static var lastSnapshot: UIImage? = nil
    private var lastSnapshotTs: TimeInterval = 0

    private var driverIconImage: UIImage? = nil
    private var lastDriverIconSource: String? = nil

<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
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
<<<<<<< HEAD
<<<<<<< HEAD
        }

        self.mapView = GMSMapView(frame: frame, camera: camera)
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
            // Apply initial style and driver icon from creation params
            self.applyStyleAndDriverIcon(dict)
        }

        self.mapView = GMSMapView(frame: frame, camera: camera)
        self.snapshotOverlay = UIImageView(frame: .zero)
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
        super.init()

        applyDarkStyle()

        mapView.settings.compassButton = true
        mapView.settings.rotateGestures = true
        mapView.settings.tiltGestures = true
        mapView.settings.myLocationButton = false
        mapView.isMyLocationEnabled = false
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
        mapView.delegate = self

        // Overlay setup to reduce white flashes
        snapshotOverlay.contentMode = .scaleAspectFill
        snapshotOverlay.clipsToBounds = true
        snapshotOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        snapshotOverlay.frame = mapView.bounds
        snapshotOverlay.isHidden = (Self.lastSnapshot == nil)
        snapshotOverlay.image = Self.lastSnapshot
        mapView.addSubview(snapshotOverlay)
        mapView.backgroundColor = UIColor(red: 0x1D/255.0, green: 0x1F/255.0, blue: 0x25/255.0, alpha: 1)
        mapView.alpha = 0.0
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { result(nil); return }
            do {
                switch call.method {
                case "updateConfig":
                    let cfg = (call.arguments as? [String: Any]) ?? [:]
<<<<<<< HEAD
<<<<<<< HEAD
=======
                    self.applyStyleAndDriverIcon(cfg)
>>>>>>> 10c9b5c (new frkdfm)
=======
                    self.applyStyleAndDriverIcon(cfg)
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
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
<<<<<<< HEAD
<<<<<<< HEAD
                    let lat = Self.asDouble(a["lat"])
                    let lng = Self.asDouble(a["lng"])
=======
                    let lat = Self.asDouble(a["latitude"]) ?? Self.asDouble(a["lat"])
                    let lng = Self.asDouble(a["longitude"]) ?? Self.asDouble(a["lng"])
>>>>>>> 10c9b5c (new frkdfm)
=======
                    let lat = Self.asDouble(a["latitude"]) ?? Self.asDouble(a["lat"])
                    let lng = Self.asDouble(a["longitude"]) ?? Self.asDouble(a["lng"])
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
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
<<<<<<< HEAD
<<<<<<< HEAD
                    if let lat = Self.asDouble(a["lat"]), let lng = Self.asDouble(a["lng"]) {
                        let rotation = Self.asFloat(a["rotation"]) ?? 0
                        let duration = (a["duration"] as? NSNumber)?.doubleValue ?? 0.8
                        self.updateCarPosition(id: id, target: CLLocationCoordinate2D(latitude: lat, longitude: lng), rotation: rotation, duration: duration)
                    }
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
                    var target: CLLocationCoordinate2D? = nil
                    if let pos = a["position"] as? [String: Any], let la = Self.asDouble(pos["latitude"]), let lo = Self.asDouble(pos["longitude"]) {
                        target = CLLocationCoordinate2D(latitude: la, longitude: lo)
                    } else if let la = Self.asDouble(a["lat"]), let lo = Self.asDouble(a["lng"]) {
                        target = CLLocationCoordinate2D(latitude: la, longitude: lo)
                    }
                    let rotation = Self.asFloat(a["rotation"]) ?? 0
                    let duration = (a["durationMs"] as? NSNumber)?.doubleValue ?? ((a["duration"] as? NSNumber)?.doubleValue ?? 0.8)
                    if let tgt = target { self.updateCarPosition(id: id, target: tgt, rotation: rotation, duration: duration) }
                    result(nil)

                case "onResume":
                    if let img = Self.lastSnapshot {
                        self.snapshotOverlay.image = img
                        self.snapshotOverlay.isHidden = false
                    }
                    result(nil)

                case "onPause":
                    result(nil)

                case "onLowMemory":
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
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
<<<<<<< HEAD
<<<<<<< HEAD
        CATransaction.setAnimationDuration(max(0.1, duration))
=======
        CATransaction.setAnimationDuration(max(0.1, duration/1000.0))
>>>>>>> 10c9b5c (new frkdfm)
=======
        CATransaction.setAnimationDuration(max(0.1, duration/1000.0))
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .linear))

        let marker: GMSMarker
        if let existing = carMarkers[id] {
            marker = existing
        } else {
<<<<<<< HEAD
<<<<<<< HEAD
            marker = GMSMarker(position: target)
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.isFlat = true
            marker.icon = GMSMarker.markerImage(with: .systemBlue)
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
            if driverIconImage == nil {
                pendingDriverPositions[id] = target
                CATransaction.commit()
                return
            }
            marker = GMSMarker(position: target)
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.isFlat = true
            marker.icon = driverIconImage
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
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
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
    // Camera + overlay callbacks
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        channel.invokeMethod("cameraMoveStart", arguments: nil)
        if let img = Self.lastSnapshot {
            snapshotOverlay.image = img
            snapshotOverlay.isHidden = false
        }
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        channel.invokeMethod("cameraIdle", arguments: nil)
        // Update snapshot cache (throttled)
        let now = Date().timeIntervalSince1970
        if now - lastSnapshotTs > 1.2 {
            lastSnapshotTs = now
            Self.lastSnapshot = captureSnapshot()
        }
        snapshotOverlay.image = nil
        snapshotOverlay.isHidden = true
        if mapView.alpha < 1.0 { UIView.animate(withDuration: 0.2) { mapView.alpha = 1.0 } }
        // Also signal mapLoaded on first idle
        channel.invokeMethod("mapLoaded", arguments: nil)
    }

    private func applyStyleAndDriverIcon(_ cfg: [String: Any]) {
        if let styleJson = cfg["mapStyleJson"] as? String, !styleJson.isEmpty {
            if let style = try? GMSMapStyle(jsonString: styleJson) { mapView.mapStyle = style }
        }
        let taxiUrl = cfg["driverTaxiIconUrl"] as? String
        let driverUrl = cfg["driverDriverIconUrl"] as? String
        let chosen = (taxiUrl?.isEmpty == false) ? taxiUrl : driverUrl
        let iconW = (cfg["driverIconWidth"] as? NSNumber)?.intValue ?? 70
        if let src = chosen, !src!.isEmpty, src != lastDriverIconSource {
            lastDriverIconSource = src
            loadImage(from: src!, desiredWidth: iconW) { [weak self] img in
                guard let self = self, let img = img else { return }
                self.driverIconImage = img
                for m in self.carMarkers.values { m.icon = img }
                if !self.pendingDriverPositions.isEmpty {
                    for (id, pos) in self.pendingDriverPositions {
                        let m = GMSMarker(position: pos)
                        m.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                        m.isFlat = true
                        m.icon = img
                        m.map = self.mapView
                        self.carMarkers[id] = m
                    }
                    self.pendingDriverPositions.removeAll()
                }
            }
        }
    }

    private func captureSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(mapView.bounds.size, true, 0)
        defer { UIGraphicsEndImageContext() }
        if let ctx = UIGraphicsGetCurrentContext() {
            mapView.layer.render(in: ctx)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            return img
        }
        return nil
    }

    private func loadImage(from src: String, desiredWidth: Int, completion: @escaping (UIImage?) -> Void) {
        if src.hasPrefix("http") {
            guard let url = URL(string: src) else { completion(nil); return }
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let img = UIImage(data: data) else { DispatchQueue.main.async { completion(nil) }; return }
                let resized = self.resizeImage(img, toWidth: CGFloat(desiredWidth))
                DispatchQueue.main.async { completion(resized) }
            }.resume()
        } else {
            let path = src.hasPrefix("asset:") ? String(src.dropFirst(6)) : src
            let key = FlutterDartProject.lookupKey(forAsset: path)
            if let bundlePath = Bundle.main.path(forResource: key, ofType: nil, inDirectory: "flutter_assets"),
               let img = UIImage(contentsOfFile: bundlePath) {
                let resized = self.resizeImage(img, toWidth: CGFloat(desiredWidth))
                completion(resized)
            } else { completion(nil) }
        }
    }

    private func resizeImage(_ image: UIImage, toWidth width: CGFloat) -> UIImage? {
        let scale = width / max(1, image.size.width)
        let newSize = CGSize(width: max(1, image.size.width) * scale, height: max(1, image.size.height) * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be

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
