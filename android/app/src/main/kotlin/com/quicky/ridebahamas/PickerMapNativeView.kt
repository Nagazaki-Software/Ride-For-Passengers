package com.quicky.ridebahamas

import android.content.Context
import android.view.View
import com.google.android.gms.maps.*
import com.google.android.gms.maps.model.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class PickerMapNativeView(
  context: Context,
  messenger: BinaryMessenger,
  id: Int,
  private val creationParams: Map<String, Any?>
) : PlatformView, OnMapReadyCallback, MethodChannel.MethodCallHandler {

  private val channel = MethodChannel(messenger, "picker_map_native_$id")
  private val mapView = MapView(context)
  private var gmap: GoogleMap? = null

  init {
    channel.setMethodCallHandler(this)
    try { MapsInitializer.initialize(context, MapsInitializer.Renderer.LATEST){} } catch (_: Throwable) {}
    mapView.onCreate(null); mapView.onStart(); mapView.onResume()
    mapView.getMapAsync(this)
  }

  override fun getView(): View = mapView

  override fun dispose() {
    channel.setMethodCallHandler(null)
    mapView.onPause(); mapView.onStop(); mapView.onDestroy()
  }

  override fun onMapReady(map: GoogleMap) {
    gmap = map
    val init = creationParams["initialUserLocation"] as? Map<*, *>
    val lat = (init?.get("latitude") as? Number)?.toDouble()
    val lng = (init?.get("longitude") as? Number)?.toDouble()
    if (lat != null && lng != null) {
      val ll = LatLng(lat, lng)
      gmap?.moveCamera(CameraUpdateFactory.newLatLngZoom(ll, 14f))
      gmap?.addMarker(MarkerOptions().position(ll).title("You"))
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "updateConfig" -> {
        val cfg = call.arguments as Map<*, *>
        val dest = (cfg["destination"] as? Map<*, *>)?.let {
          val la = (it["latitude"] as? Number)?.toDouble()
          val lo = (it["longitude"] as? Number)?.toDouble()
          if (la != null && lo != null) LatLng(la, lo) else null
        }
        dest?.let { gmap?.addMarker(MarkerOptions().position(it).title("Destination")) }
        result.success(null)
      }
      "cameraTo" -> {
        val a = call.arguments as Map<*, *>
        val la = (a["latitude"] as Number).toDouble()
        val lo = (a["longitude"] as Number).toDouble()
        val zoom = (a["zoom"] as? Number)?.toFloat()
        val u = if (zoom != null) CameraUpdateFactory.newLatLngZoom(LatLng(la, lo), zoom)
                else CameraUpdateFactory.newLatLng(LatLng(la, lo))
        gmap?.animateCamera(u); result.success(null)
      }
      "fitBounds" -> {
        val a = call.arguments as Map<*, *>
        val pts = (a["points"] as? List<*>)?.mapNotNull {
          val m = it as? Map<*, *>
          val la = (m?.get("latitude") as? Number)?.toDouble()
          val lo = (m?.get("longitude") as? Number)?.toDouble()
          if (la != null && lo != null) LatLng(la, lo) else null
        } ?: emptyList()
        val pad = ((a["padding"] as? Number)?.toInt()) ?: 0
        if (pts.isNotEmpty()) {
          val b = LatLngBounds.builder(); pts.forEach { b.include(it) }
          gmap?.animateCamera(CameraUpdateFactory.newLatLngBounds(b.build(), pad))
        }
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }
}
