import UIKit
import UserNotifications
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
    BTAppContextSwitcher.setReturnURLScheme("com.quicky.ridebahamas.braintree")

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
          guard let apiClient = BTAPIClient(authorization: authorization) else {
            result(FlutterError(code: "bt", message: "Invalid authorization", details: nil))
            return
          }
          let cardClient = BTCardClient(apiClient: apiClient)
          let card = BTCard(number: number, expirationMonth: expirationMonth, expirationYear: expirationYear, cvv: cvv)
          cardClient.tokenize(card) { tokenized, error in
            if let e = error {
              result(FlutterError(code: "bt", message: e.localizedDescription, details: nil))
            } else {
              result(tokenized?.nonce)
            }
          }

        case "paypalCheckout":
          guard let args = call.arguments as? [String: Any],
                let authorization = args["authorization"] as? String,
                let amount = args["amount"] as? String else {
            result(FlutterError(code: "arg", message: "Missing required params", details: nil))
            return
          }
          let currencyCode = (args["currencyCode"] as? String) ?? "USD"
          guard let apiClient = BTAPIClient(authorization: authorization) else {
            result(FlutterError(code: "bt", message: "Invalid authorization", details: nil))
            return
          }
          let payPalDriver = BTPayPalDriver(apiClient: apiClient)
          let request = BTPayPalCheckoutRequest(amount: amount)
          request.currencyCode = currencyCode
          payPalDriver.tokenizePayPalAccount(with: request) { tokenized, error in
            if let e = error {
              result(FlutterError(code: "bt", message: e.localizedDescription, details: nil))
            } else {
              result(tokenized?.nonce)
            }
          }

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
    if url.scheme?.localizedCaseInsensitiveCompare("com.quicky.ridebahamas.braintree") == .orderedSame {
      return BTAppContextSwitcher.handleOpenURL(url)
    }
    return super.application(app, open: url, options: options)
  }
}
