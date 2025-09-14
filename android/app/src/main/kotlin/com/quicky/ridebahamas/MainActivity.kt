package com.quicky.ridebahamas

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // registra o PlatformView "picker_map_native"
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "picker_map_native",
                PickerMapNativeFactory(flutterEngine.dartExecutor.binaryMessenger)
            )
    }
}
