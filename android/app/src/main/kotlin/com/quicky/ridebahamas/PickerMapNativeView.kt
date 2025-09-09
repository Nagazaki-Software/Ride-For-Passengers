package com.quicky.ridebahamas

import android.content.Context
import android.view.View
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.LatLng
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class PickerMapNativeView(context: Context, messenger: BinaryMessenger, id: Int) :
    PlatformView, MethodChannel.MethodCallHandler, OnMapReadyCallback {

  private val mapView: MapView = MapView(context)
  private var map: GoogleMap? = null
  private val channel = MethodChannel(messenger, "picker_map_native_$id")

  init {
    mapView.onCreate(null)
    mapView.onResume()
    mapView.getMapAsync(this)
    channel.setMethodCallHandler(this)
  }

  override fun getView(): View = mapView

  override fun dispose() {
    mapView.onDestroy()
  }

  override fun onMapReady(googleMap: GoogleMap) {
    map = googleMap
    googleMap.uiSettings.isMapToolbarEnabled = false
    googleMap.uiSettings.isZoomControlsEnabled = false
    googleMap.uiSettings.isMyLocationButtonEnabled = false
    googleMap.setOnMapClickListener {
      channel.invokeMethod(
          "onTap", mapOf("latitude" to it.latitude, "longitude" to it.longitude))
    }
    googleMap.setOnMapLongClickListener {
      channel.invokeMethod(
          "onLongPress", mapOf("latitude" to it.latitude, "longitude" to it.longitude))
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "updateConfig" -> {
        val args = call.arguments as Map<*, *>
        val user = args["userLocation"] as Map<*, *>
        val lat = user["latitude"] as Double
        val lng = user["longitude"] as Double
        map?.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), 14f))
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }
}

