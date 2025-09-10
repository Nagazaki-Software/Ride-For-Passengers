// android/app/src/main/kotlin/com/quicky/ridebahamas/PickerMapNativeView.kt
package com.quicky.ridebahamas

import android.content.Context
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.maps.*
import com.google.android.gms.maps.model.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.net.URL
import kotlin.concurrent.thread

class PickerMapNativeView(
  private val ctx: Context,
  messenger: BinaryMessenger,
  id: Int
) : PlatformView, MethodChannel.MethodCallHandler, OnMapReadyCallback {

  private val root = FrameLayout(ctx)
  private val diag = TextView(ctx).apply {
    textSize = 12f
    setPadding(16, 16, 16, 16)
    setTextColor(0xFFFFE082.toInt())
    setBackgroundColor(0x66000000.toInt())
    visibility = View.GONE
  }

  private val mapView: MapView
  private var map: GoogleMap? = null
  private val channel = MethodChannel(messenger, "picker_map_native_$id")

  private var userMarker: Marker? = null
  private var destMarker: Marker? = null
  private var routePolyline: Polyline? = null
  private val driverMarkers = mutableMapOf<String, Marker>()
  private val iconCache = mutableMapOf<String, BitmapDescriptor?>()

  init {
    // 1) LOGA a API KEY lida do Manifest (é ESSENCIAL pra cravar se está vindo vazia/errada)
    val apiKey = try {
      val ai = ctx.packageManager.getApplicationInfo(ctx.packageName, PackageManager.GET_META_DATA)
      ai.metaData?.getString("com.google.android.geo.API_KEY")
    } catch (_: Throwable) { null }
    android.util.Log.d("PickerMap", "Manifest com.google.android.geo.API_KEY = ${apiKey ?: "<NULL>"}")

    // 2) Status Play Services + fallback lite
    val status = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(ctx)
    android.util.Log.d("PickerMap", "PlayServices status=$status")
    val options = GoogleMapOptions().apply { if (status != ConnectionResult.SUCCESS) liteMode(true) }

    mapView = MapView(ctx, options)
    mapView.onCreate(null)
    try { MapsInitializer.initialize(mapView.context, MapsInitializer.Renderer.LATEST) { } } catch (_: Throwable) {}
    mapView.onStart()
    mapView.onResume()
    mapView.getMapAsync(this)

    channel.setMethodCallHandler(this)
    root.addView(mapView, FrameLayout.LayoutParams(
      FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
    val lp = FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT)
    lp.gravity = Gravity.TOP or Gravity.START
    root.addView(diag, lp)

    if (status != ConnectionResult.SUCCESS) {
      diag.visibility = View.VISIBLE
      diag.text = "Google Play Services: $status (lite mode)"
    }
  }

  override fun getView(): View = root

  override fun dispose() {
    channel.setMethodCallHandler(null)
    try { mapView.onPause(); mapView.onStop(); mapView.onDestroy() } catch (_: Throwable) {}
  }

  override fun onMapReady(googleMap: GoogleMap) {
    map = googleMap
    android.util.Log.d("PickerMap", "onMapReady()")
    googleMap.setOnMapLoadedCallback {
      android.util.Log.d("PickerMap", "onMapLoaded()")
      diag.visibility = View.GONE
    }
    googleMap.uiSettings.isMapToolbarEnabled = false
    googleMap.uiSettings.isZoomControlsEnabled = false
    googleMap.uiSettings.isMyLocationButtonEnabled = false
    googleMap.mapType = GoogleMap.MAP_TYPE_NORMAL
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "updateConfig" -> {
        android.util.Log.d("PickerMap", "updateConfig")
        val args = call.arguments as Map<*, *>
        // ... (SEU CÓDIGO ATUAL DE updateConfig AQUI, sem mudanças) ...
        result.success(null)
      }
      "cameraTo" -> { /* ... igual ao seu ... */ result.success(null) }
      "fitBounds" -> { /* ... igual ao seu ... */ result.success(null) }
      "setMarkers", "setPolylines", "setPolygons", "updateCarPosition" -> result.success(null)
      else -> result.notImplemented()
    }
  }

  private fun loadIcon(url: String, onLoadedMainThread: (BitmapDescriptor?) -> Unit) {
    val cached = iconCache[url]
    if (cached != null) { root.post { onLoadedMainThread(cached) }; return }
    thread {
      val icon = try {
        URL(url).openConnection().getInputStream().use { stream ->
          val bmp = BitmapFactory.decodeStream(stream)
          if (bmp != null) BitmapDescriptorFactory.fromBitmap(bmp) else null
        }
      } catch (_: Exception) { null }
      iconCache[url] = icon
      root.post { onLoadedMainThread(icon) }
    }
  }
}
