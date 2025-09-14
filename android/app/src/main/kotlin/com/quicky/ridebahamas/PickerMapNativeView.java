package com.quicky.ridebahamas

import android.animation.ValueAnimator
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Color
import android.util.Log
import android.view.ViewTreeObserver
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
  private val cars = mutableMapOf<String, Marker>()
  private val carAnimators = mutableMapOf<String, ValueAnimator>()
  private var pendingMapStyleJson: String? = null

  private fun dbg(msg: String) {
    Log.d(tag, msg)
    try { channel.invokeMethod("debugLog", mapOf("msg" to msg, "ts" to System.currentTimeMillis())) } catch (_: Throwable) {}
  }
  private fun dbge(msg: String, t: Throwable? = null) {
    Log.e(tag, msg, t)
    try { channel.invokeMethod("debugLog", mapOf("level" to "E", "msg" to "$msg: ${t?.message}", "ts" to System.currentTimeMillis())) } catch (_: Throwable) {}
  }

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

  init {
    val status = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(ctx)
    if (status != ConnectionResult.SUCCESS) dbge("Google Play Services indisponível: code=$status")
    else dbg("Google Play Services OK")

    try {
      MapsInitializer.initialize(ctx, MapsInitializer.Renderer.LATEST) { r ->
        dbg("MapsInitializer.initialize -> $r")
      }
    } catch (t: Throwable) { dbge("MapsInitializer.initialize falhou", t) }

    try {
      mapView.onCreate(null)
      mapView.onStart()
      mapView.onResume()
      dbg("MapView lifecycle ok (create/start/resume)")
    } catch (t: Throwable) { dbge("Lifecycle create/start/resume falhou", t) }

    mapView.getMapAsync(this)

    container.addView(
      mapView,
      FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)
    )

    mapView.viewTreeObserver.addOnGlobalLayoutListener(
      ViewTreeObserver.OnGlobalLayoutListener {
        dbg("sizes: container=${container.width}x${container.height} mapView=${mapView.width}x${mapView.height}")
      }
    )

    channel.setMethodCallHandler(this)
  }

  override fun getView() = container

  override fun dispose() {
    dbg("dispose")
    channel.setMethodCallHandler(null)
    try {
      carAnimators.values.forEach { it.cancel() }
      mapView.onPause()
      mapView.onStop()
      mapView.onDestroy()
    } catch (t: Throwable) { dbge("dispose lifecycle error", t) }
  }

  override fun onMapReady(map: GoogleMap) {
    dbg("onMapReady")
    logApiKeyFromManifest()
    googleMap = map
    map.uiSettings.isCompassEnabled = true
    map.uiSettings.isMyLocationButtonEnabled = false
    map.uiSettings.isMapToolbarEnabled = false
    map.isBuildingsEnabled = true
    map.mapType = GoogleMap.MAP_TYPE_NORMAL

    map.setOnMapLoadedCallback { dbg("onMapLoaded (tiles renderizados)") }
    map.setOnMapClickListener { p -> dbg("onMapClick ${p.latitude},${p.longitude}") }

    // creationParams: initial camera e estilo
    try {
      (creationParams as? Map<*, *>)?.let { params ->
        (params["initialUserLocation"] as? Map<*, *>)?.let { u ->
          val lat = (u["latitude"] as Number).toDouble()
          val lng = (u["longitude"] as Number).toDouble()
          map.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), 14f))
          dbg("initialUserLocation aplicada: ($lat,$lng)")
        }
        pendingMapStyleJson = (params["mapStyleJson"] as? String)
      }
    } catch (t: Throwable) { dbge("Erro ao aplicar creationParams", t) }

    // Aplica estilo (se veio)
    applyMapStyleIfNeeded()

    try { channel.invokeMethod("platformReady", null) } catch (_: Throwable) {}
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    fun ok() = result.success(null)
    fun err(t: Throwable) = result.error("error", t.message, null)

    try {
      when (call.method) {
        "updateConfig" -> { applyConfig(call.arguments as Map<*, *>); ok() }
        "setMarkers" -> { setMarkers(call.arguments as List<*>); ok() }
        "setPolylines" -> { setPolylines(call.arguments as List<*>); ok() }
        "setPolygons" -> { setPolygons(call.arguments as List<*>); ok() }
        "cameraTo" -> {
          val a = call.arguments as Map<*, *>
          val lat = (a["latitude"] as Number).toDouble()
          val lng = (a["longitude"] as Number).toDouble()
          val zoom = (a["zoom"] as? Number)?.toFloat()
          val bearing = (a["bearing"] as? Number)?.toFloat()
          val tilt = (a["tilt"] as? Number)?.toFloat()
          cameraTo(lat, lng, zoom, bearing, tilt); ok()
        }
        "fitBounds" -> {
          val a = call.arguments as Map<*, *>
          val points = a["points"] as List<*>
          val padding = ((a["padding"] as? Number) ?: 0).toInt()
          fitBounds(points, padding); ok()
        }
        "updateCarPosition" -> {
          val a = call.arguments as Map<*, *>
          val id = a["id"] as String
          val lat = (a["latitude"] as Number).toDouble()
          val lng = (a["longitude"] as Number).toDouble()
          val rotation = (a["rotation"] as? Number)?.toFloat()
          val duration = (a["durationMs"] as? Number)?.toLong() ?: 0L
          updateCarPosition(id, LatLng(lat, lng), rotation, duration); ok()
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
    } catch (t: Throwable) { dbge("onMethodCall ${call.method} error", t); err(t) }
  }

  private fun cameraTo(lat: Double, lng: Double, zoom: Float?, bearing: Float?, tilt: Float?) {
    val map = googleMap ?: run { dbg("cameraTo antes do onMapReady"); return }
    val pos = map.cameraPosition
    val cu = CameraUpdateFactory.newCameraPosition(
      CameraPosition(
        LatLng(lat, lng),
        zoom ?: pos.zoom,
        tilt ?: pos.tilt,
        bearing ?: pos.bearing
      )
    )
    map.animateCamera(cu)
    dbg("cameraTo ($lat,$lng) z=${zoom ?: "-"} b=${bearing ?: "-"} t=${tilt ?: "-"}")
  }

  private fun fitBounds(points: List<*>, padding: Int) {
    val map = googleMap ?: return
    val b = LatLngBounds.Builder()
    points.forEach { p ->
      val m = p as Map<*, *>
      b.include(LatLng((m["latitude"] as Number).toDouble(), (m["longitude"] as Number).toDouble()))
    }
    map.animateCamera(CameraUpdateFactory.newLatLngBounds(b.build(), padding))
    dbg("fitBounds points=${points.size} padding=$padding")
  }

  private fun applyMapStyleIfNeeded() {
    val json = pendingMapStyleJson ?: return
    val map = googleMap ?: return
    try {
      val ok = map.setMapStyle(MapStyleOptions(json))
      dbg("map.setMapStyle -> $ok")
    } catch (t: Throwable) {
      dbge("setMapStyle falhou", t)
    } finally {
      pendingMapStyleJson = null // consome uma vez
    }
  }

  private fun applyConfig(cfg: Map<*, *>) {
    val map = googleMap ?: run { dbg("applyConfig antes do onMapReady"); return }

    // Estilo (dark, etc) pode vir via updateConfig também
    (cfg["mapStyleJson"] as? String)?.let {
      pendingMapStyleJson = it
      applyMapStyleIfNeeded()
    }

    (cfg["userLocation"] as? Map<*, *>)?.let { m ->
      val p = LatLng((m["latitude"] as Number).toDouble(), (m["longitude"] as Number).toDouble())
      if (userMarker == null) {
        userMarker = map.addMarker(
          MarkerOptions().position(p).title((cfg["userName"] as? String) ?: "You")
            .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_AZURE))
            .flat(true)
        )
        map.moveCamera(CameraUpdateFactory.newLatLngZoom(p, 15f))
      } else userMarker?.position = p
    }

    (cfg["destination"] as? Map<*, *>)?.let { m ->
      val p = LatLng((m["latitude"] as Number).toDouble(), (m["longitude"] as Number).toDouble())
      if (destMarker == null) {
        destMarker = map.addMarker(
          MarkerOptions().position(p).title("Destination")
            .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_ORANGE))
        )
      } else destMarker?.position = p
    } ?: run { destMarker?.remove(); destMarker = null }

    val colorInt = (cfg["routeColor"] as? Number)?.toInt() ?: Color.YELLOW
    val width = (cfg["routeWidth"] as? Number)?.toFloat() ?: 4f
    routePolyline?.remove()
    (cfg["route"] as? List<*>)?.let { list ->
      val pts = list.mapNotNull { p ->
        (p as? Map<*, *>)?.let {
          LatLng((it["latitude"] as Number).toDouble(), (it["longitude"] as Number).toDouble())
        }
      }
      if (pts.size >= 2) {
        routePolyline = map.addPolyline(PolylineOptions().addAll(pts).color(colorInt).width(width))
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
          LatLng((it["latitude"] as Number).toDouble(), (it["longitude"] as Number).toDouble())
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
    polygons.forEach { it.remove() }
    polygons.clear()
    list.forEach { any ->
      val m = any as Map<*, *>
      val pts = (m["points"] as List<*>).mapNotNull { p ->
        (p as? Map<*, *>)?.let {
          LatLng((it["latitude"] as Number).toDouble(), (it["longitude"] as Number).toDouble())
        }
      }
      val strokeColor = (m["strokeColor"] as? Number)?.toInt() ?: Color.BLACK
      val fillColor = (m["fillColor"] as? Number)?.toInt() ?: 0x220000FF
      val width = (m["width"] as? Number)?.toFloat() ?: 2f
      val polygon = map.addPolygon(
        PolygonOptions().addAll(pts).strokeColor(strokeColor).fillColor(fillColor).strokeWidth(width)
      )
      polygons += polygon
    }
    dbg("setPolygons n=${polygons.size}")
  }

  private fun updateCarPosition(id: String, dest: LatLng, rotation: Float?, duration: Long) {
    val map = googleMap ?: return
    val marker = cars[id] ?: run {
      val m = map.addMarker(
        MarkerOptions().position(dest).flat(true).anchor(0.5f, 0.5f)
          .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE))
      )!!
      cars[id] = m
      dbg("car[$id] criado em ${dest.latitude},${dest.longitude}")
      m
    }
    rotation?.let { marker.rotation = it }
    carAnimators[id]?.cancel()

    if (duration <= 0L) {
      marker.position = dest
      dbg("car[$id] snap -> ${dest.latitude},${dest.longitude} rot=${rotation ?: "-"}")
      return
    }

    val startPos = marker.position
    val animator = ValueAnimator.ofFloat(0f, 1f).apply {
      interpolator = LinearInterpolator()
      duration = duration
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
