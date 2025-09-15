package com.quicky.ridebahamas;

import android.animation.TypeEvaluator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.*;
import android.os.Handler;
import android.os.Looper;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.maps.*;
import com.google.android.gms.maps.model.*;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;
import java.util.concurrent.*;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class PickerMapNativeView implements PlatformView, OnMapReadyCallback, MethodChannel.MethodCallHandler {
  private final FrameLayout root;
  private final MapView mapView;
  private GoogleMap map;
  private final MethodChannel channel;
  private final Context context;

  // params recebidos do Flutter
  private Map<String, Object> initialParams;
  private Map<String, Object> pendingConfig;

  // marcadores/rota
  private Marker userMarker;
  private Marker destMarker;
  private final Map<String, Marker> driverMarkers = new HashMap<>();
  private Polyline routePolyline;

  // ícones
  private Bitmap userPhotoBitmap;
  private Bitmap destIconBitmap;
  private Bitmap driverIconBitmap;

  // estilo/rota
  private boolean enableRouteSnake = true;
  private int routeColor = Color.parseColor("#BDBDBD");
  private float routeWidth = 5f;

  private final ExecutorService io = Executors.newSingleThreadExecutor();
  private final Handler main = new Handler(Looper.getMainLooper());

  public PickerMapNativeView(@NonNull Context ctx,
                             @NonNull BinaryMessenger messenger,
                             int viewId,
                             @Nullable Map<String, Object> params) {
    context = ctx;
    root = new FrameLayout(ctx);

    mapView = new MapView(ctx);
    mapView.onCreate(null);
    mapView.onResume();
    mapView.getMapAsync(this);
    root.addView(mapView, new FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT
    ));

    initialParams = params != null ? params : new HashMap<>();
    channel = new MethodChannel(messenger, "picker_map_native/" + viewId);
    channel.setMethodCallHandler(this);
  }

  // ========================= PlatformView =========================
  @NonNull @Override public View getView() { return root; }

  @Override public void dispose() {
    channel.setMethodCallHandler(null);
    io.shutdownNow();
    if (mapView != null) {
      mapView.onPause();
      mapView.onDestroy();
    }
  }

  // ========================= Map Ready =========================
  @Override
  public void onMapReady(@NonNull GoogleMap googleMap) {
    this.map = googleMap;
    UiSettings ui = map.getUiSettings();
    ui.setMapToolbarEnabled(false);
    ui.setCompassEnabled(false);
    ui.setMyLocationButtonEnabled(false);
    ui.setRotateGesturesEnabled(true);
    map.setBuildingsEnabled(false);
    map.setTrafficEnabled(false);

    // estilo
    applyStyle(initialParams);

    // aplica config inicial (user/dest/rota)
    applyConfig(initialParams);

    // se algo chegou antes do mapa estar pronto
    if (pendingConfig != null) {
      applyConfig(pendingConfig);
      pendingConfig = null;
    }
  }

  // ========================= MethodChannel =========================
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "updateConfig":
        if (map == null) {
          pendingConfig = (Map<String, Object>) call.arguments;
        } else {
          applyConfig((Map<String, Object>) call.arguments);
        }
        result.success(null);
        break;

      case "updateCarPosition": {
        Map<String, Object> args = (Map<String, Object>) call.arguments;
        String id = (String) args.get("id");
        Map<String, Object> pos = (Map<String, Object>) args.get("position");
        Double lat = asDouble(pos.get("latitude"));
        Double lng = asDouble(pos.get("longitude"));
        float rotation = asFloat(args.get("rotation"), 0f);
        int dur = asInt(args.get("durationMs"), 1600);
        if (id != null && lat != null && lng != null) {
          updateDriverMarker(id, new LatLng(lat, lng), rotation, dur);
        }
        result.success(null);
        break;
      }

      case "cameraTo": {
        Map<String, Object> args = (Map<String, Object>) call.arguments;
        Double lat = asDouble(args.get("latitude"));
        Double lng = asDouble(args.get("longitude"));
        float zoom = asFloat(args.get("zoom"), 15f);
        if (map != null && lat != null && lng != null) {
          map.animateCamera(CameraUpdateFactory.newCameraPosition(new CameraPosition(new LatLng(lat, lng), zoom, 0, 0)));
        }
        result.success(null);
        break;
      }

      case "fitBounds": {
        Map<String, Object> args = (Map<String, Object>) call.arguments;
        List<Map<String, Object>> pts = (List<Map<String, Object>>) args.get("points");
        int pad = asInt(args.get("padding"), 90);
        if (map != null && pts != null && pts.size() >= 2) {
          LatLngBounds.Builder b = LatLngBounds.builder();
          for (Map<String, Object> p : pts) {
            Double la = asDouble(p.get("latitude"));
            Double lo = asDouble(p.get("longitude"));
            if (la != null && lo != null) b.include(new LatLng(la, lo));
          }
          map.animateCamera(CameraUpdateFactory.newLatLngBounds(b.build(), pad));
        }
        result.success(null);
        break;
      }

      default:
        result.notImplemented();
    }
  }

  // ========================= CONFIG =========================
  private void applyStyle(Map<String, Object> cfg) {
    if (map == null) return;
    try {
      Object styleJson = cfg.get("mapStyleJson");
      if (styleJson instanceof String && !((String) styleJson).isEmpty()) {
        map.setMapStyle(new MapStyleOptions((String) styleJson));
      }
    } catch (Exception ignored) {}
  }

  private void applyConfig(Map<String, Object> cfg) {
    if (cfg == null) return;

    // rota
    Object rc = cfg.get("routeColor");
    if (rc instanceof Number) routeColor = ((Number) rc).intValue();
    Object rw = cfg.get("routeWidth");
    if (rw instanceof Number) routeWidth = ((Number) rw).floatValue();
    Object snake = cfg.get("enableRouteSnake");
    if (snake instanceof Boolean) enableRouteSnake = (Boolean) snake;

    // ícones (baixar uma vez e cachear)
    String userPhotoUrl = asString(cfg.get("userPhotoUrl"));
    if (userPhotoBitmap == null && userPhotoUrl != null && !userPhotoUrl.isEmpty()) {
      fetchBitmap(userPhotoUrl, b -> userPhotoBitmap = makeCircular(b));
    }
    String destUrl = asString(cfg.get("destinationMarkerPngUrl"));
    if (destIconBitmap == null && destUrl != null && !destUrl.isEmpty()) {
      fetchBitmap(destUrl, b -> destIconBitmap = b);
    }
    String taxiUrl = asString(cfg.get("driverTaxiIconUrl"));
    if (driverIconBitmap == null && taxiUrl != null && !taxiUrl.isEmpty()) {
      int wantW = asInt(cfg.get("driverIconWidth"), 70);
      fetchBitmap(taxiUrl, b -> driverIconBitmap = Bitmap.createScaledBitmap(b, wantW, wantW, true));
    }

    // USER
    Map<String, Object> userLoc = asMap(cfg.get("userLocation"));
    LatLng userLL = null;
    if (userLoc != null) {
      Double lat = asDouble(userLoc.get("latitude"));
      Double lng = asDouble(userLoc.get("longitude"));
      if (lat != null && lng != null) {
        userLL = new LatLng(lat, lng);
        if (userMarker == null) {
          MarkerOptions mo = new MarkerOptions().position(userLL).anchor(0.5f, 0.5f);
          String userName = asString(cfg.get("userName"));
          if (userName != null) mo.title(userName);
          if (userPhotoBitmap != null) mo.icon(BitmapDescriptorFactory.fromBitmap(userPhotoBitmap));
          userMarker = map.addMarker(mo);
        } else {
          userMarker.setPosition(userLL);
        }
      }
    }

    // DEST
    Map<String, Object> destLoc = asMap(cfg.get("destination"));
    LatLng destLL = null;
    if (destLoc != null) {
      Double lat = asDouble(destLoc.get("latitude"));
      Double lng = asDouble(destLoc.get("longitude"));
      if (lat != null && lng != null) {
        destLL = new LatLng(lat, lng);
        if (destMarker != null) destMarker.remove();
        MarkerOptions mo = new MarkerOptions().position(destLL).anchor(0.5f, 1f).title("Destination");
        if (destIconBitmap != null) mo.icon(BitmapDescriptorFactory.fromBitmap(destIconBitmap));
        destMarker = map.addMarker(mo);
      }
    } else {
      if (destMarker != null) { destMarker.remove(); destMarker = null; }
    }

    // CAMERA
    if (userLL != null && destLL != null) {
      LatLngBounds b = new LatLngBounds.Builder().include(userLL).include(destLL).build();
      map.animateCamera(CameraUpdateFactory.newLatLngBounds(b, 120));
    } else if (userLL != null) {
      map.animateCamera(CameraUpdateFactory.newCameraPosition(new CameraPosition(userLL, 15.5f, 0, 0)));
    }

    // ROTA
    if (userLL != null && destLL != null) {
      drawRoute(userLL, destLL, enableRouteSnake);
    } else {
      if (routePolyline != null) { routePolyline.remove(); routePolyline = null; }
    }
  }

  // ========================= DRIVERS =========================
  private void updateDriverMarker(String id, LatLng target, float rotation, int durationMs) {
    if (map == null) return;
    Marker m = driverMarkers.get(id);
    if (m == null) {
      MarkerOptions mo = new MarkerOptions()
          .position(target)
          .anchor(0.5f, 0.5f)
          .flat(true)
          .rotation(rotation);
      if (driverIconBitmap != null) {
        mo.icon(BitmapDescriptorFactory.fromBitmap(driverIconBitmap));
      } else {
        mo.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_YELLOW));
      }
      m = map.addMarker(mo);
      driverMarkers.put(id, m);
    } else {
      animateMarker(m, target, rotation, durationMs);
    }
  }

  private void animateMarker(Marker marker, LatLng to, float rotation, int durationMs) {
    LatLng from = marker.getPosition();
    TypeEvaluator<LatLng> te = (fraction, startValue, endValue) -> {
      double lat = (endValue.latitude - startValue.latitude) * fraction + startValue.latitude;
      double lng = (endValue.longitude - startValue.longitude) * fraction + startValue.longitude;
      return new LatLng(lat, lng);
    };
    ValueAnimator anim = ValueAnimator.ofObject(te, from, to);
    anim.setDuration(Math.max(300, durationMs));
    anim.addUpdateListener(a -> {
      LatLng v = (LatLng) a.getAnimatedValue();
      marker.setPosition(v);
      marker.setRotation(rotation);
    });
    anim.start();
  }

  // ========================= ROTA / "SNAKE" =========================
  private void drawRoute(LatLng from, LatLng to, boolean snake) {
    List<LatLng> pts = new ArrayList<>();
    pts.add(from);
    pts.add(to);

    if (routePolyline != null) routePolyline.remove();
    PolylineOptions po = new PolylineOptions().addAll(pts).width(routeWidth).color(routeColor).geodesic(true);
    routePolyline = map.addPolyline(po);

    if (snake) animatePolyline(routePolyline, from, to);
  }

  private void animatePolyline(Polyline pl, LatLng from, LatLng to) {
    if (pl == null) return;
    final int steps = 120; // suavidade
    final long total = 1800; // ms
    final long step = total / steps;

    List<LatLng> acc = new ArrayList<>();
    acc.add(from);
    for (int i = 1; i <= steps; i++) {
      final int k = i;
      main.postDelayed(() -> {
        double f = k / (double) steps;
        double lat = from.latitude + (to.latitude - from.latitude) * f;
        double lng = from.longitude + (to.longitude - from.longitude) * f;
        acc.add(new LatLng(lat, lng));
        pl.setPoints(acc);
      }, step * i);
    }
  }

  // ========================= Utils =========================
  private static Double asDouble(Object o) {
    if (o instanceof Number) return ((Number) o).doubleValue();
    if (o instanceof String) try { return Double.parseDouble((String) o); } catch (Exception ignored) {}
    return null;
  }
  private static Integer asInt(Object o, int def) {
    if (o instanceof Number) return ((Number) o).intValue();
    if (o instanceof String) try { return Integer.parseInt((String) o); } catch (Exception ignored) {}
    return def;
  }
  private static float asFloat(Object o, float def) {
    if (o instanceof Number) return ((Number) o).floatValue();
    if (o instanceof String) try { return Float.parseFloat((String) o); } catch (Exception ignored) {}
    return def;
  }
  private static String asString(Object o) { return o == null ? null : String.valueOf(o); }
  private static Map<String, Object> asMap(Object o) {
    if (o instanceof Map) return (Map<String, Object>) o;
    return null;
  }

  private void fetchBitmap(String url, BitmapConsumer c) {
    io.submit(() -> {
      try {
        URL u = new URL(url);
        HttpURLConnection conn = (HttpURLConnection) u.openConnection();
        conn.setConnectTimeout(6000);
        conn.setReadTimeout(6000);
        conn.connect();
        InputStream is = conn.getInputStream();
        Bitmap b = BitmapFactory.decodeStream(is);
        is.close();
        conn.disconnect();
        if (b != null) main.post(() -> c.onBitmap(b));
      } catch (Exception ignored) {}
    });
  }

  private static Bitmap makeCircular(Bitmap src) {
    int size = Math.min(src.getWidth(), src.getHeight());
    Bitmap out = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888);
    Canvas canvas = new Canvas(out);
    Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
    Rect srcR = new Rect(0, 0, size, size);
    RectF dstR = new RectF(0, 0, size, size);
    float r = size / 2f;
    canvas.drawARGB(0, 0, 0, 0);
    canvas.drawCircle(r, r, r, paint);
    paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
    canvas.drawBitmap(src, srcR, dstR, paint);
    // borda
    Paint border = new Paint(Paint.ANTI_ALIAS_FLAG);
    border.setStyle(Paint.Style.STROKE);
    border.setColor(Color.parseColor("#BDBDBD"));
    border.setStrokeWidth(size * 0.06f);
    canvas.drawCircle(r, r, r - border.getStrokeWidth()/2f, border);
    return out;
  }

  interface BitmapConsumer { void onBitmap(Bitmap b); }
}
