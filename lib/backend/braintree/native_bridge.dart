import 'package:flutter/services.dart';
import 'package:braintree_flutter_plus/braintree_flutter_plus.dart';
import 'payment_manager.dart';

class BraintreeNativeBridge {
  static const MethodChannel _ch = MethodChannel('com.quicky.ridebahamas/braintree');

  static Future<String?> tokenizeCard({
    required String authorization,
    required String number,
    required String expirationMonth,
    required String expirationYear,
    required String cvv,
    required String amount,
  }) async {
    final req = BraintreeCreditCardRequest(
      cardNumber: number,
      expirationMonth: expirationMonth,
      expirationYear: expirationYear,
      cvv: cvv,
      amount: amount,
    );
    final result = await Braintree.tokenizeCreditCard(authorization, req);
    return result?.nonce;
  }

  static Future<String?> paypalCheckout({
    required String authorization,
    required String amount,
    String currencyCode = 'USD',
  }) async {
    final request = BraintreePayPalRequest(amount: amount);
    final result = await Braintree.requestPaypalNonce(authorization, request);
    return result?.nonce;
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

  static Future<String?> applePay({
    required String authorization,
    required String amount,
    String currencyCode = 'USD',
    String countryCode = 'US',
    String? merchantIdentifier,
    String displayName = 'Ride Bahamas',
  }) async {
    final appleReq = BraintreeApplePayRequest(
      merchantIdentifier: merchantIdentifier ?? appleMerchantId(),
      displayName: displayName,
      currencyCode: currencyCode,
      countryCode: countryCode,
      supportedNetworks: const [
        ApplePaySupportedNetworks.visa,
        ApplePaySupportedNetworks.masterCard,
        ApplePaySupportedNetworks.amex,
        ApplePaySupportedNetworks.discover,
      ],
      paymentSummaryItems: [
        ApplePaySummaryItem(
          label: displayName,
          amount: double.tryParse(amount) ?? 0.0,
        ),
      ],
    );

    final dropInReq = BraintreeDropInRequest(
      clientToken: authorization,
      collectDeviceData: false,
      cardEnabled: false,
      applePayRequest: appleReq,
    );
    final result = await BraintreeDropIn.start(dropInReq);
    return result?.paymentMethodNonce.nonce;
  }
}
