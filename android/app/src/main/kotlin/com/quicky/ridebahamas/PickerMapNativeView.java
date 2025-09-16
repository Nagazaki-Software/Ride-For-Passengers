package com.quicky.ridebahamas;

import android.animation.TypeEvaluator;
import android.animation.ValueAnimator;
import android.content.Context;
<<<<<<< HEAD
import android.graphics.*;
=======
import android.content.SharedPreferences;
import android.graphics.*;
import android.graphics.drawable.ColorDrawable;
>>>>>>> 10c9b5c (new frkdfm)
import android.os.Handler;
import android.os.Looper;
import android.util.AttributeSet;
import android.view.View;
<<<<<<< HEAD
import android.widget.FrameLayout;
=======
import android.view.animation.LinearInterpolator;
import android.widget.FrameLayout;
import android.widget.ImageView;
>>>>>>> 10c9b5c (new frkdfm)

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.maps.*;
<<<<<<< HEAD
import com.google.android.gms.maps.model.*;

=======
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.model.*;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
>>>>>>> 10c9b5c (new frkdfm)
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;
import java.util.concurrent.*;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
<<<<<<< HEAD
=======
import io.flutter.FlutterInjector;
>>>>>>> 10c9b5c (new frkdfm)

public class PickerMapNativeView implements PlatformView, OnMapReadyCallback, MethodChannel.MethodCallHandler {
  private final FrameLayout root;
  private final MapView mapView;
<<<<<<< HEAD
  private GoogleMap map;
  private final MethodChannel channel;
  private final Context context;
=======
  private final ImageView snapshotOverlay;
  private GoogleMap map;
  private final MethodChannel channel;
  private final Context context;
  private final SharedPreferences prefs;
  private final File snapshotFile;
  private static final int DARK_CANVAS_COLOR = Color.parseColor("#0F1217");
  private static final String PREFS_NAME = "picker_map_native_cache";
  private static final String PREF_KEY_CAMERA_LAT = "camera_lat";
  private static final String PREF_KEY_CAMERA_LNG = "camera_lng";
  private static final String PREF_KEY_CAMERA_ZOOM = "camera_zoom";
  private static final String PREF_KEY_CAMERA_TILT = "camera_tilt";
  private static final String PREF_KEY_CAMERA_BEARING = "camera_bearing";
  private static final String SNAPSHOT_CACHE_NAME = "picker_map_last.png";
>>>>>>> 10c9b5c (new frkdfm)

  // params recebidos do Flutter
  private Map<String, Object> initialParams;
  private Map<String, Object> pendingConfig;

  // marcadores/rota
  private Marker userMarker;
  private Marker destMarker;
  private final Map<String, Marker> driverMarkers = new HashMap<>();
  private Polyline routePolyline;
<<<<<<< HEAD

  // ícones
  private Bitmap userPhotoBitmap;
  private Bitmap destIconBitmap;
  private Bitmap driverIconBitmap;
=======
  private List<LatLng> lastRoutePoints;
  private String lastEncodedPolyline;
  private String lastStyleJson;
  private LatLng lastUserLL;
  private LatLng lastDestLL;
  private boolean hasFadedIn = false;
  private boolean routeHadEncoded = false;
  private Long destSetAtMs = null;
  private long lastUpdateMs = 0L;
  private boolean enforcingTilt = false;
  private static Bitmap lastSnapshot = null;
  private static CameraPosition lastCameraPosition = null;
  private long lastSnapshotMs = 0L;
  private long cameraAnimatingUntilMs = 0L;
  private boolean autoFitCamera = false;
  // Runnable to hide snapshot overlay after a short delay
  private final Runnable hideOverlayRunnable = new Runnable() {
    @Override
    public void run() {
      try {
        if (snapshotOverlay != null) {
          snapshotOverlay.animate()
              .alpha(0f)
              .setDuration(160)
              .withEndAction(new Runnable() {
                @Override public void run() {
                  try {
                    snapshotOverlay.setImageDrawable(null);
                    snapshotOverlay.setVisibility(View.GONE);
                    snapshotOverlay.setAlpha(1f); // reset alpha for next show
                  } catch (Exception ignored) {}
                }
              })
              .start();
        }
      } catch (Exception ignored) {}
    }
  };

  // Attempts to capture a fresh snapshot, retrying a few times before giving up
  private void takeSnapshotAndThen(int tries, long delayMs, Runnable after) {
    if (map == null) { try { if (after != null) after.run(); } catch (Exception ignored) {} return; }
    try {
      map.snapshot(bmp -> {
        try {
          if (bmp != null) {
            lastSnapshot = bmp;
            saveSnapshotAsync(bmp);
            if (after != null) after.run();
          } else if (tries > 0) {
            // retry slightly later
            main.postDelayed(() -> takeSnapshotAndThen(tries - 1, delayMs, after), Math.max(40L, delayMs));
          } else {
            if (after != null) after.run();
          }
        } catch (Exception ignored) {}
      });
    } catch (Exception e) {
      if (tries > 0) {
        try { main.postDelayed(() -> takeSnapshotAndThen(tries - 1, delayMs, after), Math.max(60L, delayMs)); } catch (Exception ignored) {}
      } else {
        try { if (after != null) after.run(); } catch (Exception ignored) {}
      }
    }
  }
  // Gesture overlay control: show only if gesture lasts beyond a small threshold and we have cache
  private boolean cameraMoving = false;
  private final Runnable showGestureOverlayRunnable = new Runnable() {
    @Override public void run() {
      try {
        if (!cameraMoving) return;
        if (lastSnapshot == null) return;
        snapshotOverlay.setImageBitmap(lastSnapshot);
        snapshotOverlay.setVisibility(View.VISIBLE);
        snapshotOverlay.setAlpha(1f);
      } catch (Exception ignored) {}
    }
  };

  // ÃƒÂ­cones
  private Bitmap userPhotoBitmap;
  private Bitmap destIconBitmap;
  private Bitmap driverIconBitmap;
  private String lastDriverIconSource;
  // Store driver positions received before icon is ready to avoid default pin flicker
  private final Map<String, LatLng> pendingDriverPositions = new HashMap<>();
  private int brandPadBottom = 0;
>>>>>>> 10c9b5c (new frkdfm)

  // estilo/rota
  private boolean enableRouteSnake = true;
  private int routeColor = Color.parseColor("#BDBDBD");
  private float routeWidth = 5f;
<<<<<<< HEAD
=======
  private boolean ultraLowSpecMode = false;
>>>>>>> 10c9b5c (new frkdfm)

  private final ExecutorService io = Executors.newSingleThreadExecutor();
  private final Handler main = new Handler(Looper.getMainLooper());

  public PickerMapNativeView(@NonNull Context ctx,
                             @NonNull BinaryMessenger messenger,
                             int viewId,
                             @Nullable Map<String, Object> params) {
    context = ctx;
<<<<<<< HEAD
    root = new FrameLayout(ctx);

    mapView = new MapView(ctx);
    mapView.onCreate(null);
    mapView.onResume();
    mapView.getMapAsync(this);
=======
    Context appCtx = ctx.getApplicationContext();
    prefs = appCtx.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    snapshotFile = new File(appCtx.getCacheDir(), SNAPSHOT_CACHE_NAME);
    if (lastCameraPosition == null) {
      CameraPosition cachedCamera = loadCameraFromPrefs();
      if (cachedCamera != null) lastCameraPosition = cachedCamera;
    }
    if (lastSnapshot == null) {
      Bitmap cachedSnapshot = loadSnapshotFromDisk();
      if (cachedSnapshot != null) lastSnapshot = cachedSnapshot;
    }
    try { MapsInitializer.initialize(appCtx, MapsInitializer.Renderer.LATEST, null); } catch (Exception ignored) {}

    root = new FrameLayout(ctx);

    // Support lite mode via creation params (for extremely low-spec devices)
    boolean useLiteMode = false;
    try {
      if (params != null && params.containsKey("liteModeOnAndroid")) {
        Object v = params.get("liteModeOnAndroid");
        if (v instanceof Boolean) useLiteMode = (Boolean) v;
      }
    } catch (Exception ignored) {}

    if (useLiteMode) {
      GoogleMapOptions opts = new GoogleMapOptions().liteMode(true);
      mapView = new MapView(ctx, opts);
    } else {
      mapView = new MapView(ctx);
    }
    mapView.onCreate(null);
    mapView.onResume();
    mapView.getMapAsync(this);
    snapshotOverlay = new ImageView(ctx);
    snapshotOverlay.setScaleType(ImageView.ScaleType.CENTER_CROP);
    if (lastSnapshot != null) {
      snapshotOverlay.setImageBitmap(lastSnapshot);
    } else {
      // Keep a dark cover to mask white flashes until tiles load
      snapshotOverlay.setImageDrawable(new ColorDrawable(DARK_CANVAS_COLOR));
    }
    snapshotOverlay.setVisibility(View.VISIBLE);
>>>>>>> 10c9b5c (new frkdfm)
    root.addView(mapView, new FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT
    ));
<<<<<<< HEAD

    initialParams = params != null ? params : new HashMap<>();
=======
    root.addView(snapshotOverlay, new FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT
    ));
    // Reduce white flash while tiles load
    int dark = DARK_CANVAS_COLOR;
    root.setBackgroundColor(dark);
    mapView.setBackgroundColor(dark);
    snapshotOverlay.setBackgroundColor(dark);
    
    initialParams = params != null ? params : new HashMap<>();
    // read autoFitCamera from params (default false to avoid camera jumps)
    try {
      Object af = initialParams.get("autoFitCamera");
      if (af instanceof Boolean) autoFitCamera = (Boolean) af;
    } catch (Exception ignored) {}
>>>>>>> 10c9b5c (new frkdfm)
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
<<<<<<< HEAD
=======
      mapView.onStop();
>>>>>>> 10c9b5c (new frkdfm)
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
<<<<<<< HEAD
    map.setBuildingsEnabled(false);
    map.setTrafficEnabled(false);
=======
    ui.setTiltGesturesEnabled(true);
    map.setBuildingsEnabled(true);
    map.setTrafficEnabled(false);
    map.setIndoorEnabled(false);
    map.setMapType(GoogleMap.MAP_TYPE_NORMAL);
    // Enable tile prefetch on newer Google Maps SDK versions (use reflection for compatibility)
    try {
      java.lang.reflect.Method m = GoogleMap.class.getMethod("setPrefetchEnabled", boolean.class);
      m.invoke(map, true);
    } catch (Throwable ignored) {}
>>>>>>> 10c9b5c (new frkdfm)

    // estilo
    applyStyle(initialParams);

    // aplica config inicial (user/dest/rota)
    applyConfig(initialParams);

<<<<<<< HEAD
=======
    boolean hasInitialDest = initialParams != null && initialParams.get("destination") != null;
    boolean hasInitialPolyline = initialParams != null && initialParams.get("encodedPolyline") != null;
    if (lastCameraPosition != null && !(hasInitialDest || hasInitialPolyline)) {
      try { map.moveCamera(CameraUpdateFactory.newCameraPosition(lastCameraPosition)); } catch (Exception ignored) {}
    }

>>>>>>> 10c9b5c (new frkdfm)
    // se algo chegou antes do mapa estar pronto
    if (pendingConfig != null) {
      applyConfig(pendingConfig);
      pendingConfig = null;
    }
<<<<<<< HEAD
=======
    // Fade in after tiles load to avoid white flash
    map.setOnMapLoadedCallback(() -> {
      if (!hasFadedIn) {
        hasFadedIn = true;
      }
      // Take snapshot with retries before hiding the overlay to avoid any white
      try { takeSnapshotAndThen(3, 160, () -> hideSnapshotOverlayDelayed(520)); } catch (Exception ignored) { hideSnapshotOverlayDelayed(520); }
      try { channel.invokeMethod("mapLoaded", null); } catch (Exception ignored) {}
    });
    map.setOnCameraMoveStartedListener((reason) -> {
      cameraMoving = true;
      // Overlay policy handled in animate3DBounds; here we just signal movement
      try { channel.invokeMethod("cameraMoveStart", null); } catch (Exception ignored) {}
    });
    map.setOnCameraIdleListener(() -> {
      // Enforce a pleasant tilt and keep 3D buildings enabled when route is active
      try {
        if (autoFitCamera && !enforcingTilt && !ultraLowSpecMode) {
          CameraPosition cp = map.getCameraPosition();
          boolean routeActive = (lastRoutePoints != null && lastRoutePoints.size() >= 2);
          float desiredTilt = cp.tilt;
          if (routeActive) {
            desiredTilt = 45f; // keep 3D while route visible
          } else if (cp.zoom <= 15f) {
            desiredTilt = 0f; // flatten when zoomed out
          }

          if (Math.abs(desiredTilt - cp.tilt) > 1f) {
            enforcingTilt = true;
            CameraPosition target = new CameraPosition(cp.target, cp.zoom, desiredTilt, cp.bearing);
            map.animateCamera(
                CameraUpdateFactory.newCameraPosition(target),
                250,
                new GoogleMap.CancelableCallback() {
                  @Override public void onFinish() { enforcingTilt = false; }
                  @Override public void onCancel() { enforcingTilt = false; }
                }
            );
          }
          // Keep buildings on while tilted or route is active
          try { map.setBuildingsEnabled(desiredTilt >= 30f || (cp.tilt >= 30f) || routeActive); } catch (Exception ignored) {}
        }
      } catch (Exception ignored) {}
      // Update snapshot cache (throttled)
      long now2 = System.currentTimeMillis();
      if (now2 - lastSnapshotMs > 2500) {
        lastSnapshotMs = now2;
        try {
          map.snapshot(bmp -> { if (bmp != null) { lastSnapshot = bmp; saveSnapshotAsync(bmp); } });
        } catch (Exception ignored) {}
      }
      try { lastCameraPosition = map.getCameraPosition(); saveCameraToPrefs(lastCameraPosition); } catch (Exception ignored) {}
      try { channel.invokeMethod("cameraIdle", null); } catch (Exception ignored) {}
      cameraMoving = false;
      hideSnapshotOverlayDelayed(140);
    });
    // Safety fallback: if tiles taking too long, fade anyway after 700ms
    mapView.postDelayed(() -> {
      if (!hasFadedIn) {
        hasFadedIn = true;
        hideSnapshotOverlayDelayed(20);
      }
    }, 700);
  }

  private void showSnapshotOverlay() {
    try {
      if (lastSnapshot != null) {
        snapshotOverlay.setImageBitmap(lastSnapshot);
      } else {
        snapshotOverlay.setImageDrawable(new ColorDrawable(DARK_CANVAS_COLOR));
      }
      snapshotOverlay.setVisibility(View.VISIBLE);
      snapshotOverlay.setAlpha(1f);
    } catch (Exception ignored) {}
  }

  // Show overlay only if we have a cached snapshot; otherwise do nothing (avoid showing dark cover during gestures)
  private void showSnapshotOverlayIfCached() {
    try {
      if (lastSnapshot == null) return;
      snapshotOverlay.setImageBitmap(lastSnapshot);
      snapshotOverlay.setVisibility(View.VISIBLE);
      snapshotOverlay.setAlpha(1f);
    } catch (Exception ignored) {}
  }

  private Bitmap loadSnapshotFromDisk() {
    if (snapshotFile == null || !snapshotFile.exists()) return null;
    try (FileInputStream fis = new FileInputStream(snapshotFile)) {
      return BitmapFactory.decodeStream(fis);
    } catch (Exception ignored) {
      return null;
    }
  }

  private void saveSnapshotAsync(Bitmap bmp) {
    if (bmp == null || snapshotFile == null) return;
    Bitmap toSave = bmp.copy(Bitmap.Config.ARGB_8888, false);
    if (toSave == null) toSave = bmp;
    final Bitmap finalBmp = toSave;
    try {
      io.execute(() -> {
        try (FileOutputStream fos = new FileOutputStream(snapshotFile)) {
          finalBmp.compress(Bitmap.CompressFormat.JPEG, 82, fos);
          fos.flush();
        } catch (Exception ignored) {}
      });
    } catch (Exception ignored) {}
  }

  private CameraPosition loadCameraFromPrefs() {
    if (prefs == null || !prefs.contains(PREF_KEY_CAMERA_LAT)) return null;
    try {
      double lat = Double.longBitsToDouble(prefs.getLong(PREF_KEY_CAMERA_LAT, 0L));
      double lng = Double.longBitsToDouble(prefs.getLong(PREF_KEY_CAMERA_LNG, 0L));
      float zoom = prefs.getFloat(PREF_KEY_CAMERA_ZOOM, 15f);
      float tilt = prefs.getFloat(PREF_KEY_CAMERA_TILT, 0f);
      float bearing = prefs.getFloat(PREF_KEY_CAMERA_BEARING, 0f);
      return new CameraPosition(new LatLng(lat, lng), zoom, tilt, bearing);
    } catch (Exception ignored) {
      return null;
    }
  }

  private void saveCameraToPrefs(CameraPosition cp) {
    if (prefs == null || cp == null) return;
    try {
      prefs.edit()
          .putLong(PREF_KEY_CAMERA_LAT, Double.doubleToRawLongBits(cp.target.latitude))
          .putLong(PREF_KEY_CAMERA_LNG, Double.doubleToRawLongBits(cp.target.longitude))
          .putFloat(PREF_KEY_CAMERA_ZOOM, cp.zoom)
          .putFloat(PREF_KEY_CAMERA_TILT, cp.tilt)
          .putFloat(PREF_KEY_CAMERA_BEARING, cp.bearing)
          .apply();
    } catch (Exception ignored) {}
  }

  private void hideSnapshotOverlayDelayed(int delayMs) {
    if (mapView == null) return;
    try {
      mapView.removeCallbacks(hideOverlayRunnable);
      mapView.postDelayed(hideOverlayRunnable, Math.max(0, delayMs));
    } catch (Exception ignored) {}
>>>>>>> 10c9b5c (new frkdfm)
  }

  // ========================= MethodChannel =========================
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "updateConfig":
<<<<<<< HEAD
        if (map == null) {
          pendingConfig = (Map<String, Object>) call.arguments;
        } else {
          applyConfig((Map<String, Object>) call.arguments);
        }
        result.success(null);
        break;

=======
        try {
          Map<String, Object> cfg = (Map<String, Object>) call.arguments;
          if (cfg != null && cfg.containsKey("autoFitCamera")) {
            Object af = cfg.get("autoFitCamera");
            if (af instanceof Boolean) autoFitCamera = (Boolean) af;
          }
          if (map == null) {
            pendingConfig = cfg;
          } else {
            applyConfig(cfg);
          }
        } catch (Exception ignored) {}
        result.success(null);
        break;

      case "onResume": {
        try {
          if (mapView != null) {
            mapView.onStart();
            mapView.onResume();
            if (hasFadedIn && mapView.getAlpha() < 1f) {
              mapView.setAlpha(1f);
            }
            // Mask with last snapshot immediately, then refresh snapshot and hide when ready
            showSnapshotOverlay();
            try {
              takeSnapshotAndThen(3, 160, () -> hideSnapshotOverlayDelayed(500));
            } catch (Exception e) {
              hideSnapshotOverlayDelayed(500);
            }
            root.requestLayout();
            root.invalidate();
            mapView.requestLayout();
            mapView.invalidate();
          }
        } catch (Exception ignored) {}
        result.success(null);
        break;
      }

      case "onPause": {
        try {
          if (mapView != null) {
            mapView.onPause();
            mapView.onStop();
          }
        } catch (Exception ignored) {}
        result.success(null);
        break;
      }

      case "onLowMemory": {
        try { if (mapView != null) mapView.onLowMemory(); } catch (Exception ignored) {}
        result.success(null);
        break;
      }

>>>>>>> 10c9b5c (new frkdfm)
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
<<<<<<< HEAD
    if (map == null) return;
    try {
      Object styleJson = cfg.get("mapStyleJson");
      if (styleJson instanceof String && !((String) styleJson).isEmpty()) {
        map.setMapStyle(new MapStyleOptions((String) styleJson));
=======
    if (map == null || cfg == null) return;
    try {
      Object useNative = cfg.get("useNativeStyle");
      boolean useNativeStyle = false;
      if (useNative instanceof Boolean) useNativeStyle = (Boolean) useNative;
      if (!useNativeStyle && useNative instanceof String) {
        useNativeStyle = "true".equalsIgnoreCase((String) useNative);
      }

      if (useNativeStyle) {
        if (!"native:dark".equals(lastStyleJson)) {
          try {
            boolean ok = map.setMapStyle(
                MapStyleOptions.loadRawResourceStyle(context, R.raw.map_style_dark)
            );
          } catch (Exception ignored) {}
          lastStyleJson = "native:dark";
        }
      } else {
        String styleJson = asString(cfg.get("mapStyleJson"));
        if (styleJson != null && !styleJson.isEmpty()) {
          if (!styleJson.equals(lastStyleJson)) {
            lastStyleJson = styleJson;
            map.setMapStyle(new MapStyleOptions(styleJson));
          }
        } else if (lastStyleJson != null) {
          lastStyleJson = null;
          map.setMapStyle(null);
        }
>>>>>>> 10c9b5c (new frkdfm)
      }
    } catch (Exception ignored) {}
  }

  private void applyConfig(Map<String, Object> cfg) {
    if (cfg == null) return;
<<<<<<< HEAD
=======
    applyStyle(cfg);
    long now = System.currentTimeMillis();
    boolean shouldThrottle = (now - lastUpdateMs) < 16; // ~60fps throttle for smoother animations
    // Peek critical fields to avoid throttling removals/major changes
    String encPeek0 = asString(cfg.get("encodedPolyline"));
    Map<String, Object> destLocPeek0 = asMap(cfg.get("destination"));
    boolean destRemoved0 = (destLocPeek0 == null && lastDestLL != null);
    boolean destAdded0 = (destLocPeek0 != null && lastDestLL == null);
    boolean encRemoved0 = (encPeek0 == null && lastEncodedPolyline != null);
    boolean encChangedFast0 = (encPeek0 != null && (lastEncodedPolyline == null || !encPeek0.equals(lastEncodedPolyline)));
    if (shouldThrottle && !(destRemoved0 || destAdded0 || encRemoved0 || encChangedFast0)) {
      return; // skip only minor/no-op updates
    }
    lastUpdateMs = now;
>>>>>>> 10c9b5c (new frkdfm)

    // rota
    Object rc = cfg.get("routeColor");
    if (rc instanceof Number) routeColor = ((Number) rc).intValue();
    Object rw = cfg.get("routeWidth");
    if (rw instanceof Number) routeWidth = ((Number) rw).floatValue();
    Object snake = cfg.get("enableRouteSnake");
    if (snake instanceof Boolean) enableRouteSnake = (Boolean) snake;

<<<<<<< HEAD
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
=======
    // brand safe padding bottom (used to pad camera when tilting)
    Object bpad = cfg.get("brandSafePaddingBottom");
    if (bpad instanceof Number) brandPadBottom = ((Number) bpad).intValue();

    // ultra-low-spec mode (reduce effects for perf)
    Object uls = cfg.get("ultraLowSpecMode");
    if (uls instanceof Boolean) {
      ultraLowSpecMode = (Boolean) uls;
    } else if (uls instanceof String) {
      ultraLowSpecMode = "true".equalsIgnoreCase((String) uls);
    }
    try { map.setBuildingsEnabled(!ultraLowSpecMode); } catch (Exception ignored) {}

    // ÃƒÂ­cones (baixar uma vez e cachear)
    String userPhotoUrl = asString(cfg.get("userPhotoUrl"));
    String userName = asString(cfg.get("userName"));
    int dpSize = asInt(cfg.get("userMarkerSize"), 16);
    float density = context.getResources().getDisplayMetrics().density;
    final int px = Math.max(12, (int)(dpSize * density));
    // Always have an immediate placeholder using initials when name exists
    if ((userPhotoBitmap == null) && userName != null && !userName.trim().isEmpty()) {
      String ini = initialsFromName(userName);
      userPhotoBitmap = makeInitialsBadge(ini, px, Color.parseColor("#FBB125"), Color.BLACK);
    }
    // If photo URL exists, fetch and replace the icon when ready
    if (userPhotoUrl != null && !userPhotoUrl.isEmpty()) {
      fetchBitmap(userPhotoUrl, b -> {
        try {
          Bitmap scaled = Bitmap.createScaledBitmap(b, px, px, true);
          userPhotoBitmap = makeCircular(scaled);
          if (userMarker != null && userPhotoBitmap != null) {
            userMarker.setIcon(BitmapDescriptorFactory.fromBitmap(userPhotoBitmap));
          }
        } catch (Exception ignored) {}
      });
    }
    String destUrl = asString(cfg.get("destinationMarkerPngUrl"));
    if (destUrl != null && !destUrl.isEmpty()) {
      if (destUrl.startsWith("http")) {
        fetchBitmap(destUrl, b -> {
          float d = context.getResources().getDisplayMetrics().density;
          int destPx = (int)(32 * d);
          destIconBitmap = Bitmap.createScaledBitmap(b, destPx, destPx, true);
          if (destMarker != null && destIconBitmap != null) {
            destMarker.setIcon(BitmapDescriptorFactory.fromBitmap(destIconBitmap));
          }
        });
      } else {
        // load from assets (allow prefix 'asset:' or direct 'assets/...'), with Flutter lookup fallback
        String path = destUrl.startsWith("asset:") ? destUrl.substring(6) : destUrl;
        try {
          InputStream is;
          try {
            is = context.getAssets().open(path);
          } catch (Exception e) {
            String key = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(path);
            String full = "flutter_assets/" + key;
            is = context.getAssets().open(full);
          }
          Bitmap b = BitmapFactory.decodeStream(is);
          is.close();
          float d = context.getResources().getDisplayMetrics().density;
          int destPx = (int)(32 * d);
          destIconBitmap = Bitmap.createScaledBitmap(b, destPx, destPx, true);
        } catch (Exception ignored) {}
      }
    }
    String taxiUrl = asString(cfg.get("driverTaxiIconUrl"));
    String driverUrl = asString(cfg.get("driverDriverIconUrl"));
    String chosenIcon = (taxiUrl != null && !taxiUrl.isEmpty()) ? taxiUrl : driverUrl;
    if (chosenIcon != null && !chosenIcon.isEmpty()) {
      boolean iconChanged = (lastDriverIconSource == null) || !chosenIcon.equals(lastDriverIconSource);
      if (driverIconBitmap == null || iconChanged) {
        lastDriverIconSource = chosenIcon;
        int wantW = asInt(cfg.get("driverIconWidth"), 70);
        if (chosenIcon.startsWith("http")) {
          fetchBitmap(chosenIcon, b -> {
            driverIconBitmap = Bitmap.createScaledBitmap(b, wantW, wantW, true);
            try {
              // Apply new icon to existing markers
              for (Marker mk : driverMarkers.values()) {
                mk.setIcon(BitmapDescriptorFactory.fromBitmap(driverIconBitmap));
              }
              // Create any pending markers now that the icon is ready
              if (!pendingDriverPositions.isEmpty()) {
                for (Map.Entry<String, LatLng> e : new HashMap<>(pendingDriverPositions).entrySet()) {
                  String id2 = e.getKey();
                  LatLng pos2 = e.getValue();
                  MarkerOptions mo2 = new MarkerOptions()
                      .position(pos2)
                      .anchor(0.5f, 0.5f)
                      .flat(false)
                      .icon(BitmapDescriptorFactory.fromBitmap(driverIconBitmap));
                  Marker m2 = map.addMarker(mo2);
                  driverMarkers.put(id2, m2);
                }
                pendingDriverPositions.clear();
              }
            } catch (Exception ignored) {}
          });
        } else {
          // Support assets: allow prefix 'asset:' or direct 'assets/...'
          String path = chosenIcon.startsWith("asset:") ? chosenIcon.substring(6) : chosenIcon;
          try {
            InputStream is;
            try {
              is = context.getAssets().open(path);
            } catch (Exception e) {
              String key = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(path);
              String full = "flutter_assets/" + key;
              is = context.getAssets().open(full);
            }
            Bitmap b = BitmapFactory.decodeStream(is);
            is.close();
            if (b != null) {
              driverIconBitmap = Bitmap.createScaledBitmap(b, wantW, wantW, true);
              try {
                for (Marker mk : driverMarkers.values()) {
                  mk.setIcon(BitmapDescriptorFactory.fromBitmap(driverIconBitmap));
                }
                if (!pendingDriverPositions.isEmpty()) {
                  for (Map.Entry<String, LatLng> e : new HashMap<>(pendingDriverPositions).entrySet()) {
                    String id2 = e.getKey();
                    LatLng pos2 = e.getValue();
                    MarkerOptions mo2 = new MarkerOptions()
                        .position(pos2)
                        .anchor(0.5f, 0.5f)
                        .flat(false)
                        .icon(BitmapDescriptorFactory.fromBitmap(driverIconBitmap));
                    Marker m2 = map.addMarker(mo2);
                    driverMarkers.put(id2, m2);
                  }
                  pendingDriverPositions.clear();
                }
              } catch (Exception ignored) {}
            }
          } catch (Exception ignored) {}
        }
      }
    }

    // USER marker: small circular icon (photo or initials), never default pin
>>>>>>> 10c9b5c (new frkdfm)
    Map<String, Object> userLoc = asMap(cfg.get("userLocation"));
    LatLng userLL = null;
    if (userLoc != null) {
      Double lat = asDouble(userLoc.get("latitude"));
      Double lng = asDouble(userLoc.get("longitude"));
      if (lat != null && lng != null) {
        userLL = new LatLng(lat, lng);
<<<<<<< HEAD
        if (userMarker == null) {
          MarkerOptions mo = new MarkerOptions().position(userLL).anchor(0.5f, 0.5f);
          String userName = asString(cfg.get("userName"));
          if (userName != null) mo.title(userName);
          if (userPhotoBitmap != null) mo.icon(BitmapDescriptorFactory.fromBitmap(userPhotoBitmap));
          userMarker = map.addMarker(mo);
        } else {
          userMarker.setPosition(userLL);
=======
        if (userPhotoBitmap != null) {
          if (userMarker == null) {
            MarkerOptions mo = new MarkerOptions()
                .position(userLL)
                .anchor(0.5f, 0.5f)
                .flat(true)
                .icon(BitmapDescriptorFactory.fromBitmap(userPhotoBitmap));
            userMarker = map.addMarker(mo);
          } else {
            userMarker.setPosition(userLL);
            userMarker.setIcon(BitmapDescriptorFactory.fromBitmap(userPhotoBitmap));
          }
>>>>>>> 10c9b5c (new frkdfm)
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
<<<<<<< HEAD
        MarkerOptions mo = new MarkerOptions().position(destLL).anchor(0.5f, 1f).title("Destination");
        if (destIconBitmap != null) mo.icon(BitmapDescriptorFactory.fromBitmap(destIconBitmap));
        destMarker = map.addMarker(mo);
=======
        // Snap destination marker to the end of the current route (street) when available
        LatLng markerLL = destLL;
        try {
          if (lastRoutePoints != null && lastRoutePoints.size() >= 2) {
            markerLL = lastRoutePoints.get(lastRoutePoints.size() - 1);
          }
        } catch (Exception ignored) {}
        if (destIconBitmap != null) {
          MarkerOptions mo = new MarkerOptions().position(markerLL).anchor(0.5f, 1f);
          mo.icon(BitmapDescriptorFactory.fromBitmap(destIconBitmap));
          destMarker = map.addMarker(mo);
        } else {
          destMarker = null; // sem pin nativo
        }
>>>>>>> 10c9b5c (new frkdfm)
      }
    } else {
      if (destMarker != null) { destMarker.remove(); destMarker = null; }
    }
<<<<<<< HEAD

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
=======
    if (destLL != null && destSetAtMs == null) destSetAtMs = now; else if (destLL == null) destSetAtMs = null;

    // Rota por polyline (se enviada) ou fallback reta user->dest (estÃƒÂ¡vel)
    String enc = asString(cfg.get("encodedPolyline"));
    boolean encChanged = (enc != null && !enc.equals(lastEncodedPolyline)) || (enc == null && lastEncodedPolyline != null);
    boolean userChanged = !equalsLatLng(lastUserLL, userLL);
    boolean destChanged = !equalsLatLng(lastDestLL, destLL);
    boolean routeChanged = false;

    if (enc != null && !enc.isEmpty()) {
      if (encChanged) {
        List<LatLng> pts = decodePoly(enc);
        if (pts != null && pts.size() > 1) {
          // re-animate on encoded change for a smoother professional feel
          drawPolyline(pts, true);
          lastRoutePoints = pts;
          routeChanged = true;
        }
        lastEncodedPolyline = enc;
        routeHadEncoded = true;
      }
    } else if (userLL != null && destLL != null) {
      // preferir manter polyline anterior se havia encoded recente ou destino acabou de aparecer
      boolean waitForEncoded = routeHadEncoded || (destSetAtMs != null && (now - destSetAtMs) < 350);
      if (!waitForEncoded && (userChanged || destChanged || routePolyline == null)) {
        List<LatLng> pts = Arrays.asList(userLL, destLL);
        // Keep snake animation according to flag for visual quality
        if (routePolyline == null) drawRoute(userLL, destLL, enableRouteSnake); else routePolyline.setPoints(pts);
        lastRoutePoints = pts;
        routeChanged = true;
      }
      lastEncodedPolyline = null;
    } else {
      if (routePolyline != null) { routePolyline.remove(); routePolyline = null; }
      lastRoutePoints = null;
      lastEncodedPolyline = null;
      routeHadEncoded = false;
    }

    // CAMERA: sÃƒÂ³ quando a rota mudou ou destino ficou disponÃƒÂ­vel agora
    boolean destBecameSet = (lastDestLL == null && destLL != null);
    final long nowMs2 = System.currentTimeMillis();
    final boolean blockCamera = nowMs2 < cameraAnimatingUntilMs;
    if (!blockCamera && (routeChanged || destBecameSet)) {
      // Do not show overlay here; multi-stage camera below minimizes flashes without dark cover.
      // Keep destination marker snapped to route end when route updates
      try {
        if (destMarker != null && lastRoutePoints != null && lastRoutePoints.size() >= 2) {
          destMarker.setPosition(lastRoutePoints.get(lastRoutePoints.size() - 1));
        }
      } catch (Exception ignored) {}
      if (autoFitCamera && lastRoutePoints != null && lastRoutePoints.size() >= 2) {
        int pad = 120 + Math.max(0, brandPadBottom);
        if (ultraLowSpecMode) {
          try {
            LatLngBounds.Builder bd = LatLngBounds.builder();
            for (LatLng p : lastRoutePoints) bd.include(p);
            map.animateCamera(CameraUpdateFactory.newLatLngBounds(bd.build(), pad));
          } catch (Exception ignored) {}
        } else {
          animate3DBounds(lastRoutePoints, pad);
        }
      }
    } else if (!blockCamera && userLL != null && destLL == null) {
      // Quando destino nÃ£o existe (ou foi limpo), volte para o usuÃ¡rio suavemente
      float bearing = 0f;
      try { bearing = map.getCameraPosition().bearing; } catch (Exception ignored) {}
      if (autoFitCamera) {
        map.animateCamera(CameraUpdateFactory.newCameraPosition(new CameraPosition(userLL, 16.0f, 50f, bearing)));
      }
    }

    // update last markers
    lastUserLL = userLL;
    lastDestLL = destLL;

    // (removido) Rota duplicada: jÃƒÂ¡ tratada acima por polyline/fallback
>>>>>>> 10c9b5c (new frkdfm)
  }

  // ========================= DRIVERS =========================
  private void updateDriverMarker(String id, LatLng target, float rotation, int durationMs) {
    if (map == null) return;
    Marker m = driverMarkers.get(id);
    if (m == null) {
      MarkerOptions mo = new MarkerOptions()
          .position(target)
          .anchor(0.5f, 0.5f)
<<<<<<< HEAD
          .flat(true)
          .rotation(rotation);
      if (driverIconBitmap != null) {
        mo.icon(BitmapDescriptorFactory.fromBitmap(driverIconBitmap));
      } else {
        mo.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_YELLOW));
      }
=======
          // Evita distorÃ§Ã£o com tilt: nÃ£o deixa deitar no chÃ£o
          .flat(false)
          .rotation(rotation);
      if (driverIconBitmap == null) {
        // Defer marker creation until icon is available to avoid default pin flicker
        pendingDriverPositions.put(id, target);
        return;
      }
      mo.icon(BitmapDescriptorFactory.fromBitmap(driverIconBitmap));
>>>>>>> 10c9b5c (new frkdfm)
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
<<<<<<< HEAD
    anim.setDuration(Math.max(300, durationMs));
=======
    anim.setInterpolator(new LinearInterpolator());
    int dur = Math.max(300, durationMs);
    if (ultraLowSpecMode) dur = Math.min(dur, 900);
    anim.setDuration(dur);
>>>>>>> 10c9b5c (new frkdfm)
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
<<<<<<< HEAD
    PolylineOptions po = new PolylineOptions().addAll(pts).width(routeWidth).color(routeColor).geodesic(true);
=======
    PolylineOptions po = new PolylineOptions()
        .addAll(pts)
        .width(routeWidth)
        .color(routeColor)
        .geodesic(true)
        .startCap(new RoundCap())
        .endCap(new RoundCap())
        .jointType(JointType.ROUND)
        .zIndex(1f);
>>>>>>> 10c9b5c (new frkdfm)
    routePolyline = map.addPolyline(po);

    if (snake) animatePolyline(routePolyline, from, to);
  }

<<<<<<< HEAD
  private void animatePolyline(Polyline pl, LatLng from, LatLng to) {
    if (pl == null) return;
    final int steps = 120; // suavidade
    final long total = 1800; // ms
=======
  private void drawPolyline(List<LatLng> pts, boolean snake) {
    if (map == null || pts == null || pts.size() < 2) return;
    if (routePolyline != null) routePolyline.remove();
    PolylineOptions po = new PolylineOptions()
        .addAll(pts)
        .width(routeWidth)
        .color(routeColor)
        .geodesic(false)
        .startCap(new RoundCap())
        .endCap(new RoundCap())
        .jointType(JointType.ROUND)
        .zIndex(1f);
    routePolyline = map.addPolyline(po);
    if (snake) animatePolylineDiscrete(routePolyline, pts);
  }

  private static float bearingBetween(LatLng from, LatLng to) {
    double lat1 = Math.toRadians(from.latitude);
    double lon1 = Math.toRadians(from.longitude);
    double lat2 = Math.toRadians(to.latitude);
    double lon2 = Math.toRadians(to.longitude);
    double dLon = lon2 - lon1;
    double y = Math.sin(dLon) * Math.cos(lat2);
    double x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
    double brng = Math.toDegrees(Math.atan2(y, x));
    return (float)((brng + 360.0) % 360.0);
  }

  private static String initialsFromName(String name) {
    try {
      String[] parts = name.trim().toUpperCase().split("\\s+");
      if (parts.length == 0) return "?";
      if (parts.length == 1) return parts[0].substring(0, 1);
      return parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1);
    } catch (Exception e) { return "?"; }
  }

  private static Bitmap makeInitialsBadge(String initials, int sizePx, int bgColor, int fgColor) {
    Bitmap out = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888);
    Canvas canvas = new Canvas(out);
    Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
    paint.setColor(bgColor);
    float r = sizePx / 2f;
    canvas.drawCircle(r, r, r, paint);
    // text
    Paint text = new Paint(Paint.ANTI_ALIAS_FLAG);
    text.setColor(fgColor);
    text.setTextAlign(Paint.Align.CENTER);
    text.setTypeface(Typeface.create(Typeface.DEFAULT, Typeface.BOLD));
    text.setTextSize(sizePx * 0.42f);
    Paint.FontMetrics fm = text.getFontMetrics();
    float cy = r - (fm.ascent + fm.descent) / 2f;
    canvas.drawText(initials, r, cy, text);
    // outer subtle ring
    Paint ring = new Paint(Paint.ANTI_ALIAS_FLAG);
    ring.setStyle(Paint.Style.STROKE);
    ring.setColor(Color.parseColor("#33000000"));
    ring.setStrokeWidth(sizePx * 0.06f);
    canvas.drawCircle(r, r, r - ring.getStrokeWidth()/2f, ring);
    return out;
  }

  

  private static boolean equalsLatLng(LatLng a, LatLng b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    return Math.abs(a.latitude - b.latitude) < 1e-9 && Math.abs(a.longitude - b.longitude) < 1e-9;
  }

  private void animatePolylineDiscrete(Polyline pl, List<LatLng> pts) {
    if (pl == null || pts == null || pts.size() < 2) return;
    final int steps = Math.min(180, Math.max(60, pts.size() * 3));
    final long total = 1200;
    final long step = total / steps;
    List<LatLng> acc = new ArrayList<>();
    acc.add(pts.get(0));
    for (int i = 1; i < pts.size(); i++) {
      final int k = i;
      main.postDelayed(() -> {
        acc.add(pts.get(k));
        pl.setPoints(acc);
      }, step * i);
    }
  }

  // Decode Google Encoded Polyline
  private static List<LatLng> decodePoly(String encoded) {
    List<LatLng> poly = new ArrayList<>();
    int index = 0, len = encoded.length();
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.charAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.charAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng p = new LatLng(lat / 1E5, lng / 1E5);
      poly.add(p);
    }
    return poly;
  }

  private void animatePolyline(Polyline pl, LatLng from, LatLng to) {
    if (pl == null) return;
    final int steps = 120; // suavidade
    final long total = 2200; // ms
>>>>>>> 10c9b5c (new frkdfm)
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
<<<<<<< HEAD
}
=======

  // ========================= Camera helpers =========================
  private static double latRad(double lat) {
    double s = Math.sin(Math.toRadians(lat));
    double y = Math.log((1 + s) / (1 - s)) / 2;
    // clamp to Mercator limits
    return Math.max(Math.min(y, Math.PI), -Math.PI) / 2;
  }

  private static float zoomForBounds(LatLngBounds b, int widthPx, int heightPx, int paddingPx) {
    final double WORLD_PX = 256.0;
    final double ZOOM_MAX = 21.0;
    int w = Math.max(1, widthPx - paddingPx * 2);
    int h = Math.max(1, heightPx - paddingPx * 2);

    double latFraction = (latRad(b.northeast.latitude) - latRad(b.southwest.latitude)) / Math.PI;
    double lngDiff = b.northeast.longitude - b.southwest.longitude;
    if (lngDiff < 0) lngDiff += 360;
    double lngFraction = lngDiff / 360.0;

    double zoomLat = Math.log(h / WORLD_PX / latFraction) / Math.log(2);
    double zoomLng = Math.log(w / WORLD_PX / lngFraction) / Math.log(2);
    double zoom = Math.min(Math.min(zoomLat, zoomLng), ZOOM_MAX);
    if (Double.isInfinite(zoom) || Double.isNaN(zoom)) zoom = 16.0; // fallback
    return (float) zoom;
  }

  private static LatLng centerOfBounds(LatLngBounds b) {
    double lat = (b.northeast.latitude + b.southwest.latitude) / 2.0;
    double lng = (b.northeast.longitude + b.southwest.longitude) / 2.0;
    return new LatLng(lat, lng);
  }

  private void animate3DBounds(List<LatLng> pts, int paddingPx) {
    if (map == null || pts == null || pts.size() < 2) return;
    try { cameraAnimatingUntilMs = System.currentTimeMillis() + 1200; } catch (Exception ignored) {}
    LatLngBounds.Builder bd = LatLngBounds.builder();
    for (LatLng p : pts) bd.include(p);
    LatLngBounds bounds = bd.build();
    int w = root.getWidth();
    int h = root.getHeight();
    float penalty = 1.1f; // slightly lighter zoom-in to reduce tile churn

    if (w <= 0 || h <= 0) {
      // Fallback: simple bounds then gentle tilt
      map.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, paddingPx), 700,
          new GoogleMap.CancelableCallback() {
            @Override public void onFinish() {
              try {
                CameraPosition cp0 = map.getCameraPosition();
                float brg = bearingBetween(pts.get(0), pts.get(pts.size()-1));
                CameraPosition cam2 = new CameraPosition(cp0.target, Math.max(0f, cp0.zoom - penalty), 45f, brg);
                map.animateCamera(CameraUpdateFactory.newCameraPosition(cam2), 700, null);
              } catch (Exception ignored) {}
            }
            @Override public void onCancel() {}
          });
      return;
    }

    int extraPad = (int)(paddingPx * 1.15f);
    float targetZoom = zoomForBounds(bounds, w, h, extraPad);
    LatLng center = centerOfBounds(bounds);
    float brg = bearingBetween(pts.get(0), pts.get(pts.size()-1));

    // Stage 1: smooth re-center with minimal zoom change, no tilt (keeps visible tiles, avoids white)
    CameraPosition cpCurrent;
    try { cpCurrent = map.getCameraPosition(); } catch (Exception e) { cpCurrent = new CameraPosition(center, 16f, 0f, 0f); }
    boolean bigZoomDelta = Math.abs(((cpCurrent != null) ? cpCurrent.zoom : 16f) - targetZoom) > 1.8f;
    if (bigZoomDelta) {
      // Mask only when zoom delta is big enough to risk visible tile flashes
      try {
        if (lastSnapshot != null) snapshotOverlay.setImageBitmap(lastSnapshot); else snapshotOverlay.setImageDrawable(new ColorDrawable(DARK_CANVAS_COLOR));
        snapshotOverlay.setVisibility(View.VISIBLE);
        snapshotOverlay.setAlpha(1f);
      } catch (Exception ignored) {}
    }
    float midZoom = cpCurrent != null ? (cpCurrent.zoom + targetZoom) / 2f : targetZoom;
    CameraPosition cam1 = new CameraPosition(center, midZoom, 0f, brg);

    // Stage 2: introduce tilt and finalize zoom gracefully
    CameraPosition cam2 = new CameraPosition(center, Math.max(0f, targetZoom - penalty), 45f, brg);

    map.animateCamera(CameraUpdateFactory.newCameraPosition(cam1), 500,
        new GoogleMap.CancelableCallback() {
          @Override public void onFinish() {
            try {
              map.animateCamera(
                  CameraUpdateFactory.newCameraPosition(cam2),
                  700,
                  new GoogleMap.CancelableCallback() {
                    @Override public void onFinish() {
                      try { map.setBuildingsEnabled(true); } catch (Exception ignored) {}
                      // Refresh snapshot before hiding to avoid any white at settle
                      takeSnapshotAndThen(2, 100, () -> hideSnapshotOverlayDelayed(140));
                    }
                    @Override public void onCancel() {}
                  }
              );
            } catch (Exception ignored) {}
          }
          @Override public void onCancel() {
            // Try to settle to final cam nonetheless
            try {
              map.animateCamera(
                CameraUpdateFactory.newCameraPosition(cam2),
                500,
                new GoogleMap.CancelableCallback() {
                  @Override public void onFinish() {
                    try { map.setBuildingsEnabled(true); } catch (Exception ignored) {}
                    takeSnapshotAndThen(2, 100, () -> hideSnapshotOverlayDelayed(160));
                  }
                  @Override public void onCancel() {}
                }
              );
            } catch (Exception ignored) {}
          }
        });
  }
}































>>>>>>> 10c9b5c (new frkdfm)
