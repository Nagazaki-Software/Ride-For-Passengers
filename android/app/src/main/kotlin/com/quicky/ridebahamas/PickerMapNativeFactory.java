package com.quicky.ridebahamas;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class PickerMapNativeFactory extends PlatformViewFactory {

  private final BinaryMessenger messenger;

  public PickerMapNativeFactory(@NonNull BinaryMessenger messenger) {
    super(StandardMessageCodec.INSTANCE);
    this.messenger = messenger;
  }

  @Override
  public PlatformView create(@NonNull Context context, int viewId, @Nullable Object args) {
    return new PickerMapNativeView(context, messenger, viewId, args);
  }
}
