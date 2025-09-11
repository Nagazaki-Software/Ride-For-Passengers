package com.quicky.ridebahamas

import android.content.Context
import android.graphics.Color
import android.widget.FrameLayout
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.model.*
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import org.json.JSONObject

class PickerMapNativeView(
  context: Context,
  messenger: BinaryMessenger,
  id: Int
) : PlatformView, MethodChannel.MethodCallHandler, OnMapReadyCallback {

  private val tag = "PickerMap"
  private val container = FrameLayout(context)
  private val mapView = MapView(context)
  private var googleMap: GoogleMap? = null
  private val channel = MethodChannel(messenger, "picker_map_native_$id")

  private var userMarker: Marker? = null
  private var destMarker: Marker? = null
  private var routePolyline: Polyline? = null

  init {
    Log.d(tag, "PickerMapNativeView init, id=$id")
    channel.setMethodCallHandler(this)

    mapView.onCreate(null)
    mapView.getMapAsync(this)
    container.addView(mapView,
      FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT
      )
    )
  }

  override fun getView() = container

  override fun dispose() {
    Log.d(tag, "dispose")
    channel.setMethodCallHandler(null)
    mapView.onPause()
    mapView.onDestroy()
  }

  // ===== Lifecycle bridging (suficiente p/ MapView) =====
  fun onResume() { mapView.onResume() }
  fun onPause() { mapView.onPause() }

  // ===== OnMapReady =====
  override fun onMapReady(map: GoogleMap) {
    Log.d(tag, "onMapReady")
    googleMap = map
    googleMap?.uiSettings?.isCompassEnabled = true
    googleMap?.uiSettings?.isMyLocationButtonEnabled = false
    googleMap?.isBuildingsEnabled = true
    // IMPORTANTE: habilitar/checar mapas
    // googleMap?.isMyLocationEnabled = false // só ative se já tiver permissão

    // Sinaliza pro Dart que a view está criada
    channel.invokeMethod("platformReady", null)
  }

  // ===== Recebe comandos do Dart =====
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "updateConfig" -> {
        try {
          val args = call.arguments as Map<*, *>
          applyConfig(args)
          result.success(null)
        } catch (t: Throwable) {
          Log.e(tag, "updateConfig error", t)
          result.error("updateConfig", t.message, null)
        }
      }
      "setMarkers" -> {
        try {
          val list = call.arguments as List<*>
          setMarkers(list)
          result.success(null)
        } catch (t: Throwable) {
          Log.e(tag, "setMarkers error", t)
          result.error("setMarkers", t.message, null)
        }
      }
      "setPolylines" -> {
        try {
          val list = call.arguments as List<*>
          setPolylines(list)
          result.success(null)
        } catch (t: Throwable) {
          Log.e(tag, "setPolylines error", t)
          result.error("setPolylines", t.message, null)
        }
      }
      "cameraTo" -> {
        try {
          val args = call.arguments as Map<*, *>
          val lat = (args["latitude"] as Number).toDouble()
          val lng = (args["longitude"] as Number).toDouble()
          val zoom = (args["zoom"] as Number?)?.toFloat() ?: 15f
          googleMap?.animateCamera(
            CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom)
          )
          result.success(null)
        } catch (t: Throwable) {
          Log.e(tag, "cameraTo error", t)
          result.error("cameraTo", t.message, null)
        }
      }
      "fitBounds" -> {
        try {
          val args = call.arguments as Map<*, *>
          val points = args["points"] as List<*>
          val padding = ((args["padding"] as Number?)?: 0).toInt()
          val builder = LatLngBounds.Builder()
          points.forEach { p ->
            val m = p as Map<*, *>
            builder.include(LatLng(
              (m["latitude"] as Number).toDouble(),
              (m["longitude"] as Number).toDouble()
            ))
          }
          val bounds = builder.build()
          googleMap?.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, padding))
          result.success(null)
        } catch (t: Throwable) {
          Log.e(tag, "fitBounds error", t)
          result.error("fitBounds", t.message, null)
        }
      }
      else -> result.notImplemented()
    }
  }

  // ===== Helpers =====
  private fun applyConfig(cfg: Map<*, *>) {
    val map = googleMap ?: return
    // user marker
    (cfg["userLocation"] as? Map<*, *>)?.let { m ->
      val p = LatLng(
        (m["latitude"] as Number).toDouble(),
        (m["longitude"] as Number).toDouble()
      )
      if (userMarker == null) {
        userMarker = map.addMarker(
          MarkerOptions()
            .position(p)
            .title((cfg["userName"] as? String) ?: "You")
            .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_AZURE))
        )
        map.moveCamera(CameraUpdateFactory.newLatLngZoom(p, 15f))
      } else {
        userMarker?.position = p
      }
    }

    // destination
    (cfg["destination"] as? Map<*, *>)?.let { m ->
      val p = LatLng(
        (m["latitude"] as Number).toDouble(),
        (m["longitude"] as Number).toDouble()
      )
      if (destMarker == null) {
        destMarker = map.addMarker(
          MarkerOptions()
            .position(p)
            .title("Destination")
            .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_ORANGE))
        )
      } else {
        destMarker?.position = p
      }
    } ?: run {
      destMarker?.remove()
      destMarker = null
    }

    // route polyline
    val colorInt = (cfg["routeColor"] as? Number)?.toInt() ?: Color.YELLOW
    val width = (cfg["routeWidth"] as? Number)?.toFloat() ?: 4f
    routePolyline?.remove()
    (cfg["route"] as? List<*>)?.let { list ->
      val pts = list.mapNotNull { p ->
        (p as? Map<*, *>)?.let {
          val lat = (it["latitude"] as Number).toDouble()
          val lng = (it["longitude"] as Number).toDouble()
          LatLng(lat, lng)
        }
      }
      if (pts.size >= 2) {
        routePolyline = map.addPolyline(
          PolylineOptions()
            .addAll(pts)
            .color(colorInt)
            .width(width)
        )
      }
    }
  }

  private fun setMarkers(list: List<*>) {
    val map = googleMap ?: return
    list.forEach { any ->
      val m = any as Map<*, *>
      val lat = (m["latitude"] as Number).toDouble()
      val lng = (m["longitude"] as Number).toDouble()
      map.addMarker(MarkerOptions().position(LatLng(lat, lng)))
    }
  }

  private fun setPolylines(list: List<*>) {
    val map = googleMap ?: return
    list.forEach { any ->
      val m = any as Map<*, *>
      val pts = (m["points"] as List<*>).mapNotNull { p ->
        (p as? Map<*, *>)?.let {
          val lat = (it["latitude"] as Number).toDouble()
          val lng = (it["longitude"] as Number).toDouble()
          LatLng(lat, lng)
        }
      }
      val color = (m["color"] as? Number)?.toInt() ?: Color.YELLOW
      val width = (m["width"] as? Number)?.toFloat() ?: 4f
      map.addPolyline(PolylineOptions().addAll(pts).color(color).width(width))
    }
  }
}
