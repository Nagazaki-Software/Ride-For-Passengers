import UIKit
import Braintree

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
    if let registrar = self.registrar(forPlugin: "native-google-map") {
      registrar.register(NativeGoogleMapFactory(messenger: registrar.messenger()), withId: "native-google-map")
    }
    BTAppContextSwitcher.setReturnURLScheme("com.quicky.ridebahamas.braintree")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
