import UIKit
import UserNotifications
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

    // Flutter <-> iOS native Braintree channel
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "com.quicky.ridebahamas/braintree", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        guard self != nil else {
          result(FlutterError(code: "unavailable", message: "AppDelegate released", details: nil))
          return
        }
        switch call.method {
        case "tokenizeCard":
          guard let args = call.arguments as? [String: Any],
                let authorization = args["authorization"] as? String,
                let number = args["number"] as? String,
                let expirationMonth = args["expirationMonth"] as? String,
                let expirationYear = args["expirationYear"] as? String else {
            result(FlutterError(code: "arg", message: "Missing required params", details: nil))
            return
          }
          let cvv = args["cvv"] as? String
          // iOS Braintree bridge disabled in this build; return unsupported
          result(FlutterError(code: "unsupported", message: "Braintree not implemented on iOS build", details: nil))

        case "paypalCheckout":
          guard let args = call.arguments as? [String: Any],
                let authorization = args["authorization"] as? String,
                let amount = args["amount"] as? String else {
            result(FlutterError(code: "arg", message: "Missing required params", details: nil))
            return
          }
          let currencyCode = (args["currencyCode"] as? String) ?? "USD"
          // iOS Braintree bridge disabled in this build; return unsupported
          result(FlutterError(code: "unsupported", message: "Braintree not implemented on iOS build", details: nil))

        case "googlePay":
          result(FlutterError(code: "unsupported", message: "Google Pay not supported on iOS", details: nil))

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    // Allow notifications to appear while app is in foreground on iOS
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    // Make sure APNs is registered so FCM can deliver notifications
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle app switch returns (PayPal, etc.)
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return super.application(app, open: url, options: options)
  }
}
