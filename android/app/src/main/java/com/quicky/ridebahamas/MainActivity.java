package com.quicky.ridebahamas;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

// Braintree Android SDK v5
import com.braintreepayments.api.BraintreeClient;
import com.braintreepayments.api.CardClient;
import com.braintreepayments.api.CardNonce;
import com.braintreepayments.api.CardRequest;
import com.braintreepayments.api.CardTokenizeCallback;
import com.braintreepayments.api.PayPalAccountNonce;
import com.braintreepayments.api.PayPalCheckoutRequest;
import com.braintreepayments.api.PayPalClient;
import com.braintreepayments.api.PayPalTokenizeCallback;
import com.braintreepayments.api.GooglePayClient;
import com.braintreepayments.api.GooglePayRequest;
import com.braintreepayments.api.PaymentMethodNonce;
import com.braintreepayments.api.GooglePayRequestPaymentCallback;

public class MainActivity extends FlutterFragmentActivity {

  private static final String CHANNEL = "com.quicky.ridebahamas/braintree";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(this::handleMethodCall);
  }

  private BraintreeClient braintreeClient(String authorization) {
    return new BraintreeClient(this, authorization);
  }

  private void handleMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "tokenizeCard":
        handleTokenizeCard(call, result);
        break;
      case "paypalCheckout":
        handlePayPalCheckout(call, result);
        break;
      case "googlePay":
        handleGooglePay(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void handleTokenizeCard(MethodCall call, MethodChannel.Result result) {
    String authorization = call.argument("authorization");
    String number = call.argument("number");
    String expirationMonth = call.argument("expirationMonth");
    String expirationYear = call.argument("expirationYear");
    String cvv = call.argument("cvv");
    if (authorization == null || number == null || expirationMonth == null || expirationYear == null) {
      result.error("arg", "Missing required params", null);
      return;
    }

    BraintreeClient client = braintreeClient(authorization);
    CardClient cardClient = new CardClient(client);
    CardRequest request = new CardRequest()
        .cardNumber(number)
        .expirationMonth(expirationMonth)
        .expirationYear(expirationYear);
    if (cvv != null && !cvv.trim().isEmpty()) {
      request.cvv(cvv);
    }

    cardClient.tokenize(request, new CardTokenizeCallback() {
      @Override
      public void onResult(CardNonce cardNonce, Exception error) {
        if (error != null) {
          result.error("bt", error.getMessage(), null);
        } else if (cardNonce != null) {
          result.success(cardNonce.getString());
        } else {
          result.success(null);
        }
      }
    });
  }

  private void handlePayPalCheckout(MethodCall call, MethodChannel.Result result) {
    String authorization = call.argument("authorization");
    String amount = call.argument("amount");
    String currencyCode = call.argument("currencyCode");
    if (currencyCode == null) currencyCode = "USD";
    if (authorization == null || amount == null) {
      result.error("arg", "Missing required params", null);
      return;
    }

    BraintreeClient client = braintreeClient(authorization);
    PayPalClient payPalClient = new PayPalClient(this, client);
    PayPalCheckoutRequest request = new PayPalCheckoutRequest(amount);
    request.setCurrencyCode(currencyCode);

    payPalClient.tokenizePayPalAccount(this, request, new PayPalTokenizeCallback() {
      @Override
      public void onResult(PayPalAccountNonce nonce, Exception error) {
        if (error != null) {
          result.error("bt", error.getMessage(), null);
        } else if (nonce != null) {
          result.success(nonce.getString());
        } else {
          result.success(null);
        }
      }
    });
  }

  private void handleGooglePay(MethodCall call, MethodChannel.Result result) {
    String authorization = call.argument("authorization");
    String amount = call.argument("amount");
    String currencyCode = call.argument("currencyCode");
    if (currencyCode == null) currencyCode = "USD";
    if (authorization == null || amount == null) {
      result.error("arg", "Missing required params", null);
      return;
    }

    BraintreeClient client = braintreeClient(authorization);
    GooglePayClient googlePayClient = new GooglePayClient(this, client);
    GooglePayRequest request = new GooglePayRequest();
    request.setAmount(amount);
    request.setCurrencyCode(currencyCode);

    googlePayClient.requestPayment(this, request, new GooglePayRequestPaymentCallback() {
      @Override
      public void onResult(PaymentMethodNonce nonce, Exception error) {
        if (error != null) {
          result.error("bt", error.getMessage(), null);
        } else if (nonce != null) {
          result.success(nonce.getString());
        } else {
          result.success(null);
        }
      }
    });
  }
}

