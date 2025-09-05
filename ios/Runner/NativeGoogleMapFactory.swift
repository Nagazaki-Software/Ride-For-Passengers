import Flutter
import UIKit
import GoogleMaps

class NativeGoogleMapFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    return NativeGoogleMap(frame: frame, viewId: viewId, args: args as? [String: Any], messenger: messenger)
  }
}
