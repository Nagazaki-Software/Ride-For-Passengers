package com.quicky.ridebahamas

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.ViewTreeObserver
import android.view.animation.LinearInterpolator
import android.widget.FrameLayout
import com.google.android.gms.maps.*
import com.google.android.gms.maps.model.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import org.json.JSONArray
import org.json.JSONObject
import kotlin.math.abs

class PickerMapNativeView(
    private val ctx: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    creationParams: Map<*, *>?
) : PlatformView, MethodChannel.MethodCallHandler, OnMapReadyCallback, GoogleMap.OnMapLoadedCallback {

    private val channel = MethodChannel(messenger, "picker_map_native_$viewId")
    private val container = FrameLayout(ctx)
    private val mapView = MapView(ctx)
    private var googleMap: GoogleMap? = null

    private var userMarker: Marker? = null
    private var destMarker: Marker? = null
    private var routePolyline: Polyline? = null
    private val polygons = mutableListOf<Polygon>()
    private val dynamicMarkers = hashMapOf<String, Marker>()

    private var lastConfig: Map<*, *>? = null

    init {
        channel.setMethodCallHandler(this)

        container.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        container.addView(mapView)

        mapView.onCreate(Bundle())
        mapView.getMapAsync(this)

        // Workaround para garantir layout correto (logs de tamanho como no seu print)
        container.viewTreeObserver.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener {
            override fun onGlobalLayout() {
                val w = container.width
                val h = container.height
                dbg("sizes: container=${w}x$h mapView=${mapView.width}x${mapView.height}")
                if (w > 0 && h > 0) {
                    container.viewTreeObserver.removeOnGlobalLayoutListener(this)
                }
            }
        })

        // Params iniciais opcionais
        creationParams?.let {
            val user = it["initialUserLocation"] as? Map<*, *>
            if (user != null) {
                val lat = (user["latitude"] as Number).toDouble()
                val lng = (user["longitude"] as Number).toDouble()
                lastConfig = mapOf("userLocation" to mapOf("latitude" to lat, "longitude" to lng))
            }
        }
    }

    // ========= PlatformView =========
    override fun getView(): View = container
    override fun dispose() {
        channel.setMethodCallHandler(null)
        googleMap?.setOnMapLoadedCallback(null)
        mapView.onPause()
        mapView.onStop()
        mapView.onDestroy()
    }

    // ========= Map callbacks =========
    override fun onMapReady(map: GoogleMap) {
        googleMap = map
        dbg("onMapReady")

        // Renderer LATEST e callbacks
        MapsInitializer.initialize(ctx, MapsInitializer.Renderer.LATEST) { renderer ->
            dbg("MapsInitializer renderer=$renderer")
        }

        googleMap?.setOnMapLoadedCallback(this)

        // Estilo inicial (se veio via creationParams)
        val styleJson = (lastConfig?.get("mapStyleJson") as? String)
        if (!styleJson.isNullOrBlank()) {
            try {
                googleMap?.setMapStyle(MapStyleOptions(styleJson))
            } catch (t: Throwable) {
                dbge("setMapStyle initial error", t)
            }
        }

        // Aplica config se já tínhamos algo
        lastConfig?.let { applyConfig(it) }
    }

    override fun onMapLoaded() {
        dbg("onMapLoaded (tiles renderizados)")
        channel.invokeMethod("platformReady", null)
    }

    // ========= MethodChannel =========
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "updateConfig" -> {
                    val cfg = call.arguments as Map<*, *>
                    applyConfig(cfg)
                    ok(result)
                }
                "setMarkers" -> {
                    val list = call.arguments as List<*>
                    setMarkers(list)
                    ok(result)
                }
                "setPolylines" -> {
                    val list = call.arguments as List<*>
                    setPolylines(list)
                    ok(result)
                }
                "setPolygons" -> {
                    val list = call.arguments as List<*>
                    setPolygons(list)
                    ok(result)
                }
                "cameraTo" -> {
                    val m = call.arguments as Map<*, *>
                    val lat = (m["latitude"] as Number).toDouble()
                    val lng = (m["longitude"] as Number).toDouble()
                    val zoom = (m["zoom"] as? Number)?.toFloat()
                    val bearing = (m["bearing"] as? Number)?.toFloat()
                    val tilt = (m["tilt"] as? Number)?.toFloat()
                    cameraTo(lat, lng, zoom, bearing, tilt)
                    ok(result)
                }
                "fitBounds" -> {
                    val m = call.arguments as Map<*, *>
                    @Suppress("UNCHECKED_CAST")
                    val points = (m["points"] as List<Map<String, Number>>).map {
                        LatLng(it["latitude"]!!.toDouble(), it["longitude"]!!.toDouble())
                    }
                    val padding = (m["padding"] as? Number)?.toInt() ?: 0
                    fitBounds(points, padding)
                    ok(result)
                }
                "updateCarPosition" -> {
                    val m = call.arguments as Map<*, *>
                    val id = m["id"].toString()
                    val lat = (m["latitude"] as Number).toDouble()
                    val lng = (m["longitude"] as Number).toDouble()
                    val rotation = (m["rotation"] as? Number)?.toFloat()
                    val duration = (m["durationMs"] as? Number)?.toInt() ?: 1200
                    updateCarPosition(id, LatLng(lat, lng), rotation, duration)
                    ok(result)
                }
                "debugInfo" -> {
                    result.success(mapOf("mapReady" to (googleMap != null)))
                }
                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            dbge("onMethodCall ${call.method} error", t)
            result.error("err", t.message, null)
        }
    }

    private fun ok(result: MethodChannel.Result) = result.success(null)

    // ========= Actions =========
    private fun cameraTo(lat: Double, lng: Double, zoom: Float?, bearing: Float?, tilt: Float?) {
        val map = googleMap ?: run { dbg("cameraTo antes do onMapReady"); return }
        val cam = CameraPosition.Builder()
            .target(LatLng(lat, lng))
            .apply { if (zoom != null) zoom(zoom) }
            .apply { if (bearing != null) bearing(bearing) }
            .apply { if (tilt != null) tilt(tilt) }
            .build()
        map.animateCamera(CameraUpdateFactory.newCameraPosition(cam))
    }

    private fun fitBounds(points: List<LatLng>, padding: Int) {
        val map = googleMap ?: run { dbg("fitBounds antes do onMapReady"); return }
        if (points.isEmpty()) return
        val b = LatLngBounds.Builder()
        points.forEach { b.include(it) }
        map.animateCamera(CameraUpdateFactory.newLatLngBounds(b.build(), padding))
    }

    private fun applyConfig(cfg: Map<*, *>) {
        lastConfig = cfg
        val map = googleMap ?: run { dbg("applyConfig antes do onMapReady"); return }

        // Estilo (dark) se vier JSON
        (cfg["mapStyleJson"] as? String)?.let { json ->
            try {
                map.setMapStyle(MapStyleOptions(json))
                dbg("dark style aplicado")
            } catch (t: Throwable) {
                dbge("setMapStyle error", t)
            }
        }

        // Usuário
        val user = cfg["userLocation"] as? Map<*, *>
        user?.let {
            val lat = (it["latitude"] as Number).toDouble()
            val lng = (it["longitude"] as Number).toDouble()
            if (userMarker == null) {
                userMarker = map.addMarker(
                    MarkerOptions()
                        .position(LatLng(lat, lng))
                        .title("Você")
                        .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_AZURE))
                )
                cameraTo(lat, lng, 16f, null, null)
            } else {
                userMarker!!.position = LatLng(lat, lng)
            }
        }

        // Destino
        val dest = cfg["destination"] as? Map<*, *>
        dest?.let {
            val lat = (it["latitude"] as Number).toDouble()
            val lng = (it["longitude"] as Number).toDouble()
            if (destMarker == null) {
                destMarker = map.addMarker(
                    MarkerOptions()
                        .position(LatLng(lat, lng))
                        .title("Destino")
                        .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED))
                )
            } else {
                destMarker!!.position = LatLng(lat, lng)
            }
        } ?: run {
            destMarker?.remove(); destMarker = null
        }

        // Rota (se vier)
        val route = cfg["route"] as? List<*>
        val routeColor = (cfg["routeColor"] as? Number)?.toInt() ?: Color.YELLOW
        val routeWidth = (cfg["routeWidth"] as? Number)?.toFloat() ?: 6f
        if (route != null && route.isNotEmpty()) {
            val pts = route.mapNotNull {
                val m = it as? Map<*, *> ?: return@mapNotNull null
                val la = (m["latitude"] as Number).toDouble()
                val lo = (m["longitude"] as Number).toDouble()
                LatLng(la, lo)
            }
            drawPolyline(pts, routeColor, routeWidth, animate = (cfg["enableRouteSnake"] as? Boolean) == true)
        }
    }

    private fun setMarkers(list: List<*>) {
        val map = googleMap ?: return
        list.forEach { any ->
            val m = any as? Map<*, *> ?: return@forEach
            val id = (m["id"] ?: "marker_${dynamicMarkers.size + 1}").toString()
            val lat = (m["latitude"] as Number).toDouble()
            val lng = (m["longitude"] as Number).toDouble()
            val title = m["title"]?.toString()
            val hue = (m["hue"] as? Number)?.toFloat()
            val icon: BitmapDescriptor = if (hue != null) {
                BitmapDescriptorFactory.defaultMarker(hue)
            } else {
                BitmapDescriptorFactory.defaultMarker()
            }
            dynamicMarkers[id]?.remove()
            dynamicMarkers[id] = map.addMarker(
                MarkerOptions().position(LatLng(lat, lng)).apply {
                    if (!title.isNullOrBlank()) title(title)
                    icon(icon)
                }
            )!!
        }
    }

    private fun setPolylines(list: List<*>) {
        if (list.isEmpty()) return
        val first = list.first() as? Map<*, *> ?: return
        val color = (first["color"] as? Number)?.toInt() ?: Color.YELLOW
        val width = (first["width"] as? Number)?.toFloat() ?: 6f
        val pts = (first["points"] as? List<*>)?.mapNotNull {
            val m = it as? Map<*, *> ?: return@mapNotNull null
            LatLng(
                (m["latitude"] as Number).toDouble(),
                (m["longitude"] as Number).toDouble()
            )
        } ?: emptyList()
        drawPolyline(pts, color, width, animate = true)
    }

    private fun drawPolyline(points: List<LatLng>, color: Int, width: Float, animate: Boolean) {
        val map = googleMap ?: return
        routePolyline?.remove()
        if (points.isEmpty()) return
        if (!animate) {
            routePolyline = map.addPolyline(
                PolylineOptions()
                    .addAll(points)
                    .color(color)
                    .width(width)
                    .zIndex(2f)
            )
            return
        }
        // Efeito "snake"
        val animator = ValueAnimator.ofInt(0, points.size - 1)
        animator.duration = (800 + points.size * 15).toLong()
        animator.interpolator = LinearInterpolator()
        routePolyline = map.addPolyline(
            PolylineOptions()
                .color(color)
                .width(width)
                .zIndex(2f)
        )
        animator.addUpdateListener { va ->
            val idx = (va.animatedValue as Int).coerceIn(0, points.size - 1)
            routePolyline?.points = points.subList(0, idx + 1)
        }
        animator.start()
    }

    private fun setPolygons(list: List<*>) {
        val map = googleMap ?: return
        polygons.forEach { it.remove() }
        polygons.clear()

        list.forEach { any ->
            val m = any as? Map<*, *> ?: return@forEach
            val strokeColor = (m["strokeColor"] as? Number)?.toInt() ?: Color.WHITE
            val fillColor = (m["fillColor"] as? Number)?.toInt() ?: 0x22FFFFFF
            val width = (m["strokeWidth"] as? Number)?.toFloat() ?: 2f
            val pts = (m["points"] as? List<*>)?.mapNotNull {
                val p = it as? Map<*, *> ?: return@mapNotNull null
                LatLng((p["latitude"] as Number).toDouble(), (p["longitude"] as Number).toDouble())
            } ?: emptyList()
            if (pts.size >= 3) {
                polygons += map.addPolygon(
                    PolygonOptions()
                        .addAll(pts)
                        .strokeColor(strokeColor)
                        .strokeWidth(width)
                        .fillColor(fillColor)
                        .zIndex(1f)
                )
            }
        }
    }

    private fun updateCarPosition(id: String, pos: LatLng, rotation: Float?, duration: Int) {
        val map = googleMap ?: return
        val marker = dynamicMarkers[id] ?: run {
            // cria se não existe
            val mk = map.addMarker(
                MarkerOptions()
                    .position(pos)
                    .anchor(0.5f, 0.5f)
                    .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_ORANGE))
                    .flat(true)
                    .zIndex(3f)
            )
            dynamicMarkers[id] = mk!!
            mk
        }

        // anima posição
        val start = marker.position
        if (abs(start.latitude - pos.latitude) < 1e-9 && abs(start.longitude - pos.longitude) < 1e-9) {
            rotation?.let { marker.rotation = it }
            return
        }
        val va = ValueAnimator.ofFloat(0f, 1f).apply {
            this.duration = duration.toLong()
            interpolator = LinearInterpolator()
        }
        va.addUpdateListener {
            val t = it.animatedFraction
            val lat = start.latitude + (pos.latitude - start.latitude) * t
            val lng = start.longitude + (pos.longitude - start.longitude) * t
            marker.position = LatLng(lat, lng)
            rotation?.let { r -> marker.rotation = r }
        }
        va.start()
    }

    // ========= Logs helper =========
    private fun dbg(msg: String) {
        Log.d("KT/PickerMap", msg)
        try { channel.invokeMethod("debugLog", mapOf("level" to "D", "msg" to msg)) } catch (_: Throwable) {}
    }

    private fun dbge(msg: String, t: Throwable) {
        Log.e("KT/PickerMap", msg, t)
        try { channel.invokeMethod("debugLog", mapOf("level" to "E", "msg" to "$msg: ${t.message}")) } catch (_: Throwable) {}
    }
}
