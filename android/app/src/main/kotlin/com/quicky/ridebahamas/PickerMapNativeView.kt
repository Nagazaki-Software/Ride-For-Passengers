package com.quicky.ridebahamas

import android.content.Context
import android.graphics.BitmapFactory
import android.view.View
import com.google.android.gms.maps.*
import com.google.android.gms.maps.model.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.net.URL
import kotlin.concurrent.thread

class PickerMapNativeView(
  context: Context,
  messenger: BinaryMessenger,
  id: Int
) : PlatformView, MethodChannel.MethodCallHandler, OnMapReadyCallback {

  private val mapView: MapView
  private var map: GoogleMap? = null
  private val channel = MethodChannel(messenger, "picker_map_native_$id")

  private var userMarker: Marker? = null
  private var destMarker: Marker? = null
  private var routePolyline: Polyline? = null
  private val driverMarkers = mutableMapOf<String, Marker>()
  private val iconCache = mutableMapOf<String, BitmapDescriptor?>()

  init {
    // (Opcional) se quiser testar Lite Mode:
    // val options = GoogleMapOptions().liteMode(true)
    // mapView = MapView(context, options)

    mapView = MapView(context)

    mapView.onCreate(null)
    // Inicializa renderer moderno (ajuda a evitar tela preta em alguns devices/AVDs)
    try {
      MapsInitializer.initialize(mapView.context, MapsInitializer.Renderer.LATEST) { }
    } catch (_: Throwable) { }

    mapView.onStart()
    mapView.onResume()
    mapView.getMapAsync(this)

    channel.setMethodCallHandler(this)
  }

  override fun getView(): View = mapView

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
    android.util.Log.d("PickerMap", "onMapReady() chamado")

    googleMap.uiSettings.isMapToolbarEnabled = false
    googleMap.uiSettings.isZoomControlsEnabled = false
    googleMap.uiSettings.isMyLocationButtonEnabled = false

    googleMap.setOnMapClickListener {
      channel.invokeMethod(
        "onTap", mapOf("latitude" to it.latitude, "longitude" to it.longitude)
      )
    }
    googleMap.setOnMapLongClickListener {
      channel.invokeMethod(
        "onLongPress", mapOf("latitude" to it.latitude, "longitude" to it.longitude)
      )
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {

      "updateConfig" -> {
        android.util.Log.d("PickerMap", "updateConfig recebido")
        val args = call.arguments as Map<*, *>

        // userLocation
        val user = args["userLocation"] as Map<*, *>
        val lat = (user["latitude"] as Number).toDouble()
        val lng = (user["longitude"] as Number).toDouble()
        val pos = LatLng(lat, lng)
        map?.moveCamera(CameraUpdateFactory.newLatLngZoom(pos, 14f))

        // padding
        val pad = ((args["brandSafePaddingBottom"] as? Number)?.toInt()) ?: 0
        map?.setPadding(0, 0, 0, pad)

        // user marker
        val userPhoto = args["userPhotoUrl"] as? String
        if (userMarker == null) {
          userMarker = map?.addMarker(
            MarkerOptions().position(pos).anchor(0.5f, 0.5f)
              .icon(BitmapDescriptorFactory.defaultMarker())
          )
        }
        userMarker?.position = pos
        userPhoto?.let { url ->
          loadIcon(url) { icon ->
            userMarker?.setIcon(icon ?: BitmapDescriptorFactory.defaultMarker())
          }
        }

        // destination marker (opcional)
        if (args.containsKey("destination")) {
          val dest = args["destination"] as Map<*, *>
          val dlat = (dest["latitude"] as Number).toDouble()
          val dlng = (dest["longitude"] as Number).toDouble()
          val dpos = LatLng(dlat, dlng)
          if (destMarker == null) {
            destMarker = map?.addMarker(MarkerOptions().position(dpos).anchor(0.5f, 1f))
          }
          destMarker?.position = dpos
        } else {
          destMarker?.remove(); destMarker = null
        }

        // drivers
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
            val mk = map?.addMarker(
              MarkerOptions().position(posD).anchor(0.5f, 0.5f).rotation(rotation).flat(true)
            )
            if (mk != null) {
              driverMarkers[id] = mk
              val iconUrl = if (type == "taxi")
                args["driverTaxiIconUrl"] as? String
              else
                args["driverDriverIconUrl"] as? String

              val cacheKey = "${type}_${iconUrl ?: ""}"
              val cached = iconCache[cacheKey]
              if (cached != null) {
                mk.setIcon(cached)
              } else if (!iconUrl.isNullOrEmpty()) {
                loadIcon(iconUrl) { icon ->
                  icon?.let { ico ->
                    iconCache[cacheKey] = ico
                    mk.setIcon(ico)
                  }
                }
              }
            }
          } else {
            marker.position = posD
            marker.rotation = rotation
          }
          existing.remove(id)
        }
        existing.forEach { id -> driverMarkers.remove(id)?.remove() }

        // route polyline
        val route = args["route"] as? List<*>
        if (!route.isNullOrEmpty()) {
          val pts = route.map {
            val p = it as Map<*, *>
            LatLng((p["latitude"] as Number).toDouble(), (p["longitude"] as Number).toDouble())
          }
          val color = ((args["routeColor"] as? Number)?.toInt()) ?: 0xFFFFC107.toInt()
          val width = ((args["routeWidth"] as? Number)?.toInt()) ?: 4
          if (routePolyline == null) {
            routePolyline = map?.addPolyline(
              PolylineOptions().color(color).width(width.toFloat()).addAll(pts)
            )
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

      // Implementações mínimas para evitar MissingPluginException
      "cameraTo" -> {
        val lat = (call.argument<Number>("latitude"))?.toDouble()
        val lng = (call.argument<Number>("longitude"))?.toDouble()
        val zoom = (call.argument<Number>("zoom"))?.toFloat()
        if (lat != null && lng != null) {
          val update = if (zoom != null)
            CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom)
          else
            CameraUpdateFactory.newLatLng(LatLng(lat, lng))
          map?.animateCamera(update)
          result.success(null)
        } else {
          result.error("bad_args", "latitude/longitude ausentes", null)
        }
      }

      "fitBounds" -> {
        val points = call.argument<List<Map<String, Number>>>("points").orEmpty()
        if (points.isNotEmpty()) {
          val builder = LatLngBounds.builder()
          points.forEach { p -> builder.include(LatLng(p["latitude"]!!.toDouble(), p["longitude"]!!.toDouble())) }
          val padding = (call.argument<Number>("padding")?.toInt()) ?: 0
          val bounds = builder.build()
          map?.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, padding))
        }
        result.success(null)
      }

      "setMarkers", "setPolylines", "setPolygons", "updateCarPosition" -> {
        result.success(null) // stubs por enquanto
      }

      else -> result.notImplemented()
    }
  }

  private fun loadIcon(url: String, onLoadedMainThread: (BitmapDescriptor?) -> Unit) {
    val cached = iconCache[url]
    if (cached != null) {
      mapView.post { onLoadedMainThread(cached) }
      return
    }
    thread {
      val icon = try {
        URL(url).openConnection().getInputStream().use { stream ->
          val bmp = BitmapFactory.decodeStream(stream)
          if (bmp != null) BitmapDescriptorFactory.fromBitmap(bmp) else null
        }
      } catch (_: Exception) {
        null
      }
      iconCache[url] = icon
      mapView.post { onLoadedMainThread(icon) }
    }
  }
}
