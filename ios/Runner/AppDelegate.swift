import UIKit
import BraintreeCore

import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ")
    GeneratedPluginRegistrant.register(with: self)
    let controller = window?.rootViewController as! FlutterViewController
    let factory = PickerMapNativeFactory(messenger: controller.binaryMessenger)
    self.registrar(forPlugin: "PickerMapNative")?.register(factory, withId: "picker_map_native")
    BTAppContextSwitcher.setReturnURLScheme("com.quicky.ridebahamas.braintree")
    if let registrar = self.registrar(forPlugin: "BraintreeNativeChannel") {
      BraintreeNativeChannel.register(with: registrar)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Handle Braintree app switch returns (3DS/PayPal if any)
    if BTAppContextSwitcher.handleOpenURL(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
