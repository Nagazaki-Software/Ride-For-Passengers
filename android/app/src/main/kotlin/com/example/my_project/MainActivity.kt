package com.quicky.ridebahamas

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "native-google-map",
            NativeGoogleMapFactory(flutterEngine.dartExecutor.binaryMessenger)
        )
    }
}
