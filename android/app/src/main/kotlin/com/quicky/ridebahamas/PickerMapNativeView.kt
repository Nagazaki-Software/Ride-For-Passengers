package com.quicky.ridebahamas

import android.content.Context
import android.graphics.Color
import android.widget.FrameLayout
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.maps.*
import com.google.android.gms.maps.model.*
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class PickerMapNativeView(
  private val ctx: Context,
  messenger: BinaryMessenger,
  id: Int,
  private val creationParams: Any? // <--- AGORA ACEITA OS PARAMS DO FLUTTER
) : PlatformView, MethodChannel.MethodCallHandler, OnMapReadyCallback {

  private val tag = "PickerMap"
  private val container = FrameLayout(ctx)

  // Opções de inicialização do Map
  private val mapOptions = GoogleMapOptions()
    .mapType(GoogleMap.MAP_TYPE_NORMAL)
    .compassEnabled(true)
    .mapToolbarEnabled(false)
    .liteMode(false)

  private val mapView = MapView(ctx, mapOptions)
  private var googleMap: GoogleMap? = null
  private val channel = MethodChannel(messenger, "picker_map_native_$id")

  private var userMarker: Marker? = null
  private var destMarker: Marker? = null
  private var routePolyline: Polyline? = null

  init {
    Log.d(tag, "PickerMapNativeView init, id=$id, hasParams=${creationParams != null}")

    // 1) Play Services
    val ga = GoogleApiAvailability.getInstance()
    val status = ga.isGooglePlayServicesAvailable(ctx)
    if (status != ConnectionResult.SUCCESS) {
      Log.e(tag, "Google Play Services indisponível: code=$status")
    } else {
      Log.d(tag, "Google Play Services OK")
    }

    // 2) Inicializa Maps
    try {
      val renderer = MapsInitializer.initialize(ctx, MapsInitializer.Renderer.LATEST) {}
      Log.d(tag, "MapsInitializer.initialize -> $renderer")
    } catch (t: Throwable) {
      Log.e(tag, "MapsInitializer.initialize falhou", t)
    }

    // 3) Lifecycle do MapView
    try {
      mapView.onCreate(null)
      mapView.onStart()
      mapView.onResume()
    } catch (t: Throwable) {
      Log.e(tag, "Lifecycle create/start/resume falhou", t)
    }

    // 4) Map async
    mapView.getMapAsync(this)

    // 5) Adiciona ao container
    container.addView(
      mapView,
      FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT
      )
    )

    // Channel
    channel.setMethodCallHandler(this)
  }

  // ---------- PlatformView ----------
  override fun getView() = container

  override fun dispose() {
    Log.d(tag, "dispose")
    channel.setMethodCallHandler(null)
    try {
      mapView.onPause()
      mapView.onStop()
      mapView.onDestroy()
    } catch (t: Throwable) {
      Log.e(tag, "dispose lifecycle error", t)
    }
  }

  // ---------- OnMapReady ----------
  override fun onMapReady(map: GoogleMap) {
    Log.d(tag, "onMapReady")
    googleMap = map
    googleMap?.uiSettings?.isCompassEnabled = true
    googleMap?.uiSettings?.isMyLocationButtonEnabled = false
    googleMap?.isBuildingsEnabled = true
    googleMap?.mapType = GoogleMap.MAP_TYPE_NORMAL

    // Se vieram creationParams do Dart, aplica config inicial aqui
    try {
      (creationParams as? Map<*, *>)?.let { params ->
        // Ex.: params["initialCamera"] = { latitude, longitude, zoom }
        (params["initialCamera"] as? Map<*, *>)?.let { cam ->
          val lat = (cam["latitude"] as Number).toDouble()
          val lng = (cam["longitude"] as Number).toDouble()
          val zoom = (cam["zoom"] as? Number)?.toFloat() ?: 14f
          googleMap?.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom))
        }

        // Se quiser já aplicar markers/rota iniciais:
        (params["config"] as? Map<*, *>)?.let { cfg -> applyConfig(cfg) }
      }
    } catch (t: Throwable) {
      Log.e(tag, "Erro ao aplicar creationParams", t)
    }

    // Sinaliza pro Dart que a view está pronta
    channel.invokeMethod("platformReady", null)
  }

  // ---------- MethodChannel ----------
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
          val padding = ((args["padding"] as Number?) ?: 0).toInt()
          val builder = LatLngBounds.Builder()
          points.forEach { p ->
            val m = p as Map<*, *>
            builder.include(
              LatLng(
                (m["latitude"] as Number).toDouble(),
                (m["longitude"] as Number).toDouble()
              )
            )
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

  // ---------- Helpers ----------
  private fun applyConfig(cfg: Map<*, *>) {
    val map = googleMap ?: run {
      Log.w(tag, "applyConfig antes do onMapReady")
      return
    }

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
