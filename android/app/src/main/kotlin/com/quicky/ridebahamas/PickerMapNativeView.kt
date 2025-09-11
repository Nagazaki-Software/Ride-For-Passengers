package com.quicky.ridebahamas

import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.webkit.WebSettings
import android.webkit.WebView
import android.widget.FrameLayout
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.MapsInitializer
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.model.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class PickerMapNativeView(
  private val ctx: Context,
  messenger: BinaryMessenger,
  id: Int,
  creationParams: Any? // <- recebendo do Flutter
) : PlatformView, MethodChannel.MethodCallHandler, OnMapReadyCallback {

  private val tag = "PickerMap"
  private val container = FrameLayout(ctx)
  private val mapView = MapView(ctx)
  private var googleMap: GoogleMap? = null
  private val channel = MethodChannel(messenger, "picker_map_native_$id")

  private var userMarker: Marker? = null
  private var destMarker: Marker? = null
  private var routePolyline: Polyline? = null

  // params recebidos do Flutter (para usar no fallback)
  private val initialUserLat: Double?
  private val initialUserLng: Double?

  // watchdog p/ forçar fallback se onMapReady não vier
  private val handler = Handler(Looper.getMainLooper())
  private var fallbackPosted = false
  private var webFallbackUsed = false

  init {
    Log.d(tag, "PickerMapNativeView init, id=$id")
    channel.setMethodCallHandler(this)

    // lê initialUserLocation dos creationParams
    var lat: Double? = null
    var lng: Double? = null
    try {
      val params = creationParams as? Map<*, *>
      val init = params?.get("initialUserLocation") as? Map<*, *>
      lat = (init?.get("latitude") as? Number)?.toDouble()
      lng = (init?.get("longitude") as? Number)?.toDouble()
    } catch (t: Throwable) {
      Log.e(tag, "Erro lendo creationParams", t)
    }
    initialUserLat = lat
    initialUserLng = lng

    // Inicializa Maps SDK
    try {
      MapsInitializer.initialize(ctx.applicationContext)
    } catch (t: Throwable) {
      Log.e(tag, "MapsInitializer error", t)
    }

    // Cria MapView e pede onMapReady
    mapView.onCreate(null)
    mapView.onStart()
    mapView.onResume()
    mapView.getMapAsync(this)

    container.addView(
      mapView,
      FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT
      )
    )

    // Se o nativo não chamar onMapReady rápido, cai no WebView com JS API
    postFallbackWatchdog()
  }

  private fun postFallbackWatchdog() {
    if (fallbackPosted) return
    fallbackPosted = true
    handler.postDelayed({
      if (googleMap == null && !webFallbackUsed) {
        Log.w(tag, "onMapReady timeout — ativando fallback WebView (JS API)")
        useWebFallback()
      }
    }, 4000) // 4s
  }

  override fun getView() = container

  override fun dispose() {
    Log.d(tag, "dispose")
    channel.setMethodCallHandler(null)
    mapView.onPause()
    mapView.onStop()
    mapView.onDestroy()
  }

  // ===== OnMapReady =====
  override fun onMapReady(map: GoogleMap) {
    Log.d(tag, "onMapReady")
    googleMap = map
    googleMap?.uiSettings?.isCompassEnabled = true
    googleMap?.uiSettings?.isMyLocationButtonEnabled = false
    googleMap?.isBuildingsEnabled = true
    // googleMap?.isMyLocationEnabled = false // ative só se concedida permissão

    // Se o Map nativo ficou pronto, não precisamos do fallback
    webFallbackUsed = false

    // avisa o Dart para reenviar updateConfig
    channel.invokeMethod("platformReady", null)
  }

  // ===== Recebe comandos do Dart =====
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "updateConfig" -> {
        try {
          val args = call.arguments as Map<*, *>
          if (googleMap != null) {
            applyConfig(args)
          } else if (!webFallbackUsed) {
            // ainda não está pronto — aguarda mais um pouco antes de cair no fallback
            postFallbackWatchdog()
          } else {
            // já estamos no WebView — tenta aplicar via JS
            applyConfigOnWeb(args)
          }
          result.success(null)
        } catch (t: Throwable) {
          Log.e(tag, "updateConfig error", t)
          result.error("updateConfig", t.message, null)
        }
      }
      "setMarkers" -> {
        try {
          val list = call.arguments as List<*>
          if (googleMap != null) setMarkers(list) else applyMarkersOnWeb(list)
          result.success(null)
        } catch (t: Throwable) {
          Log.e(tag, "setMarkers error", t)
          result.error("setMarkers", t.message, null)
        }
      }
      "setPolylines" -> {
        try {
          val list = call.arguments as List<*>
          if (googleMap != null) setPolylines(list) else applyPolylinesOnWeb(list)
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
          if (googleMap != null) {
            googleMap?.animateCamera(
              CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom)
            )
          } else {
            evalJs("""cameraTo($lat,$lng,$zoom);""")
          }
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
          if (googleMap != null) {
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
          } else {
            val jsPoints = points.joinToString(
              prefix = "[", postfix = "]"
            ) { p ->
              val m = p as Map<*, *>
              val la = (m["latitude"] as Number).toDouble()
              val lo = (m["longitude"] as Number).toDouble()
              "{lat:$la,lng:$lo}"
            }
            evalJs("""fitBounds($jsPoints,$padding);""")
          }
          result.success(null)
        } catch (t: Throwable) {
          Log.e(tag, "fitBounds error", t)
          result.error("fitBounds", t.message, null)
        }
      }
      else -> result.notImplemented()
    }
  }

  // ===== Helpers (Nativo) =====
  private fun applyConfig(cfg: Map<*, *>) {
    val map = googleMap ?: return

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

  // ===== Fallback WebView (JS API) =====
  private var webView: WebView? = null

  private fun useWebFallback() {
    val apiKey = readApiKeyFromManifest()
    if (apiKey.isNullOrBlank()) {
      Log.e(tag, "API KEY não encontrada para fallback WebView.")
      return
    }
    webFallbackUsed = true

    val html = buildHtml(apiKey,
      initialUserLat ?: 25.0343, // Nassau default se não vier
      initialUserLng ?: -77.3963
    )

    val wv = WebView(ctx)
    webView = wv
    val s: WebSettings = wv.settings
    s.javaScriptEnabled = true
    s.domStorageEnabled = true
    s.useWideViewPort = true
    s.loadWithOverviewMode = true

    container.removeAllViews()
    container.addView(
      wv,
      FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT
      )
    )
    wv.loadDataWithBaseURL(
      "https://maps.googleapis.com/",
      html, "text/html", "UTF-8", null
    )

    // informa ao Dart que “está pronto”
    channel.invokeMethod("platformReady", null)
  }

  private fun buildHtml(key: String, lat: Double, lng: Double): String {
    // funções JS mínimas para espelhar alguns comandos
    return """
<!DOCTYPE html><html><head><meta name="viewport" content="initial-scale=1, width=device-width">
<style>html,body,#map{height:100%;margin:0;padding:0}</style>
<script>
let map, userMarker, routePolyline;
function initMap(){
  const pos = {lat:$lat,lng:$lng};
  map = new google.maps.Map(document.getElementById('map'), {
    center: pos, zoom: 15, disableDefaultUI: false
  });
  userMarker = new google.maps.Marker({position: pos, map, title:'You'});
}
function updateConfig(cfg){
  if(cfg.userLocation){
    const p = {lat:cfg.userLocation.latitude, lng:cfg.userLocation.longitude};
    userMarker.setPosition(p);
    map.setCenter(p);
  }
  if(cfg.destination){
    if(!window.destMarker){
      window.destMarker = new google.maps.Marker({
        position:{lat:cfg.destination.latitude, lng:cfg.destination.longitude},
        map, title:'Destination'
      });
    }else{
      destMarker.setPosition({lat:cfg.destination.latitude, lng:cfg.destination.longitude});
    }
  }else if(window.destMarker){ destMarker.setMap(null); destMarker=null; }

  if(routePolyline){ routePolyline.setMap(null); routePolyline=null; }
  if(cfg.route && cfg.route.length>=2){
    const path = cfg.route.map(p => ({lat:p.latitude, lng:p.longitude}));
    routePolyline = new google.maps.Polyline({
      path, strokeColor:'#${String.format("%06X", (0xFFFFFF and (cfg.routeColor||0xFFC107)))}',
      strokeOpacity:1.0, strokeWeight: (cfg.routeWidth||4)
    });
    routePolyline.setMap(map);
  }
}
function cameraTo(lat,lng,zoom){ map.setZoom(zoom||15); map.panTo({lat:lat,lng:lng}); }
function fitBounds(points,padding){
  const b = new google.maps.LatLngBounds();
  points.forEach(p => b.extend(new google.maps.LatLng(p.lat,p.lng)));
  map.fitBounds(b, padding||0);
}
</script>
</head>
<body>
<div id="map"></div>
<script src="https://maps.googleapis.com/maps/api/js?key=$key&callback=initMap" async defer></script>
</body></html>
""".trimIndent()
  }

  private fun readApiKeyFromManifest(): String? {
    return try {
      val ai = ctx.packageManager.getApplicationInfo(ctx.packageName, PackageManager.GET_META_DATA)
      val meta = ai.metaData
      meta.getString("com.google.android.geo.API_KEY")
    } catch (t: Throwable) {
      Log.e(tag, "readApiKeyFromManifest error", t)
      null
    }
  }

  private fun evalJs(js: String) {
    webView?.post { webView?.evaluateJavascript(js, null) }
  }

  private fun applyConfigOnWeb(cfg: Map<*, *>) {
    val json = toJsConfig(cfg)
    evalJs("updateConfig($json);")
  }

  private fun applyMarkersOnWeb(list: List<*>) {
    // exemplo simples: converta para polyline para visual (ou crie markers JS próprio)
    // aqui não é estritamente necessário para o app atual
  }

  private fun applyPolylinesOnWeb(list: List<*>) {
    // idem acima; mantemos a rota principal via updateConfig
  }

  private fun toJsConfig(cfg: Map<*, *>): String {
    fun mapToJs(m: Map<*, *>): String {
      val lat = (m["latitude"] as Number).toDouble()
      val lng = (m["longitude"] as Number).toDouble()
      return "{latitude:$lat,longitude:$lng}"
    }
    val sb = StringBuilder("{")
    (cfg["userLocation"] as? Map<*, *>)?.let {
      sb.append("userLocation:${mapToJs(it)},")
    }
    (cfg["destination"] as? Map<*, *>)?.let {
      sb.append("destination:${mapToJs(it)},")
    }
    (cfg["route"] as? List<*>)?.let { list ->
      val pts = list.mapNotNull { p ->
        (p as? Map<*, *>)?.let {
          val la = (it["latitude"] as Number).toDouble()
          val lo = (it["longitude"] as Number).toDouble()
          "{latitude:$la,longitude:$lo}"
        }
      }.joinToString(prefix = "[", postfix = "]")
      sb.append("route:$pts,")
    }
    val color = (cfg["routeColor"] as? Number)?.toLong() ?: 0xFFFFC107
    val width = (cfg["routeWidth"] as? Number)?.toInt() ?: 4
    sb.append("routeColor:$color,routeWidth:$width")
    sb.append("}")
    return sb.toString()
  }
}
