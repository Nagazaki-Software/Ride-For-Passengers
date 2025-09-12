package com.quicky.ridebahamas

import android.animation.ValueAnimator
import android.content.Context
import android.content.pm.PackageManager // <- NOVO
import android.graphics.Color
import android.util.Log
import android.view.animation.LinearInterpolator
import android.widget.FrameLayout
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.maps.*
import com.google.android.gms.maps.model.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class PickerMapNativeView(
  private val ctx: Context,
  messenger: BinaryMessenger,
  id: Int,
  private val creationParams: Any?
) : PlatformView, MethodChannel.MethodCallHandler, OnMapReadyCallback {

  private val tag = "PickerMap"
  private val container = FrameLayout(ctx)

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
  private val polygons = mutableListOf<Polygon>()

  // carros animados por id
  private val cars = mutableMapOf<String, Marker>()
  private val carAnimators = mutableMapOf<String, ValueAnimator>()

  private fun dbg(msg: String) {
    Log.d(tag, msg)
    try {
      channel.invokeMethod("debugLog", mapOf("msg" to msg, "ts" to System.currentTimeMillis()))
    } catch (_: Throwable) { /* melhor esforço */ }
  }

  private fun dbge(msg: String, t: Throwable? = null) {
    Log.e(tag, msg, t)
    try {
      channel.invokeMethod("debugLog", mapOf("level" to "E", "msg" to "$msg: ${t?.message}", "ts" to System.currentTimeMillis()))
    } catch (_: Throwable) { /* melhor esforço */ }
  }

  // ----------- NOVO: logar a API key que o app está usando -----------
  private fun logApiKeyFromManifest() {
    try {
      val ai = ctx.packageManager.getApplicationInfo(ctx.packageName, PackageManager.GET_META_DATA)
      val key = ai.metaData?.getString("com.google.android.geo.API_KEY") ?: "<null>"
      val masked = if (key.length >= 12) key.take(6) + "…" + key.takeLast(4) else key
      dbg("API_KEY(manifest)=$masked len=${key.length}")
    } catch (t: Throwable) {
      dbge("Falha ao ler API_KEY do manifest", t)
    }
  }
  // -------------------------------------------------------------------

  init {
    dbg("init: id=$id, params=${creationParams is Map<*, *>}")

    // 0) *** Forçar a MESMA API KEY do google_maps_flutter (teste definitivo) ***
    //    Cole aqui a key que você usa no android/app/src/debug/res/values/google_maps_api.xml
    try {
      MapsInitializer.setApiKey("SUA_API_KEY_ANDROID_AQUI")
      dbg("MapsInitializer.setApiKey aplicado (forçando mesma key do Flutter).")
    } catch (t: Throwable) {
      dbge("setApiKey falhou", t)
    }

    // 1) Google Play Services
    val status = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(ctx)
    if (status != ConnectionResult.SUCCESS) {
      dbge("Google Play Services indisponível: code=$status")
    } else dbg("Google Play Services OK")

    // 2) MapsInitializer
    try {
      val renderer = MapsInitializer.initialize(ctx, MapsInitializer.Renderer.LATEST) {}
      dbg("MapsInitializer.initialize -> $renderer")
    } catch (t: Throwable) {
      dbge("MapsInitializer.initialize falhou", t)
    }

    // 3) Lifecycle do MapView
    try {
      mapView.onCreate(null)
      mapView.onStart()
      mapView.onResume()
      dbg("MapView lifecycle ok (create/start/resume)")
    } catch (t: Throwable) {
      dbge("Lifecycle create/start/resume falhou", t)
    }

    // 4) Async
    mapView.getMapAsync(this)

    // 5) Container
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
    dbg("dispose")
    channel.setMethodCallHandler(null)
    try {
      carAnimators.values.forEach { it.cancel() }
      mapView.onPause()
      mapView.onStop()
      mapView.onDestroy()
    } catch (t: Throwable) {
      dbge("dispose lifecycle error", t)
    }
  }

  // ---------- OnMapReady ----------
  override fun onMapReady(map: GoogleMap) {
    dbg("onMapReady")
    googleMap = map

    // >>> NOVO: loga a API key e confirma quando tiles carregarem
    logApiKeyFromManifest()
    map.setOnMapLoadedCallback { dbg("onMapLoaded (tiles renderizados)") }
    // <<<

    map.uiSettings.isCompassEnabled = true
    map.uiSettings.isMyLocationButtonEnabled = false
    map.isBuildingsEnabled = true
    map.mapType = GoogleMap.MAP_TYPE_NORMAL

    // creationParams: suporta tanto "initialCamera" quanto "initialUserLocation"
    try {
      (creationParams as? Map<*, *>)?.let { params ->
        (params["initialCamera"] as? Map<*, *>)?.let { cam ->
          val lat = (cam["latitude"] as Number).toDouble()
          val lng = (cam["longitude"] as Number).toDouble()
          val zoom = (cam["zoom"] as? Number)?.toFloat() ?: 14f
          map.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom))
          dbg("initialCamera aplicada: ($lat,$lng) z=$zoom")
        }
        (params["initialUserLocation"] as? Map<*, *>)?.let { u ->
          val lat = (u["latitude"] as Number).toDouble()
          val lng = (u["longitude"] as Number).toDouble()
          map.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), 14f))
          dbg("initialUserLocation aplicada: ($lat,$lng)")
        }
      }
    } catch (t: Throwable) {
      dbge("Erro ao aplicar creationParams", t)
    }

    // (workaround) garante render ativo pós-ready
    try {
      mapView.onResume()
      dbg("onMapReady -> mapView.onResume() reforçado")
    } catch (t: Throwable) {
      dbge("onResume extra falhou", t)
    }

    // sinaliza pronto
    try {
      channel.invokeMethod("platformReady", null)
    } catch (_: Throwable) { /* best effort */ }
  }

  // ---------- MethodChannel ----------
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "updateConfig" -> safe(result) {
        val args = call.arguments as Map<*, *>
        applyConfig(args)
      }
      "setMarkers" -> safe(result) {
        val list = call.arguments as List<*>
        setMarkers(list)
      }
      "setPolylines" -> safe(result) {
        val list = call.arguments as List<*>
        setPolylines(list)
      }
      "setPolygons" -> safe(result) {
        val list = call.arguments as List<*>
        setPolygons(list)
      }
      "cameraTo" -> safe(result) {
        val a = call.arguments as Map<*, *>
        val lat = (a["latitude"] as Number).toDouble()
        val lng = (a["longitude"] as Number).toDouble()
        val zoom = (a["zoom"] as? Number)?.toFloat()
        val bearing = (a["bearing"] as? Number)?.toFloat()
        val tilt = (a["tilt"] as? Number)?.toFloat()
        cameraTo(lat, lng, zoom, bearing, tilt)
      }
      "fitBounds" -> safe(result) {
        val a = call.arguments as Map<*, *>
        val points = a["points"] as List<*>
        val padding = ((a["padding"] as? Number) ?: 0).toInt()
        fitBounds(points, padding)
      }
      "updateCarPosition" -> safe(result) {
        val a = call.arguments as Map<*, *>
        val id = a["id"] as String
        val lat = (a["latitude"] as Number).toDouble()
        val lng = (a["longitude"] as Number).toDouble()
        val rotation = (a["rotation"] as? Number)?.toFloat()
        val duration = (a["durationMs"] as? Number)?.toLong() ?: 0L
        updateCarPosition(id, LatLng(lat, lng), rotation, duration)
      }
      "debugInfo" -> {
        val info = mapOf(
          "hasGooglePlay" to (GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(ctx) == ConnectionResult.SUCCESS),
          "mapReady" to (googleMap != null),
          "paramsKeys" to ((creationParams as? Map<*, *>)?.keys?.map { it.toString() } ?: emptyList<String>())
        )
        result.success(info)
      }
      else -> result.notImplemented()
    }
  }

  private inline fun safe(result: MethodChannel.Result, crossinline block: () -> Unit) {
    try {
      block()
      result.success(null)
    } catch (t: Throwable) {
      dbge("${Thread.currentThread().stackTrace[3].methodName} error", t)
      result.error("error", t.message, null)
    }
  }

  // ---------- Helpers ----------
  private fun cameraTo(lat: Double, lng: Double, zoom: Float?, bearing: Float?, tilt: Float?) {
    val map = googleMap ?: run { dbg("cameraTo antes do onMapReady"); return }
    val cu = CameraUpdateFactory.newCameraPosition(
      CameraPosition(
        LatLng(lat, lng),
        zoom ?: map.cameraPosition.zoom,
        tilt ?: map.cameraPosition.tilt,
        bearing ?: map.cameraPosition.bearing
      )
    )
    map.animateCamera(cu)
    dbg("cameraTo ($lat,$lng) z=${zoom ?: "-"} b=${bearing ?: "-"} t=${tilt ?: "-"}")
  }

  private fun fitBounds(points: List<*>, padding: Int) {
    val map = googleMap ?: return
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
    map.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, padding))
    dbg("fitBounds points=${points.size} padding=$padding")
  }

  private fun applyConfig(cfg: Map<*, *>) {
    val map = googleMap ?: run { dbg("applyConfig antes do onMapReady"); return }

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
    dbg("applyConfig ok: user=${userMarker != null} dest=${destMarker != null} route=${routePolyline != null}")
  }

  private fun setMarkers(list: List<*>) {
    val map = googleMap ?: return
    list.forEach { any ->
      val m = any as Map<*, *>
      val lat = (m["latitude"] as Number).toDouble()
      val lng = (m["longitude"] as Number).toDouble()
      map.addMarker(MarkerOptions().position(LatLng(lat, lng)))
    }
    dbg("setMarkers n=${list.size}")
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
    dbg("setPolylines n=${list.size}")
  }

  private fun setPolygons(list: List<*>) {
    val map = googleMap ?: return
    // remove antigos
    polygons.forEach { it.remove() }
    polygons.clear()

    list.forEach { any ->
      val m = any as Map<*, *>
      val pts = (m["points"] as List<*>).mapNotNull { p ->
        (p as? Map<*, *>)?.let {
          val lat = (it["latitude"] as Number).toDouble()
          val lng = (it["longitude"] as Number).toDouble()
          LatLng(lat, lng)
        }
      }
      val strokeColor = (m["strokeColor"] as? Number)?.toInt() ?: Color.BLACK
      val fillColor = (m["fillColor"] as? Number)?.toInt() ?: 0x220000FF
      val width = (m["width"] as? Number)?.toFloat() ?: 2f
      val polygon = map.addPolygon(
        PolygonOptions()
          .addAll(pts)
          .strokeColor(strokeColor)
          .fillColor(fillColor)
          .strokeWidth(width)
      )
      polygons += polygon
    }
    dbg("setPolygons n=${polygons.size}")
  }

  private fun updateCarPosition(id: String, dest: LatLng, rotation: Float?, duration: Long) {
    val map = googleMap ?: return
    val marker = cars[id] ?: run {
      val m = map.addMarker(
        MarkerOptions()
          .position(dest)
          .flat(true)
          .anchor(0.5f, 0.5f)
          .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE))
      )
      cars[id] = m!!
      dbg("car[$id] criado em ${dest.latitude},${dest.longitude}")
      m
    }

    rotation?.let { marker.rotation = it }

    // cancela anim anterior se houver
    carAnimators[id]?.cancel()

    if (duration <= 0L) {
      marker.position = dest
      dbg("car[$id] snap -> ${dest.latitude},${dest.longitude} rot=${rotation ?: "-"}")
      return
    }

    val startPos = marker.position
    val animator = ValueAnimator.ofFloat(0f, 1f).apply {
      interpolator = LinearInterpolator()
      setDuration(duration)
      addUpdateListener { va ->
        val f = va.animatedValue as Float
        val lat = startPos.latitude + (dest.latitude - startPos.latitude) * f
        val lng = startPos.longitude + (dest.longitude - startPos.longitude) * f
        marker.position = LatLng(lat, lng)
      }
      start()
    }
    carAnimators[id] = animator
    dbg("car[$id] anim -> ${dest.latitude},${dest.longitude} dur=${duration}ms rot=${rotation ?: "-"}")
  }
}
