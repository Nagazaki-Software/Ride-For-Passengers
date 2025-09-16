import Foundation
import Flutter
import BraintreeCore
import BraintreeCard
import BraintreeThreeDSecure

final class BraintreeNativeChannel: NSObject {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "braintree_native", binaryMessenger: registrar.messenger())

    channel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "tokenizeCard":
        guard let args = call.arguments as? [String: Any] else {
          result(FlutterError(code: "invalid_args", message: "Arguments must be a map", details: nil))
          return
        }
        guard let tokenizationKey = args["tokenizationKey"] as? String,
              let number = args["number"] as? String,
              let expirationMonth = args["expirationMonth"] as? String,
              let expirationYear = args["expirationYear"] as? String else {
          result(FlutterError(code: "invalid_args", message: "Missing card fields", details: nil))
          return
        }
        let cvv = args["cvv"] as? String
        let cardholderName = args["cardholderName"] as? String

        guard let apiClient = BTAPIClient(authorization: tokenizationKey) else {
          result(FlutterError(code: "invalid_key", message: "Invalid tokenization key", details: nil))
          return
        }

        let cardClient = BTCardClient(apiClient: apiClient)
        let card = BTCard(number: number, expirationMonth: expirationMonth, expirationYear: expirationYear, cvv: cvv)
        if let name = cardholderName { card.cardholderName = name }

        cardClient.tokenizeCard(card) { (cardNonce, error) in
          if let error = error {
            result(FlutterError(code: "braintree_error", message: error.localizedDescription, details: nil))
            return
          }
          guard let cardNonce = cardNonce else {
            result(nil)
            return
          }
          let last4 = number.count >= 4 ? String(number.suffix(4)) : number
          result(["nonce": cardNonce.nonce, "last4": last4])
        }

      case "threeDSecureVerify":
        guard let args = call.arguments as? [String: Any] else {
          result(FlutterError(code: "invalid_args", message: "Arguments must be a map", details: nil))
          return
        }
        guard let tokenizationKey = args["tokenizationKey"] as? String,
              let nonce = args["nonce"] as? String,
              let amountStr = args["amount"] as? String else {
          result(FlutterError(code: "invalid_args", message: "Missing nonce/amount", details: nil))
          return
        }
        let email = args["email"] as? String

        guard let apiClient = BTAPIClient(authorization: tokenizationKey) else {
          result(FlutterError(code: "invalid_key", message: "Invalid tokenization key", details: nil))
          return
        }

        let threeDSReq = BTThreeDSecureRequest()
        threeDSReq.nonce = nonce
        threeDSReq.amount = NSDecimalNumber(string: amountStr)
        threeDSReq.email = email
        threeDSReq.challengeRequested = true
        threeDSReq.versionRequested = .version2

        // Present from root Flutter VC
        guard let root = UIApplication.shared.keyWindow?.rootViewController ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
          result(FlutterError(code: "no_vc", message: "No rootViewController to present 3DS", details: nil))
          return
        }

        let driver = BTThreeDSecureDriver(apiClient: apiClient, viewControllerPresenting: root)
        driver.verify(with: threeDSReq) { threeDSResult, error in
          if let error = error {
            result(FlutterError(code: "three_d_secure_error", message: error.localizedDescription, details: nil))
            return
          }
          guard let threeDSResult = threeDSResult, let cardNonce = threeDSResult.tokenizedCard else {
            result(nil)
            return
          }
          let out: [String: Any] = [
            "nonce": cardNonce.nonce,
            "liabilityShifted": threeDSResult.liabilityShifted,
            "liabilityShiftPossible": threeDSResult.liabilityShiftPossible,
          ]
          result(out)
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
