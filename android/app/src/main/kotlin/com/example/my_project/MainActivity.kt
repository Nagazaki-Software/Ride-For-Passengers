package com.quicky.ridebahamas

import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// Braintree Android SDK
import com.braintreepayments.api.BraintreeClient
import com.braintreepayments.api.Card
import com.braintreepayments.api.CardClient
import com.braintreepayments.api.CardNonce
// v4 API uses Card object tokenization
import com.braintreepayments.api.PayPalClient
import com.braintreepayments.api.PayPalCheckoutRequest
import com.braintreepayments.api.GooglePayClient
import com.braintreepayments.api.GooglePayRequest

class MainActivity: FlutterFragmentActivity() {

    private val channelName = "com.quicky.ridebahamas/braintree"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    "tokenizeCard" -> handleTokenizeCard(call, result)
                    "paypalCheckout" -> handlePayPalCheckout(call, result)
                    "googlePay" -> handleGooglePay(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun braintreeClient(auth: String): BraintreeClient {
        return BraintreeClient(this, auth)
    }

    private fun handleTokenizeCard(call: MethodCall, result: MethodChannel.Result) {
        val auth = call.argument<String>("authorization") ?: return result.error("arg", "authorization required", null)
        val number = call.argument<String>("number") ?: return result.error("arg", "number required", null)
        val expirationMonth = call.argument<String>("expirationMonth") ?: return result.error("arg", "expirationMonth required", null)
        val expirationYear = call.argument<String>("expirationYear") ?: return result.error("arg", "expirationYear required", null)
        val cvv = call.argument<String>("cvv")

        val client = braintreeClient(auth)
        val cardClient = CardClient(client)
        val card = Card()
            .number(number)
            .expirationMonth(expirationMonth)
            .expirationYear(expirationYear)
        if (!cvv.isNullOrBlank()) card.cvv(cvv)

        cardClient.tokenize(card) { cardNonce: CardNonce?, error: java.lang.Exception? ->
            if (error != null) {
                result.error("bt", error.message, null)
            } else if (cardNonce != null) {
                result.success(cardNonce.string)
            } else {
                result.success(null)
            }
        }
    }

    private fun handlePayPalCheckout(call: MethodCall, result: MethodChannel.Result) {
        val auth = call.argument<String>("authorization") ?: return result.error("arg", "authorization required", null)
        val amount = call.argument<String>("amount") ?: return result.error("arg", "amount required", null)
        val currencyCode = call.argument<String>("currencyCode") ?: "USD"

        val client = braintreeClient(auth)
        val payPalClient = PayPalClient(this, client)
        val request = PayPalCheckoutRequest(amount).apply {
            this.currencyCode = currencyCode
        }
        payPalClient.tokenizePayPalAccount(this, request) { nonce, error ->
            if (error != null) {
                result.error("bt", error.message, null)
            } else if (nonce != null) {
                result.success(nonce.string)
            } else {
                result.success(null)
            }
        }
    }

    private fun handleGooglePay(call: MethodCall, result: MethodChannel.Result) {
        val auth = call.argument<String>("authorization") ?: return result.error("arg", "authorization required", null)
        val amount = call.argument<String>("amount") ?: return result.error("arg", "amount required", null)
        val currencyCode = call.argument<String>("currencyCode") ?: "USD"

        val client = braintreeClient(auth)
        val googlePayClient = GooglePayClient(this, client)
        val request = GooglePayRequest().apply {
            this.amount = amount
            this.currencyCode = currencyCode
        }
        googlePayClient.requestPayment(this, request) { nonce, error ->
            if (error != null) {
                result.error("bt", error.message, null)
            } else if (nonce != null) {
                result.success(nonce.string)
            } else {
                result.success(null)
            }
        }
    }
}
