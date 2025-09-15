package com.quicky.ridebahamas;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import java.util.Map;

public class PickerMapNativeFactory extends PlatformViewFactory {
  private final BinaryMessenger messenger;

  public PickerMapNativeFactory(BinaryMessenger messenger) {
    super(StandardMessageCodec.INSTANCE);
    this.messenger = messenger;
  }

  @Override
  public PlatformView create(@NonNull Context context, int viewId, @Nullable Object args) {
    @SuppressWarnings("unchecked")
    Map<String, Object> creationParams = args instanceof Map ? (Map<String, Object>) args : null;
    return new PickerMapNativeView(context, messenger, viewId, creationParams);
  }
}
