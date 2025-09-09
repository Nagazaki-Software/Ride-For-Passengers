package com.quicky.ridebahamas

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.view.View
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import com.google.android.gms.maps.model.Polyline
import com.google.android.gms.maps.model.PolylineOptions
import com.google.android.gms.maps.model.BitmapDescriptor
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.net.URL
import kotlin.concurrent.thread

class PickerMapNativeView(context: Context, messenger: BinaryMessenger, id: Int) :
    PlatformView, MethodChannel.MethodCallHandler, OnMapReadyCallback {

  private val mapView: MapView = MapView(context)
  private var map: GoogleMap? = null
  private val channel = MethodChannel(messenger, "picker_map_native_$id")

  private var userMarker: Marker? = null
  private var destMarker: Marker? = null
  private var routePolyline: Polyline? = null
  private val driverMarkers = mutableMapOf<String, Marker>()
  private val driverIconCache = mutableMapOf<String, BitmapDescriptor?>()

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
        val pos = LatLng(lat, lng)
        map?.moveCamera(CameraUpdateFactory.newLatLngZoom(pos, 14f))

        // user marker
        val userPhoto = args["userPhotoUrl"] as String?
        if (userMarker == null) {
          userMarker = map?.addMarker(
              MarkerOptions().position(pos).anchor(0.5f,0.5f))
        }
        userMarker?.position = pos
        userPhoto?.let { url ->
          thread {
            descriptorFromUrl(url)?.let { icon ->
              userMarker?.setIcon(icon)
            }
          }
        }

        // destination marker
        if (args.containsKey("destination")) {
          val dest = args["destination"] as Map<*, *>
          val dlat = dest["latitude"] as Double
          val dlng = dest["longitude"] as Double
          val dpos = LatLng(dlat, dlng)
          if (destMarker == null) {
            destMarker = map?.addMarker(
                MarkerOptions().position(dpos).anchor(0.5f,1f))
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
          val dlat = m["latitude"] as Double
          val dlng = m["longitude"] as Double
          val rotation = (m["rotation"] as? Double)?.toFloat() ?: 0f
          val type = m["type"]?.toString() ?: "driver"
          val marker = driverMarkers[id]
          val posD = LatLng(dlat, dlng)
          if (marker == null) {
            val opt = MarkerOptions().position(posD).anchor(0.5f,0.5f).rotation(rotation)
            val mk = map?.addMarker(opt)
            if (mk != null) {
              driverMarkers[id] = mk
              val iconUrl = if (type == "taxi") {
                args["driverTaxiIconUrl"] as? String
              } else {
                args["driverDriverIconUrl"] as? String
              }
              val cacheKey = "${type}_${iconUrl ?: ""}"
              val cached = driverIconCache[cacheKey]
              if (cached != null) {
                mk.setIcon(cached)
              } else if (iconUrl != null) {
                thread {
                  descriptorFromUrl(iconUrl)?.let { icon ->
                    driverIconCache[cacheKey] = icon
                    mk.setIcon(icon)
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
        if (route != null && route.isNotEmpty()) {
          val pts = route.map {
            val p = it as Map<*, *>
            LatLng(p["latitude"] as Double, p["longitude"] as Double)
          }
          val color = (args["routeColor"] as Int?) ?: 0xFFFFC107.toInt()
          val width = (args["routeWidth"] as Int?) ?: 4
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
      else -> result.notImplemented()
    }
  }

  private fun descriptorFromUrl(url: String?): BitmapDescriptor? {
    if (url == null || url.isEmpty()) return null
    return try {
      val stream = URL(url).openConnection().getInputStream()
      val bmp = BitmapFactory.decodeStream(stream)
      BitmapDescriptorFactory.fromBitmap(bmp)
    } catch (e: Exception) {
      null
    }
  }
}

