package com.quicky.ridebahamas;

import android.animation.ValueAnimator;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.util.Log;
import android.view.ViewTreeObserver;
import android.view.animation.LinearInterpolator;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
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

@SuppressWarnings({"rawtypes","unchecked"})
public class PickerMapNativeView implements PlatformView, MethodChannel.MethodCallHandler, OnMapReadyCallback {

  private static final String TAG = "PickerMap";
  private final Context ctx;
  private final FrameLayout container;
  private final GoogleMapOptions mapOptions;
  private MapView mapView;
  private GoogleMap googleMap;
  private final MethodChannel channel;
  private final Object creationParams;

  private Marker userMarker;
  private Marker destMarker;
  private Polyline routePolyline;

  private final List<Polygon> polygons = new ArrayList<>();
  private final Map<String, Marker> cars = new HashMap<>();
  private final Map<String, ValueAnimator> carAnimators = new HashMap<>();

  public PickerMapNativeView(@NonNull Context context,
                             @NonNull BinaryMessenger messenger,
                             int id,
                             @Nullable Object creationParams) {
    this.ctx = context;
    this.creationParams = creationParams != null ? creationParams : new HashMap<>();
    this.container = new FrameLayout(context);

    this.mapOptions = new GoogleMapOptions()
        .mapType(GoogleMap.MAP_TYPE_NORMAL)
        .compassEnabled(true)
        .mapToolbarEnabled(false)
        .liteMode(false);

    this.mapView = new MapView(context, mapOptions);
    this.channel = new MethodChannel(messenger, "picker_map_native_" + id);
    this.channel.setMethodCallHandler(this);

    init();
  }

  private void dbg(String msg) {
    Log.d(TAG, msg);
    try { channel.invokeMethod("debugLog", new HashMap<String, Object>() {{
      put("msg", msg);
      put("ts", System.currentTimeMillis());
    }});} catch (Throwable ignore) {}
  }

  private void dbge(String msg, Throwable t) {
    Log.e(TAG, msg, t);
    try { channel.invokeMethod("debugLog", new HashMap<String, Object>() {{
      put("level", "E");
      put("msg", msg + ": " + (t != null ? t.getMessage() : ""));
      put("ts", System.currentTimeMillis());
    }});} catch (Throwable ignore) {}
  }

  private void logApiKeyFromManifest() {
    try {
      ApplicationInfo ai = ctx.getPackageManager()
          .getApplicationInfo(ctx.getPackageName(), PackageManager.GET_META_DATA);
      String key = ai.metaData != null ? ai.metaData.getString("com.google.android.geo.API_KEY") : "<null>";
      if (key == null) key = "<null>";
      String masked = key.length() >= 12 ? key.substring(0, 6) + "…" + key.substring(key.length() - 4) : key;
      dbg("API_KEY(manifest)=" + masked + " len=" + key.length());
    } catch (Throwable t) {
      dbge("Falha ao ler API_KEY do manifest", t);
    }
  }

  private void init() {
    try {
      int status = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(ctx);
      if (status != ConnectionResult.SUCCESS) dbge("Google Play Services indisponível: code=" + status, null);
      else dbg("Google Play Services OK");

      // ✅ API nova (18+): escolhe renderer e recebe no callback (sem retorno)
      MapsInitializer.initialize(
          ctx,
          MapsInitializer.Renderer.LATEST,
          renderer -> dbg("MapsInitializer renderer -> " + renderer)
      );
    } catch (Throwable t) {
      dbge("MapsInitializer.initialize falhou", t);
    }

    try {
      mapView.onCreate(null);
      mapView.onStart();
      mapView.onResume();
      dbg("MapView lifecycle ok (create/start/resume)");
    } catch (Throwable t) { dbge("Lifecycle create/start/resume falhou", t); }

    mapView.getMapAsync(this);

    container.addView(
        mapView,
        new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)
    );

    mapView.getViewTreeObserver().addOnGlobalLayoutListener(
        new ViewTreeObserver.OnGlobalLayoutListener() {
          @Override public void onGlobalLayout() {
            dbg("sizes: container=" + container.getWidth() + "x" + container.getHeight() +
                " mapView=" + mapView.getWidth() + "x" + mapView.getHeight());
          }
        }
    );
  }

  @Override public FrameLayout getView() { return container; }

  @Override public void dispose() {
    dbg("dispose");
    channel.setMethodCallHandler(null);
    try {
      for (ValueAnimator a : carAnimators.values()) a.cancel();
      mapView.onPause();
      mapView.onStop();
      mapView.onDestroy();
    } catch (Throwable t) { dbge("dispose lifecycle error", t); }
  }

  @Override public void onMapReady(@NonNull GoogleMap map) {
    dbg("onMapReady");
    logApiKeyFromManifest();
    googleMap = map;

    map.getUiSettings().setCompassEnabled(true);
    map.getUiSettings().setMyLocationButtonEnabled(false);
    map.setBuildingsEnabled(true);
    map.setMapType(GoogleMap.MAP_TYPE_NORMAL);

    map.setOnMapLoadedCallback(() -> dbg("onMapLoaded (tiles renderizados)"));
    map.setOnMapClickListener(p -> dbg("onMapClick " + p.latitude + "," + p.longitude));

    try {
      if (creationParams instanceof Map) {
        Map params = (Map) creationParams;

        Object camObj = params.get("initialCamera");
        if (camObj instanceof Map) {
          Map cam = (Map) camObj;
          double lat = toDouble(cam.get("latitude"));
          double lng = toDouble(cam.get("longitude"));
          float zoom = cam.get("zoom") != null ? toFloat(cam.get("zoom")) : 14f;
          map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lat, lng), zoom));
          dbg("initialCamera aplicada: (" + lat + "," + lng + ") z=" + zoom);
        }

        Object userObj = params.get("initialUserLocation");
        if (userObj instanceof Map) {
          Map u = (Map) userObj;
          double lat = toDouble(u.get("latitude"));
          double lng = toDouble(u.get("longitude"));
          map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lat, lng), 14f));
          dbg("initialUserLocation aplicada: (" + lat + "," + lng + ")");
        }
      }
    } catch (Throwable t) { dbge("Erro ao aplicar creationParams", t); }

    try { channel.invokeMethod("platformReady", null); } catch (Throwable ignore) {}
  }

  @Override public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    try {
      switch (call.method) {
        case "updateConfig":
          applyConfig((Map) call.arguments); result.success(null); break;
        case "setMarkers":
          setMarkers((List) call.arguments); result.success(null); break;
        case "setPolylines":
          setPolylines((List) call.arguments); result.success(null); break;
        case "setPolygons":
          setPolygons((List) call.arguments); result.success(null); break;
        case "cameraTo": {
          Map a = (Map) call.arguments;
          double lat = toDouble(a.get("latitude"));
          double lng = toDouble(a.get("longitude"));
          Float zoom = a.get("zoom") != null ? toFloat(a.get("zoom")) : null;
          Float bearing = a.get("bearing") != null ? toFloat(a.get("bearing")) : null;
          Float tilt = a.get("tilt") != null ? toFloat(a.get("tilt")) : null;
          cameraTo(lat, lng, zoom, bearing, tilt);
          result.success(null);
          break;
        }
        case "fitBounds": {
          Map a = (Map) call.arguments;
          List pts = (List) a.get("points");
          int padding = a.get("padding") != null ? ((Number) a.get("padding")).intValue() : 0;
          fitBounds(pts, padding);
          result.success(null);
          break;
        }
        case "updateCarPosition": {
          Map a = (Map) call.arguments;
          String id = String.valueOf(a.get("id"));
          double lat = toDouble(a.get("latitude"));
          double lng = toDouble(a.get("longitude"));
          Float rotation = a.get("rotation") != null ? toFloat(a.get("rotation")) : null;
          long duration = a.get("durationMs") != null ? ((Number) a.get("durationMs")).longValue() : 0L;
          updateCarPosition(id, new LatLng(lat, lng), rotation, duration);
          result.success(null);
          break;
        }
        case "debugInfo": {
          Map<String, Object> info = new HashMap<>();
          info.put("hasGooglePlay", GoogleApiAvailability.getInstance()
              .isGooglePlayServicesAvailable(ctx) == ConnectionResult.SUCCESS);
          info.put("mapReady", googleMap != null);
          if (creationParams instanceof Map) {
            info.put("paramsKeys", new ArrayList<>(((Map) creationParams).keySet()));
          } else info.put("paramsKeys", new ArrayList<>());
          result.success(info);
          break;
        }
        case "ping": {
          result.success("pong from native");
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

  private void cameraTo(double lat, double lng, @Nullable Float zoom, @Nullable Float bearing, @Nullable Float tilt) {
    if (googleMap == null) { dbg("cameraTo antes do onMapReady"); return; }
    CameraPosition current = googleMap.getCameraPosition();
    CameraPosition cp = new CameraPosition(
        new LatLng(lat, lng),
        zoom != null ? zoom : current.zoom,
        tilt != null ? tilt : current.tilt,
        bearing != null ? bearing : current.bearing
    );
    googleMap.animateCamera(CameraUpdateFactory.newCameraPosition(cp));
    dbg("cameraTo (" + lat + "," + lng + ") z=" + (zoom != null ? zoom : "-")
        + " b=" + (bearing != null ? bearing : "-")
        + " t=" + (tilt != null ? tilt : "-"));
  }

  private void fitBounds(List points, int padding) {
    if (googleMap == null) return;
    LatLngBounds.Builder b = new LatLngBounds.Builder();
    for (Object p : points) {
      Map m = (Map) p;
      b.include(new LatLng(toDouble(m.get("latitude")), toDouble(m.get("longitude"))));
    }
    googleMap.animateCamera(CameraUpdateFactory.newLatLngBounds(b.build(), padding));
    dbg("fitBounds points=" + points.size() + " padding=" + padding);
  }

  private void applyConfig(Map cfg) {
    if (googleMap == null) { dbg("applyConfig antes do onMapReady"); return; }

    Object u = cfg.get("userLocation");
    if (u instanceof Map) {
      Map m = (Map) u;
      LatLng p = new LatLng(toDouble(m.get("latitude")), toDouble(m.get("longitude")));
      if (userMarker == null) {
        userMarker = googleMap.addMarker(new MarkerOptions()
            .position(p)
            .title(cfg.get("userName") instanceof String ? (String) cfg.get("userName") : "You")
            .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_AZURE))
        );
        googleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(p, 15f));
      } else {
        userMarker.setPosition(p);
      }
    }

    Object d = cfg.get("destination");
    if (d instanceof Map) {
      Map m = (Map) d;
      LatLng p = new LatLng(toDouble(m.get("latitude")), toDouble(m.get("longitude")));
      if (destMarker == null) {
        destMarker = googleMap.addMarker(new MarkerOptions()
            .position(p)
            .title("Destination")
            .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_ORANGE))
        );
      } else destMarker.setPosition(p);
    } else {
      if (destMarker != null) { destMarker.remove(); destMarker = null; }
    }

    int colorInt = cfg.get("routeColor") instanceof Number ? ((Number) cfg.get("routeColor")).intValue() : Color.YELLOW;
    float width = cfg.get("routeWidth") instanceof Number ? ((Number) cfg.get("routeWidth")).floatValue() : 4f;
    if (routePolyline != null) { routePolyline.remove(); routePolyline = null; }

    Object r = cfg.get("route");
    if (r instanceof List) {
      List list = (List) r;
      List<LatLng> pts = new ArrayList<>();
      for (Object p : list) {
        Map m = (Map) p;
        pts.add(new LatLng(toDouble(m.get("latitude")), toDouble(m.get("longitude"))));
      }
      if (pts.size() >= 2) {
        routePolyline = googleMap.addPolyline(new PolylineOptions().addAll(pts).color(colorInt).width(width));
      }
    }

    dbg("applyConfig ok: user=" + (userMarker != null) +
        " dest=" + (destMarker != null) + " route=" + (routePolyline != null));
  }

  private void setMarkers(List list) {
    if (googleMap == null) return;
    for (Object any : list) {
      Map m = (Map) any;
      double lat = toDouble(m.get("latitude"));
      double lng = toDouble(m.get("longitude"));
      googleMap.addMarker(new MarkerOptions().position(new LatLng(lat, lng)));
    }
    dbg("setMarkers n=" + list.size());
  }

  private void setPolylines(List list) {
    if (googleMap == null) return;
    for (Object any : list) {
      Map m = (Map) any;
      List ptsRaw = (List) m.get("points");
      List<LatLng> pts = new ArrayList<>();
      for (Object p : ptsRaw) {
        Map mm = (Map) p;
        pts.add(new LatLng(toDouble(mm.get("latitude")), toDouble(mm.get("longitude"))));
      }
      int color = m.get("color") instanceof Number ? ((Number) m.get("color")).intValue() : Color.YELLOW;
      float width = m.get("width") instanceof Number ? ((Number) m.get("width")).floatValue() : 4f;
      googleMap.addPolyline(new PolylineOptions().addAll(pts).color(color).width(width));
    }
    dbg("setPolylines n=" + list.size());
  }

  private void setPolygons(List list) {
    if (googleMap == null) return;
    for (Polygon p : polygons) p.remove();
    polygons.clear();

    for (Object any : list) {
      Map m = (Map) any;
      List ptsRaw = (List) m.get("points");
      List<LatLng> pts = new ArrayList<>();
      for (Object p : ptsRaw) {
        Map mm = (Map) p;
        pts.add(new LatLng(toDouble(mm.get("latitude")), toDouble(mm.get("longitude"))));
      }
      int strokeColor = m.get("strokeColor") instanceof Number ? ((Number) m.get("strokeColor")).intValue() : Color.BLACK;
      int fillColor = m.get("fillColor") instanceof Number ? ((Number) m.get("fillColor")).intValue() : 0x220000FF;
      float width = m.get("width") instanceof Number ? ((Number) m.get("width")).floatValue() : 2f;

      Polygon polygon = googleMap.addPolygon(new PolygonOptions()
          .addAll(pts)
          .strokeColor(strokeColor)
          .fillColor(fillColor)
          .strokeWidth(width)
      );
      polygons.add(polygon);
    }
    dbg("setPolygons n=" + polygons.size());
  }

  private void updateCarPosition(String id, LatLng dest, @Nullable Float rotation, long duration) {
    if (googleMap == null) return;
    Marker marker = cars.get(id);
    if (marker == null) {
      marker = googleMap.addMarker(new MarkerOptions()
          .position(dest).flat(true).anchor(0.5f, 0.5f)
          .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE))
      );
      cars.put(id, marker);
      dbg("car[" + id + "] criado em " + dest.latitude + "," + dest.longitude);
    }
    if (rotation != null) marker.setRotation(rotation);
    ValueAnimator prev = carAnimators.get(id);
    if (prev != null) prev.cancel();

    if (duration <= 0L) {
      marker.setPosition(dest);
      dbg("car[" + id + "] snap -> " + dest.latitude + "," + dest.longitude + " rot=" + (rotation != null ? rotation : "-"));
      return;
    }

    final LatLng startPos = marker.getPosition();
    ValueAnimator animator = ValueAnimator.ofFloat(0f, 1f);
    animator.setInterpolator(new LinearInterpolator());
    animator.setDuration(duration);
    animator.addUpdateListener(va -> {
      float f = (float) va.getAnimatedValue();
      double lat = startPos.latitude + (dest.latitude - startPos.latitude) * f;
      double lng = startPos.longitude + (dest.longitude - startPos.longitude) * f;
      marker.setPosition(new LatLng(lat, lng));
    });
    animator.start();
    carAnimators.put(id, animator);
    dbg("car[" + id + "] anim -> " + dest.latitude + "," + dest.longitude + " dur=" + duration + "ms rot=" + (rotation != null ? rotation : "-"));
  }

  private static double toDouble(Object n) { return ((Number) n).doubleValue(); }
  private static float toFloat(Object n) { return ((Number) n).floatValue(); }
}
