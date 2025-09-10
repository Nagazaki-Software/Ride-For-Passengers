package com.quicky.ridebahamas

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.util.Log

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    Log.d("PickerMap", "MainActivity.configureFlutterEngine()")
    flutterEngine.platformViewsController.registry.registerViewFactory(
      "picker_map_native",
      PickerMapNativeFactory(
        applicationContext,
        flutterEngine.dartExecutor.binaryMessenger
      )
    )
    Log.d("PickerMap", "Factory registrada com viewType=picker_map_native")
  }
}
