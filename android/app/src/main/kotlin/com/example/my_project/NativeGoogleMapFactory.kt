package com.quicky.ridebahamas

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeGoogleMapFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, obj: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = obj as? Map<String, Any>
        return NativeGoogleMap(context, messenger, id, params)
    }
}
