package com.quicky.ridebahamas

import android.content.Context
import android.view.View
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.MapsInitializer
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MarkerOptions
import com.google.android.gms.maps.model.PolylineOptions
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
        mapView.onResume()
        mapView.getMapAsync { g ->
            googleMap = g
            val lat = (params?.get("lat") as? Double) ?: 0.0
            val lng = (params?.get("lng") as? Double) ?: 0.0
            val zoom = (params?.get("zoom") as? Double) ?: 14.0
            g.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom.toFloat()))
            channel.invokeMethod("mapReady", null)
        }
        MapsInitializer.initialize(context)
    }

    override fun getView(): View = mapView

    override fun dispose() {
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
                    val pos = LatLng((m["lat"] as Number).toDouble(), (m["lng"] as Number).toDouble())
                    googleMap?.addMarker(MarkerOptions().position(pos))
                }
                result.success(null)
            }
            "setPolylines" -> {
                val pts = call.argument<List<List<Double>>>("polyline")
                val opts = PolylineOptions().color(0xff4285F4.toInt()).width(5f)
                pts?.forEach { p -> opts.add(LatLng(p[0], p[1])) }
                googleMap?.addPolyline(opts)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
