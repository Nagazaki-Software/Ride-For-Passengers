package com.quicky.ridebahamas

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.Log

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    Log.d("PickerMap", "Registrando view factory…")
    flutterEngine
      .platformViewsController
      .registry
      .registerViewFactory(
        "picker_map_native",
        PickerMapNativeFactory(flutterEngine.dartExecutor.binaryMessenger)
      )
  }
}
