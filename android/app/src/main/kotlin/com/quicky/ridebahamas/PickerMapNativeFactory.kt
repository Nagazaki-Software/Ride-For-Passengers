// android/app/src/main/kotlin/com/quicky/ridebahamas/PickerMapNativeFactory.kt
package com.quicky.ridebahamas

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class PickerMapNativeFactory(private val messenger: BinaryMessenger) :
  PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  override fun create(context: Context, id: Int, obj: Any?): PlatformView {
    // Se quiser ler creationParams, estão em `obj`, mas seu Dart manda só initialUserLocation para uso na view
    return PickerMapNativeView(context, messenger, id)
  }
}
