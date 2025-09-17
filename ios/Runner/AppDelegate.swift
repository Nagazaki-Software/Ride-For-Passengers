import UIKit
<<<<<<< HEAD
<<<<<<< HEAD
import Braintree
=======
import BraintreeCore
>>>>>>> 10c9b5c (new frkdfm)
=======
import BraintreeCore
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be

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
<<<<<<< HEAD
<<<<<<< HEAD
=======
    if let registrar = self.registrar(forPlugin: "BraintreeNativeChannel") {
      BraintreeNativeChannel.register(with: registrar)
    }
>>>>>>> 10c9b5c (new frkdfm)
=======
    if let registrar = self.registrar(forPlugin: "BraintreeNativeChannel") {
      BraintreeNativeChannel.register(with: registrar)
    }
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
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
