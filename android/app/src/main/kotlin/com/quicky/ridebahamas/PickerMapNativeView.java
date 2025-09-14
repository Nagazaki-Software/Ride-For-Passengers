package com.quicky.ridebahamas;

import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.animation.LinearInterpolator;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.MapStyleOptions;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.Polygon;
import com.google.android.gms.maps.model.PolygonOptions;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class PickerMapNativeView implements PlatformView, MethodChannel.MethodCallHandler, OnMapReadyCallback {

    private static final String TAG = "KT";
    private static void dbg(String m){ Log.d(TAG + "/D", m); }
    private static void dbge(String m, Throwable t){ Log.e(TAG + "/E", m, t); }

    private final Context ctx;
    private final int viewId;
    private final BinaryMessenger messenger;
    @SuppressWarnings("rawtypes")
    private final Map creationParams;

    private final FrameLayout container;
    private final MapView mapView;
    @Nullable private GoogleMap googleMap;
    private final MethodChannel channel;

    // Estado
    private final Map<String, Marker> carMarkers = new HashMap<>();
    private final Map<String, Polyline> polylineMap = new HashMap<>();
    private final Map<String, Polygon> polygonMap = new HashMap<>();
    private final List<Marker> genericMarkers = new ArrayList<>();

    @SuppressWarnings("rawtypes")
    public PickerMapNativeView(Context context, int id, BinaryMessenger messenger, Map creationParams) {
        this.ctx = context;
        this.viewId = id;
        this.messenger = messenger;
        this.creationParams = creationParams != null ? creationParams : new HashMap();

        this.container = new FrameLayout(context);

        // Evita a confusão da API do MapsInitializer (usar a forma simples)
        try { MapsInitializer.initialize(context.getApplicationContext()); } catch (Throwable ignore) {}

        this.mapView = new MapView(context);
        mapView.onCreate(null);
        mapView.onResume();

        container.addView(mapView, new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
        ));

        container.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override public void onGlobalLayout() {
                dbg("sizes: container=" + container.getWidth() + "x" + container.getHeight()
                        + " mapView=" + mapView.getWidth() + "x" + mapView.getHeight());
                if (Math.max(container.getWidth(), container.getHeight()) > 0) {
                    container.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                }
            }
        });

        channel = new MethodChannel(messenger, "picker_map_native/" + id);
        channel.setMethodCallHandler(this);

        mapView.getMapAsync(this);
    }

    // PlatformView
    @NonNull @Override public View getView() { return container; }

    @Override public void dispose() {
        try {
            if (googleMap != null) googleMap.setOnMapLoadedCallback(null);
            googleMap = null;
            for (Marker m : genericMarkers) m.remove();
            genericMarkers.clear();
            for (Marker m : carMarkers.values()) m.remove();
            carMarkers.clear();
            for (Polyline p : polylineMap.values()) p.remove();
            polylineMap.clear();
            for (Polygon p : polygonMap.values()) p.remove();
            polygonMap.clear();
            mapView.onPause();
            mapView.onDestroy();
            channel.setMethodCallHandler(null);
        } catch (Throwable ignore) {}
    }

    // OnMapReady
    @Override public void onMapReady(@NonNull GoogleMap map) {
        dbg("onMapReady");
        this.googleMap = map;

        applyDarkStyle(map);

        map.getUiSettings().setCompassEnabled(true);
        map.getUiSettings().setMapToolbarEnabled(false);
        map.getUiSettings().setRotateGesturesEnabled(true);
        map.getUiSettings().setTiltGesturesEnabled(true);
        map.getUiSettings().setMyLocationButtonEnabled(false);

        try { map.setMyLocationEnabled(false); } catch (SecurityException ignore) {}

        // Camera inicial (se vier nos creationParams)
        Double initLat = asDouble(creationParams.get("initialLat"));
        Double initLng = asDouble(creationParams.get("initialLng"));
        Float initZoom = asFloat(creationParams.get("initialZoom"));
        if (initZoom == null) initZoom = 15f;

        if (initLat != null && initLng != null) {
            map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(initLat, initLng), initZoom));
            dbg("initialUserLocation aplicada: (" + initLat + "," + initLng + ")");
        }

        dbg("MapView lifecycle ok (create/start/resume)");

        map.setOnMapLoadedCallback(new GoogleMap.OnMapLoadedCallback() {
            @Override public void onMapLoaded() { dbg("onMapLoaded (tiles renderizados)"); }
        });

        channel.invokeMethod("platformReady", null);
        dbg("KT → Dart: platformReady");
    }

    // MethodChannel
    @Override public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        try {
            switch (call.method) {
                case "updateConfig": {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> m = call.arguments instanceof Map ? (Map<String, Object>) call.arguments : new HashMap<>();
                    applyConfig(m);
                    result.success(null);
                    break;
                }
                case "setMarkers": {
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> list = call.arguments instanceof List ? (List<Map<String, Object>>) call.arguments : new ArrayList<>();
                    setMarkers(list);
                    result.success(null);
                    break;
                }
                case "setPolylines": {
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> list = call.arguments instanceof List ? (List<Map<String, Object>>) call.arguments : new ArrayList<>();
                    setPolylines(list);
                    result.success(null);
                    break;
                }
                case "setPolygons": {
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> list = call.arguments instanceof List ? (List<Map<String, Object>>) call.arguments : new ArrayList<>();
                    setPolygons(list);
                    result.success(null);
                    break;
                }
                case "cameraTo": {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> a = call.arguments instanceof Map ? (Map<String, Object>) call.arguments : new HashMap<>();
                    Double lat = asDouble(a.get("lat"));
                    Double lng = asDouble(a.get("lng"));
                    Float zoom = asFloat(a.get("zoom")); if (zoom == null) zoom = 16f;
                    Float bearing = asFloat(a.get("bearing")); if (bearing == null) bearing = 0f;
                    Float tilt = asFloat(a.get("tilt")); if (tilt == null) tilt = 0f;
                    if (lat != null && lng != null) cameraTo(lat, lng, zoom, bearing, tilt);
                    result.success(null);
                    break;
                }
                case "fitBounds": {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> a = call.arguments instanceof Map ? (Map<String, Object>) call.arguments : new HashMap<>();
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> pts = a.get("points") instanceof List ? (List<Map<String, Object>>) a.get("points") : new ArrayList<>();
                    Integer padding = a.get("padding") instanceof Number ? ((Number) a.get("padding")).intValue() : 80;
                    fitBounds(pts, padding);
                    result.success(null);
                    break;
                }
                case "updateCarPosition": {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> a = call.arguments instanceof Map ? (Map<String, Object>) call.arguments : new HashMap<>();
                    String id = a.get("id") instanceof String ? (String) a.get("id") : "car";
                    Double lat = asDouble(a.get("lat"));
                    Double lng = asDouble(a.get("lng"));
                    Float rotation = asFloat(a.get("rotation")); if (rotation == null) rotation = 0f;
                    Long duration = a.get("duration") instanceof Number ? ((Number) a.get("duration")).longValue() : 800L;
                    if (lat != null && lng != null) {
                        updateCarPosition(id, new LatLng(lat, lng), rotation, duration);
                    }
                    result.success(null);
                    break;
                }
                default:
                    result.notImplemented();
            }
        } catch (Throwable t) {
            dbge("onMethodCall " + call.method + " error", t);
            result.error("error", t.getMessage(), null);
        }
    }

    // --- Helpers ---

    private void applyDarkStyle(GoogleMap map) {
        String nightJson =
                "[" +
                "{\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#1d2c4d\"}]}," +
                "{\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#8ec3b9\"}]}," +
                "{\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#1a3646\"}]}," +
                "{\"featureType\":\"administrative.country\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#4b6878\"}]}," +
                "{\"featureType\":\"administrative.province\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#4b6878\"}]}," +
                "{\"featureType\":\"landscape.natural\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#023e58\"}]}," +
                "{\"featureType\":\"poi\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#283d6a\"}]}," +
                "{\"featureType\":\"poi.park\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#023e58\"}]}," +
                "{\"featureType\":\"road\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#304a7d\"}]}," +
                "{\"featureType\":\"road.highway\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#2c6675\"}]}," +
                "{\"featureType\":\"water\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#0e1626\"}]}" +
                "]";
        try { map.setMapStyle(new MapStyleOptions(nightJson)); } catch (Throwable ignore) {}
    }

    private void applyConfig(@NonNull Map<String, Object> cfg) {
        GoogleMap map = googleMap;
        if (map == null) { dbg("applyConfig antes do onMapReady"); return; }

        boolean user = getBool(cfg, "user", true);
        if (!user) user = getBool(cfg, "showUser", false);

        try { map.setMyLocationEnabled(user); }
        catch (SecurityException ignore) { map.setMyLocationEnabled(false); }

        boolean dest = getBool(cfg, "dest", false);
        boolean route = getBool(cfg, "route", false);
        dbg("applyConfig ok: user=" + user + " dest=" + dest + " route=" + route);
    }

    private void setMarkers(@NonNull List<Map<String, Object>> items) {
        GoogleMap map = googleMap; if (map == null) return;

        for (Marker m : genericMarkers) m.remove();
        genericMarkers.clear();

        for (Map<String, Object> it : items) {
            Double lat = asDouble(it.get("lat"));
            Double lng = asDouble(it.get("lng"));
            if (lat == null || lng == null) continue;

            String title = it.get("title") instanceof String ? (String) it.get("title") : null;

            MarkerOptions mo = new MarkerOptions()
                    .position(new LatLng(lat, lng))
                    .title(title);

            // se quiser custom icon por URL/base64 no futuro, tratar aqui

            Marker mk = map.addMarker(mo);
            if (mk != null) genericMarkers.add(mk);
        }
    }

    private void setPolylines(@NonNull List<Map<String, Object>> items) {
        GoogleMap map = googleMap; if (map == null) return;

        // remove antigos que não vierem nesta chamada
        Map<String, Polyline> next = new HashMap<>();

        for (Map<String, Object> it : items) {
            String id = it.get("id") instanceof String ? (String) it.get("id") : null;
            if (id == null) id = "pl_" + next.size();

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> pts = it.get("points") instanceof List ? (List<Map<String, Object>>) it.get("points") : new ArrayList<>();
            if (pts.isEmpty()) continue;

            Polyline old = polylineMap.get(id);
            if (old != null) { old.remove(); }

            PolylineOptions opts = new PolylineOptions();
            for (Map<String, Object> p : pts) {
                Double lat = asDouble(p.get("lat"));
                Double lng = asDouble(p.get("lng"));
                if (lat != null && lng != null) opts.add(new LatLng(lat, lng));
            }

            Integer width = it.get("width") instanceof Number ? ((Number) it.get("width")).intValue() : 8;
            String colorStr = it.get("color") instanceof String ? (String) it.get("color") : "#00E5FF";
            int color = parseColorSafe(colorStr, Color.CYAN);

            opts.width(width).color(color).geodesic(true);

            Polyline pl = map.addPolyline(opts);
            if (pl != null) next.put(id, pl);
        }

        // Limpa os antigos que sobraram
        for (Map.Entry<String, Polyline> e : polylineMap.entrySet()) {
            if (!next.containsKey(e.getKey())) e.getValue().remove();
        }
        polylineMap.clear();
        polylineMap.putAll(next);
    }

    private void setPolygons(@NonNull List<Map<String, Object>> items) {
        GoogleMap map = googleMap; if (map == null) return;

        Map<String, Polygon> next = new HashMap<>();

        for (Map<String, Object> it : items) {
            String id = it.get("id") instanceof String ? (String) it.get("id") : null;
            if (id == null) id = "pg_" + next.size();

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> pts = it.get("points") instanceof List ? (List<Map<String, Object>>) it.get("points") : new ArrayList<>();
            if (pts.isEmpty()) continue;

            Polygon old = polygonMap.get(id);
            if (old != null) old.remove();

            PolygonOptions opts = new PolygonOptions();
            for (Map<String, Object> p : pts) {
                Double lat = asDouble(p.get("lat"));
                Double lng = asDouble(p.get("lng"));
                if (lat != null && lng != null) opts.add(new LatLng(lat, lng));
            }

            String strokeColorStr = it.get("strokeColor") instanceof String ? (String) it.get("strokeColor") : "#00E5FF";
            int strokeColor = parseColorSafe(strokeColorStr, Color.CYAN);
            String fillColorStr = it.get("fillColor") instanceof String ? (String) it.get("fillColor") : "#3300E5FF"; // 20% alpha
            int fillColor = parseColorSafe(fillColorStr, Color.argb(0x33, 0x00, 0xE5, 0xFF));
            Integer strokeWidth = it.get("strokeWidth") instanceof Number ? ((Number) it.get("strokeWidth")).intValue() : 4;

            opts.strokeColor(strokeColor).strokeWidth(strokeWidth).fillColor(fillColor);

            Polygon pg = map.addPolygon(opts);
            if (pg != null) next.put(id, pg);
        }

        for (Map.Entry<String, Polygon> e : polygonMap.entrySet()) {
            if (!next.containsKey(e.getKey())) e.getValue().remove();
        }
        polygonMap.clear();
        polygonMap.putAll(next);
    }

    private void cameraTo(double lat, double lng, float zoom, float bearing, float tilt) {
        GoogleMap map = googleMap; if (map == null) { dbg("cameraTo antes do onMapReady"); return; }
        map.animateCamera(CameraUpdateFactory.newCameraPosition(
                new com.google.android.gms.maps.model.CameraPosition(
                        new LatLng(lat, lng), zoom, tilt, bearing
                )
        ));
    }

    private void fitBounds(@NonNull List<Map<String, Object>> pts, int padding) {
        GoogleMap map = googleMap; if (map == null) return;
        if (pts.isEmpty()) return;

        LatLngBounds.Builder b = LatLngBounds.builder();
        for (Map<String, Object> p : pts) {
            Double lat = asDouble(p.get("lat"));
            Double lng = asDouble(p.get("lng"));
            if (lat != null && lng != null) b.include(new LatLng(lat, lng));
        }
        map.animateCamera(CameraUpdateFactory.newLatLngBounds(b.build(), padding));
    }

    private void updateCarPosition(@NonNull String id, @NonNull LatLng target, float rotation, long durationMs) {
        GoogleMap map = googleMap; if (map == null) return;

        Marker marker = carMarkers.get(id);
        if (marker == null) {
            MarkerOptions mo = new MarkerOptions()
                    .position(target)
                    .flat(true)
                    .anchor(0.5f, 0.5f)
                    .rotation(rotation)
                    .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_AZURE));
            marker = map.addMarker(mo);
            if (marker != null) carMarkers.put(id, marker);
            return;
        }

        final LatLng startPos = marker.getPosition();
        final LatLng endPos = target;

        marker.setRotation(rotation);

        ValueAnimator animator = ValueAnimator.ofFloat(0f, 1f);
        animator.setDuration(Math.max(100L, durationMs));
        animator.setInterpolator(new LinearInterpolator());
        animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override public void onAnimationUpdate(ValueAnimator valueAnimator) {
                float t = (float) valueAnimator.getAnimatedValue();
                double lat = startPos.latitude + (endPos.latitude - startPos.latitude) * t;
                double lng = startPos.longitude + (endPos.longitude - startPos.longitude) * t;
                marker.setPosition(new LatLng(lat, lng));
            }
        });
        animator.start();
    }

    // --- Utils ---

    @Nullable private static Double asDouble(Object o){
        if (o instanceof Number) return ((Number) o).doubleValue();
        try { return o != null ? Double.parseDouble(String.valueOf(o)) : null; } catch (Exception ignore) {}
        return null;
    }
    @Nullable private static Float asFloat(Object o){
        if (o instanceof Number) return ((Number) o).floatValue();
        try { return o != null ? Float.parseFloat(String.valueOf(o)) : null; } catch (Exception ignore) {}
        return null;
    }
    private static boolean getBool(Map<String, Object> m, String k, boolean def){
        Object o = m.get(k);
        if (o instanceof Boolean) return (Boolean) o;
        if (o != null) return "true".equalsIgnoreCase(String.valueOf(o));
        return def;
    }
    private static int parseColorSafe(String s, int def){
        try { return Color.parseColor(s); } catch (Throwable t){ return def; }
    }
}
