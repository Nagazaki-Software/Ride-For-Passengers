package com.quicky.ridebahamas

import android.content.Context
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

  // Container para poder sobrepor mensagens de diagnóstico
  private val root: FrameLayout = FrameLayout(ctx)
  private val diag: TextView = TextView(ctx).apply {
    textSize = 12f
    setPadding(16, 16, 16, 16)
    setTextColor(0xFFFFE082.toInt()) // amarelinho
    setBackgroundColor(0x66000000)   // preto 40%
    visibility = View.GONE
  }

  // Tenta criar MapView no modo normal; se Play Services indisponível, ativa lite mode
  private val mapView: MapView
  private var map: GoogleMap? = null
  private val channel = MethodChannel(messenger, "picker_map_native_$id")

  private var userMarker: Marker? = null
  private var destMarker: Marker? = null
  private var routePolyline: Polyline? = null
  private val driverMarkers = mutableMapOf<String, Marker>()
  private val iconCache = mutableMapOf<String, BitmapDescriptor?>()

  init {
    // Diagnóstico: Play Services
    val status = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(ctx)
    android.util.Log.d("PickerMap", "PlayServices status=$status (${statusName(status)})")

    val options = GoogleMapOptions().apply {
      // se não está SUCCESS, força liteMode para pelo menos renderizar algo
      if (status != ConnectionResult.SUCCESS) liteMode(true)
    }

    mapView = MapView(ctx, options)

    mapView.onCreate(null)
    try { MapsInitializer.initialize(mapView.context, MapsInitializer.Renderer.LATEST) { } } catch (_: Throwable) { }
    mapView.onStart()
    mapView.onResume()
    mapView.getMapAsync(this)

    channel.setMethodCallHandler(this)

    // Monta a view raiz com overlay de diagnóstico
    root.addView(mapView, FrameLayout.LayoutParams(
      FrameLayout.LayoutParams.MATCH_PARENT,
      FrameLayout.LayoutParams.MATCH_PARENT
    ))
    val lp = FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT)
    lp.gravity = Gravity.TOP or Gravity.START
    root.addView(diag, lp)

    // Mostra mensagem se Play Services não ok
    if (status != ConnectionResult.SUCCESS) {
      diag.visibility = View.VISIBLE
      diag.text = "Google Play Services: ${statusName(status)} (modo lite)"
    }
  }

  override fun getView(): View = root

  override fun dispose() {
    channel.setMethodCallHandler(null)
    try {
      mapView.onPause()
      mapView.onStop()
      mapView.onDestroy()
    } catch (_: Throwable) { }
  }

  override fun onMapReady(googleMap: GoogleMap) {
    map = googleMap
    android.util.Log.d("PickerMap", "onMapReady()")
    googleMap.setOnMapLoadedCallback {
      android.util.Log.d("PickerMap", "onMapLoaded()")
      diag.visibility = View.GONE // some o diagnóstico quando carregar
    }

    // Configurações de segurança
    googleMap.uiSettings.isMapToolbarEnabled = false
    googleMap.uiSettings.isZoomControlsEnabled = false
    googleMap.uiSettings.isMyLocationButtonEnabled = false
    googleMap.mapType = GoogleMap.MAP_TYPE_NORMAL
    googleMap.isBuildingsEnabled = true
    googleMap.isIndoorEnabled = false
    googleMap.isTrafficEnabled = false

    googleMap.setOnMapClickListener {
      channel.invokeMethod("onTap", mapOf("latitude" to it.latitude, "longitude" to it.longitude))
    }
    googleMap.setOnMapLongClickListener {
      channel.invokeMethod("onLongPress", mapOf("latitude" to it.latitude, "longitude" to it.longitude))
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "updateConfig" -> {
        android.util.Log.d("PickerMap", "updateConfig")
        val args = call.arguments as Map<*, *>

        val user = args["userLocation"] as Map<*, *>
        val lat = (user["latitude"] as Number).toDouble()
        val lng = (user["longitude"] as Number).toDouble()
        val pos = LatLng(lat, lng)
        map?.moveCamera(CameraUpdateFactory.newLatLngZoom(pos, 14f))

        val pad = ((args["brandSafePaddingBottom"] as? Number)?.toInt()) ?: 0
        map?.setPadding(0, 0, 0, pad)

        // Marcador do usuário
        val userPhoto = args["userPhotoUrl"] as? String
        if (userMarker == null) {
          userMarker = map?.addMarker(MarkerOptions().position(pos).anchor(0.5f, 0.5f)
            .icon(BitmapDescriptorFactory.defaultMarker()))
        }
        userMarker?.position = pos
        userPhoto?.let { url -> loadIcon(url) { icon ->
          userMarker?.setIcon(icon ?: BitmapDescriptorFactory.defaultMarker())
        } }

        // Destino (opcional)
        if (args.containsKey("destination")) {
          val dest = args["destination"] as Map<*, *>
          val dlat = (dest["latitude"] as Number).toDouble()
          val dlng = (dest["longitude"] as Number).toDouble()
          val dpos = LatLng(dlat, dlng)
          if (destMarker == null) destMarker = map?.addMarker(MarkerOptions().position(dpos).anchor(0.5f, 1f))
          destMarker?.position = dpos
        } else {
          destMarker?.remove(); destMarker = null
        }

        // Drivers
        val existing = driverMarkers.keys.toMutableSet()
        val drivers = args["drivers"] as? List<*>
        drivers?.forEach { d ->
          val m = d as Map<*, *>
          val id = m["id"].toString()
          val dlat = (m["latitude"] as Number).toDouble()
          val dlng = (m["longitude"] as Number).toDouble()
          val rotation = ((m["rotation"] as? Number)?.toFloat()) ?: 0f
          val type = m["type"]?.toString() ?: "driver"
          val posD = LatLng(dlat, dlng)

          val marker = driverMarkers[id]
          if (marker == null) {
            val mk = map?.addMarker(MarkerOptions().position(posD).anchor(0.5f, 0.5f).rotation(rotation).flat(true))
            if (mk != null) {
              driverMarkers[id] = mk
              val iconUrl = if (type == "taxi") args["driverTaxiIconUrl"] as? String else args["driverDriverIconUrl"] as? String
              val cacheKey = "${type}_${iconUrl ?: ""}"
              val cached = iconCache[cacheKey]
              if (cached != null) mk.setIcon(cached) else if (!iconUrl.isNullOrEmpty()) {
                loadIcon(iconUrl) { icon -> icon?.let { ico -> iconCache[cacheKey] = ico; mk.setIcon(ico) } }
              }
            }
          } else {
            marker.position = posD
            marker.rotation = rotation
          }
          existing.remove(id)
        }
        existing.forEach { id -> driverMarkers.remove(id)?.remove() }

        // Rota
        val route = args["route"] as? List<*>
        if (!route.isNullOrEmpty()) {
          val pts = route.map {
            val p = it as Map<*, *>
            LatLng((p["latitude"] as Number).toDouble(), (p["longitude"] as Number).toDouble())
          }
          val color = ((args["routeColor"] as? Number)?.toInt()) ?: 0xFFFFC107.toInt()
          val width = ((args["routeWidth"] as? Number)?.toInt()) ?: 4
          if (routePolyline == null) {
            routePolyline = map?.addPolyline(PolylineOptions().color(color).width(width.toFloat()).addAll(pts))
          } else {
            routePolyline?.points = pts
            routePolyline?.color = color
            routePolyline?.width = width.toFloat()
          }
        } else {
          routePolyline?.remove(); routePolyline = null
        }

        result.success(null)
      }

      "cameraTo" -> {
        val lat = (call.argument<Number>("latitude"))?.toDouble()
        val lng = (call.argument<Number>("longitude"))?.toDouble()
        val zoom = (call.argument<Number>("zoom"))?.toFloat()
        if (lat != null && lng != null) {
          val update = if (zoom != null) CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom)
                       else CameraUpdateFactory.newLatLng(LatLng(lat, lng))
          map?.animateCamera(update)
          result.success(null)
        } else result.error("bad_args", "latitude/longitude ausentes", null)
      }

      "fitBounds" -> {
        val points = call.argument<List<Map<String, Number>>>("points").orEmpty()
        if (points.isNotEmpty()) {
          val builder = LatLngBounds.builder()
          points.forEach { p -> builder.include(LatLng(p["latitude"]!!.toDouble(), p["longitude"]!!.toDouble())) }
          val padding = (call.argument<Number>("padding")?.toInt()) ?: 0
          map?.animateCamera(CameraUpdateFactory.newLatLngBounds(builder.build(), padding))
        }
        result.success(null)
      }

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

  private fun statusName(code: Int) = when(code) {
    ConnectionResult.SUCCESS -> "SUCCESS"
    ConnectionResult.SERVICE_MISSING -> "SERVICE_MISSING"
    ConnectionResult.SERVICE_VERSION_UPDATE_REQUIRED -> "UPDATE_REQUIRED"
    ConnectionResult.SERVICE_DISABLED -> "SERVICE_DISABLED"
    else -> "CODE_$code"
  }
}
