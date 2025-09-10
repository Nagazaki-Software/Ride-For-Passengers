package com.quicky.ridebahamas

import android.content.Context
import android.graphics.Color
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
  private val options = GoogleMapOptions().liteMode(
    (creationParams["liteModeOnAndroid"] as? Boolean) == true
  )
  private val mapView = MapView(context, options)
  private var gmap: GoogleMap? = null

  private var route: List<LatLng> = emptyList()
  private var user: LatLng? = null
  private var dest: LatLng? = null
  private var routeColor = Color.parseColor("#FFC107")
  private var routeWidth = 4f

  init {
    channel.setMethodCallHandler(this)
    try { MapsInitializer.initialize(context, MapsInitializer.Renderer.LATEST) { } } catch (_: Throwable) {}

    // CHAME o ciclo de vida – sem isso o mapa não aparece.
    mapView.onCreate(null)
    mapView.onStart()
    mapView.onResume()

    mapView.getMapAsync(this)
  }

  override fun getView(): View = mapView

  override fun dispose() {
    channel.setMethodCallHandler(null)
    mapView.onPause()
    mapView.onStop()
    mapView.onDestroy()
  }

  override fun onMapReady(map: GoogleMap) {
    gmap = map
    // posição inicial enviada do Flutter
    user = creationParams["initialUserLocation"].toLatLng()
    user?.let { gmap?.moveCamera(CameraUpdateFactory.newLatLngZoom(it, 14f)) }
    drawAll()
  }

  private fun drawAll() {
    val m = gmap ?: return
    m.clear()
    user?.let { m.addMarker(MarkerOptions().position(it).title("You")) }
    dest?.let { m.addMarker(MarkerOptions().position(it).title("Destination")) }
    if (route.isNotEmpty()) {
      m.addPolyline(
        PolylineOptions()
          .addAll(route)
          .color(routeColor)
          .width(routeWidth)
          .geodesic(true)
      )
    }
  }

  // ===== MethodChannel =====
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "updateConfig" -> {
        val cfg = call.arguments as Map<*, *>
        user = cfg["userLocation"].toLatLng()
        dest = cfg["destination"].toLatLng()
        route = (cfg["route"] as? List<*>)?.mapNotNull { it.toLatLng() } ?: emptyList()
        (cfg["routeColor"] as? Number)?.toInt()?.let { routeColor = it }
        (cfg["routeWidth"] as? Number)?.toFloat()?.let { routeWidth = it }
        drawAll()
        result.success(null)
      }
      "cameraTo" -> {
        val a = call.arguments as Map<*, *>
        val lat = (a["latitude"] as Number).toDouble()
        val lng = (a["longitude"] as Number).toDouble()
        val zoom = (a["zoom"] as? Number)?.toFloat()
        val update = if (zoom != null)
          CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom)
        else
          CameraUpdateFactory.newLatLng(LatLng(lat, lng))
        gmap?.animateCamera(update)
        result.success(null)
      }
      "fitBounds" -> {
        val a = call.arguments as Map<*, *>
        val pts = (a["points"] as? List<*>)?.mapNotNull { it.toLatLng() } ?: emptyList()
        val pad = ((a["padding"] as? Number)?.toInt()) ?: 0
        if (pts.isNotEmpty()) {
          val b = LatLngBounds.builder()
          pts.forEach { b.include(it) }
          gmap?.animateCamera(CameraUpdateFactory.newLatLngBounds(b.build(), pad))
        }
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }
}

private fun Any?.toLatLng(): LatLng? {
  val m = this as? Map<*, *> ?: return null
  val la = (m["latitude"] as? Number)?.toDouble()
  val lo = (m["longitude"] as? Number)?.toDouble()
  return if (la != null && lo != null) LatLng(la, lo) else null
}
