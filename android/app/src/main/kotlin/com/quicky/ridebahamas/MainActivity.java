package com.quicky.ridebahamas;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        flutterEngine
                .getPlatformViewsController()
                .getRegistry()
                .registerViewFactory(
                        "picker_map_native",
                        new PickerMapNativeFactory(flutterEngine.getDartExecutor().getBinaryMessenger())
                );
    }
}
