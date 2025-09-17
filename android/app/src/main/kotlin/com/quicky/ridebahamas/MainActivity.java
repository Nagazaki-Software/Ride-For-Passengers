package com.quicky.ridebahamas;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformViewRegistry;
<<<<<<< HEAD
<<<<<<< HEAD
// Removed unused Braintree native channel imports
// (Flutter code uses flutter_braintree plugin directly.)
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

import com.braintreepayments.api.card.Card;
import com.braintreepayments.api.card.CardClient;
import com.braintreepayments.api.card.CardTokenizeCallback;
import com.braintreepayments.api.card.CardResult;
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    BinaryMessenger messenger = flutterEngine.getDartExecutor().getBinaryMessenger();
    PlatformViewRegistry registry = flutterEngine.getPlatformViewsController().getRegistry();
    registry.registerViewFactory(
        "picker_map_native",
        new PickerMapNativeFactory(messenger)
    );
<<<<<<< HEAD
<<<<<<< HEAD
  }
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be

    // Braintree native method channel (no Drop-in)
    new MethodChannel(messenger, "braintree_native").setMethodCallHandler(
        (MethodCall call, Result result) -> {
          if ("tokenizeCard".equals(call.method)) {
            tokenizeCard(call, result);
          } else if ("threeDSecureVerify".equals(call.method)) {
            // For SDK v5 on Android, the 3DS flow is multi-step and requires
            // launching an Activity/Contract. For now, return an explicit
            // unsupported error so Dart can proceed without 3DS (as coded).
            result.error("unsupported_3ds_android_v5", "3D Secure on Android SDK v5 requires activity flow; not wired yet", null);
          } else {
            result.notImplemented();
          }
        }
    );
  }

  private void tokenizeCard(MethodCall call, Result result) {
    String tokenizationKey = call.argument("tokenizationKey");
    String number = call.argument("number");
    String expirationMonth = call.argument("expirationMonth");
    String expirationYear = call.argument("expirationYear");
    String cvv = call.argument("cvv");
    String cardholderName = call.argument("cardholderName");

    if (tokenizationKey == null || tokenizationKey.trim().isEmpty()) {
      result.error("invalid_key", "tokenizationKey is required", null);
      return;
    }
    if (number == null || expirationMonth == null || expirationYear == null) {
      result.error("invalid_args", "Missing card fields", null);
      return;
    }

    // Braintree v5: use CardClient(Context, authorization)
    CardClient cardClient = new CardClient(this, tokenizationKey);
    Card card = new Card();
    card.setNumber(number);
    card.setExpirationMonth(expirationMonth);
    card.setExpirationYear(expirationYear);
    if (cvv != null) card.setCvv(cvv);
    if (cardholderName != null) card.setCardholderName(cardholderName);

    cardClient.tokenize(card, new CardTokenizeCallback() {
      @Override
      public void onCardResult(CardResult cardResult) {
        try {
          if (cardResult instanceof CardResult.Success) {
            CardResult.Success success = (CardResult.Success) cardResult;
            // Guessing method name getCardNonce(); adjust if API differs.
            com.braintreepayments.api.card.CardNonce cn;
            try {
              cn = (com.braintreepayments.api.card.CardNonce)
                  CardResult.Success.class.getMethod("getCardNonce").invoke(success);
            } catch (NoSuchMethodException nsme) {
              // Fallback: try method named getNonce()
              cn = (com.braintreepayments.api.card.CardNonce)
                  CardResult.Success.class.getMethod("getNonce").invoke(success);
            }
            if (cn == null) {
              result.success(null);
              return;
            }
            String nonce = cn.getString();
            String last4 = (number.length() >= 4) ? number.substring(number.length() - 4) : number;
            java.util.HashMap<String, Object> out = new java.util.HashMap<>();
            out.put("nonce", nonce);
            out.put("last4", last4);
            result.success(out);
          } else if (cardResult instanceof CardResult.Failure) {
            CardResult.Failure failure = (CardResult.Failure) cardResult;
            // Guessing getError() accessor is available on Failure
            Throwable err = null;
            try {
              err = (Throwable) CardResult.Failure.class.getMethod("getError").invoke(failure);
            } catch (Exception ignore) {}
            String msg = (err != null && err.getMessage() != null) ? err.getMessage() : "Tokenization failed";
            result.error("braintree_error", msg, null);
          } else {
            result.success(null);
          }
        } catch (Exception e) {
          result.error("braintree_error", e.getMessage(), null);
        }
      }
    });
  }

  // Note: 3DS verify not implemented for Android v5 here; handled above.
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
}
