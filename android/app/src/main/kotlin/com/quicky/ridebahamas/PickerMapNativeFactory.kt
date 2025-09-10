package com.quicky.ridebahamas

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class PickerMapNativeFactory(
  private val appContext: Context,
  private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  override fun create(context: Context?, id: Int, args: Any?): PlatformView {
    @Suppress("UNCHECKED_CAST")
    val creationParams = args as? Map<String, Any?> ?: emptyMap()
    return PickerMapNativeView(appContext, messenger, id, creationParams)
  }
}
