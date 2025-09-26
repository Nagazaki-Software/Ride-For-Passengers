import 'package:flutter/services.dart';
import 'package:braintree_flutter_plus/braintree_flutter_plus.dart';

class BraintreeNativeBridge {
  static const MethodChannel _ch = MethodChannel('com.quicky.ridebahamas/braintree');

  static Future<String?> tokenizeCard({
    required String authorization,
    required String number,
    required String expirationMonth,
    required String expirationYear,
    String? cvv,
  }) async {
    final req = BraintreeCreditCardRequest(
      cardNumber: number,
      expirationMonth: expirationMonth,
      expirationYear: expirationYear,
      cvv: cvv,
    );
    final result = await Braintree.tokenizeCreditCard(authorization, req);
    return result.nonce;
  }

  static Future<String?> paypalCheckout({
    required String authorization,
    required String amount,
    String currencyCode = 'USD',
  }) async {
    final request = BraintreePayPalRequest(amount: amount);
    final result = await Braintree.requestPaypalNonce(authorization, request);
    return result.nonce;
  }

  static Future<String?> googlePay({
    required String authorization,
    required String amount,
    String currencyCode = 'USD',
  }) async {
    final dropInReq = BraintreeDropInRequest(
      clientToken: authorization,
      collectDeviceData: false,
      cardEnabled: false,
      googlePaymentRequest: BraintreeGooglePaymentRequest(
        totalPrice: amount,
        currencyCode: currencyCode,
        billingAddressRequired: false,
      ),
    );
    final result = await BraintreeDropIn.start(dropInReq);
    return result?.paymentMethodNonce.nonce;
  }
}
