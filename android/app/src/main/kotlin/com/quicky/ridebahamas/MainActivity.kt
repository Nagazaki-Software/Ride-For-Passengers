package com.quicky.ridebahamas

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Registra o PlatformView "picker_map_native"
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "picker_map_native",
                PickerMapNativeFactory(flutterEngine.dartExecutor.binaryMessenger)
            )
    }
}

/**
 * Factory local (no mesmo arquivo) para evitar "Unresolved reference".
 * Se você tiver um arquivo separado PickerMapNativeFactory.kt, APAGUE-O
 * para não duplicar a classe.
 */
private class PickerMapNativeFactory(
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<*, *> ?: emptyMap<String, Any>()
        // PickerMapNativeView deve existir em:
        // android/app/src/main/kotlin/com/quicky/ridebahamas/PickerMapNativeView.kt
        return PickerMapNativeView(context, viewId, messenger, params)
    }
}
