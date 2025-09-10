package com.quicky.ridebahamas

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import android.util.Log

class MainActivity : FlutterFragmentActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    Log.i("PickerMap", "MainActivity.configureFlutterEngine")
    flutterEngine.platformViewsController.registry.registerViewFactory(
      "picker_map_native",
      PickerMapNativeFactory(
        applicationContext,
        flutterEngine.dartExecutor.binaryMessenger
      )
    )
    Log.i("PickerMap", "Factory registrada: picker_map_native")
  }
}
