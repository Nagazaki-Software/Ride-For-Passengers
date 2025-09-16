import Foundation
import Flutter

final class PickerMapNativeFactory: NSObject, FlutterPlatformViewFactory {

    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect,
                viewIdentifier viewId: Int64,
                arguments args: Any?) -> FlutterPlatformView {
        return PickerMapNativeView(frame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
    }
}
