import Flutter
import UIKit

class PickerMapNativeFactory: NSObject, FlutterPlatformViewFactory {
  private var messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return PickerMapNativeView(
      frame: frame,
      viewId: viewId,
      messenger: messenger,
      args: args
    )
  }
}

