package com.quicky.ridebahamas;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

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
    @SuppressWarnings("rawtypes")
    public PlatformView create(@NonNull Context context, int viewId, @Nullable Object args) {
        Map creationParams = args instanceof Map ? (Map) args : null;
        return new PickerMapNativeView(context, viewId, messenger, creationParams);
    }
}
