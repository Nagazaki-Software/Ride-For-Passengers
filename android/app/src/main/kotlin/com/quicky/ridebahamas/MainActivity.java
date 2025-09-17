package com.quicky.ridebahamas;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformViewRegistry;
// Removed unused Braintree native channel imports
// (Flutter code uses flutter_braintree plugin directly.)

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
  }
}
