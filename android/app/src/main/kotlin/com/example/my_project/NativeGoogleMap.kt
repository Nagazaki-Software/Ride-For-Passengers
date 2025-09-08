package com.quicky.ridebahamas

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Bitmap
import android.view.View
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.MapsInitializer
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MarkerOptions
import com.google.android.gms.maps.model.PolylineOptions
import com.google.android.gms.maps.model.PolygonOptions
import com.google.android.gms.maps.model.MapStyleOptions
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class NativeGoogleMap(
    context: Context,
    messenger: BinaryMessenger,
    id: Int,
    params: Map<String, Any>?
) : PlatformView, MethodChannel.MethodCallHandler {

    private val mapView: MapView = MapView(context)
    private var googleMap: GoogleMap? = null
    private val channel = MethodChannel(messenger, "native_google_map_" + id)

    init {
        channel.setMethodCallHandler(this)
        mapView.onCreate(null)
        // Ensure the MapView lifecycle is properly started so the
        // GoogleMap instance can render correctly.
        // Some devices require onStart to be invoked before onResume.
        mapView.onStart()
        mapView.onResume()
        mapView.getMapAsync { g ->
            googleMap = g
            val lat = (params?.get("lat") as? Double) ?: 0.0
            val lng = (params?.get("lng") as? Double) ?: 0.0
            val zoom = (params?.get("zoom") as? Double) ?: 14.0
            g.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom.toFloat()))
            g.setOnMapClickListener { ll ->
                channel.invokeMethod("onTap", mapOf("lat" to ll.latitude, "lng" to ll.longitude))
            }
            g.setOnMapLongClickListener { ll ->
                channel.invokeMethod("onLongPress", mapOf("lat" to ll.latitude, "lng" to ll.longitude))
            }
            channel.invokeMethod("mapReady", null)
        }
        MapsInitializer.initialize(context)
    }

    override fun getView(): View = mapView

    override fun dispose() {
        // Mirror the lifecycle methods called in init to avoid
        // memory leaks and ensure the map cleans up correctly.
        mapView.onPause()
        mapView.onStop()
        mapView.onDestroy()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "moveCamera" -> {
                val lat = call.argument<Double>("lat") ?: 0.0
                val lng = call.argument<Double>("lng") ?: 0.0
                val zoom = call.argument<Double>("zoom") ?: 14.0
                googleMap?.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom.toFloat()))
                result.success(null)
            }
            "setMarkers" -> {
                val markers = call.argument<List<Map<String, Any>>>("markers")
                googleMap?.clear()
                markers?.forEach { m ->
                    val lat = (m["lat"] as Number).toDouble()
                    val lng = (m["lng"] as Number).toDouble()
                    val rotation = (m["rotation"] as Number?)?.toFloat() ?: 0f
                    val bytes = m["icon"] as? ByteArray
                    val opts = MarkerOptions().position(LatLng(lat, lng)).rotation(rotation).anchor(0.5f, 0.5f).flat(true)
                    bytes?.let {
                        val bmp = BitmapFactory.decodeByteArray(it, 0, it.size)
                        opts.icon(BitmapDescriptorFactory.fromBitmap(bmp))
                    }
                    googleMap?.addMarker(opts)
                }
                result.success(null)
            }
            "setPolylines" -> {
                val pts = call.argument<List<List<Double>>>("polyline")
                val color = call.argument<Int>("color") ?: 0xff4285F4.toInt()
                val width = (call.argument<Double>("width") ?: 5.0).toFloat()
                val opts = PolylineOptions().color(color).width(width)
                pts?.forEach { p -> opts.add(LatLng(p[0], p[1])) }
                googleMap?.addPolyline(opts)
                result.success(null)
            }
            "setPolygons" -> {
                val polys = call.argument<List<List<List<Double>>>>("polygons")
                val strokeColor = call.argument<Int>("strokeColor") ?: 0xff4285F4.toInt()
                val fillColor = call.argument<Int>("fillColor") ?: 0x554285F4
                val strokeWidth = (call.argument<Double>("strokeWidth") ?: 1.0).toFloat()
                polys?.forEach { poly ->
                    val opts = PolygonOptions().strokeColor(strokeColor).fillColor(fillColor).strokeWidth(strokeWidth)
                    poly.forEach { p -> opts.add(LatLng(p[0], p[1])) }
                    googleMap?.addPolygon(opts)
                }
                result.success(null)
            }
            "setMapStyle" -> {
                val style = call.argument<String>("style")
                googleMap?.setMapStyle(style?.let { MapStyleOptions(it) })
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
