# PickerMapNative Usage

This document outlines how to interact with the `PickerMapNative` widget.
It exposes an imperative API via `PickerMapNativeController` that mirrors the
old picker map behaviour.

## Basic Setup

```dart
final controller = PickerMapNativeController();

PickerMapNative(
  controller: controller,
  userLocation: const LatLng(25.0, -80.0),
);
```

## Marker and Shape Management

```dart
await controller.setMarkers([
  {
    'id': 'home',
    'latitude': 25.0,
    'longitude': -80.0,
    'iconUrl': 'https://example.com/home.png',
    'zIndex': 1,
  }
]);

await controller.setPolylines([
  {
    'id': 'route',
    'points': [
      {'latitude': 25.0, 'longitude': -80.0},
      {'latitude': 25.1, 'longitude': -80.1},
    ],
    'width': 4,
    'color': 0xFF0000FF,
  }
]);

await controller.setPolygons([
  {
    'id': 'area',
    'points': [
      {'latitude': 25.0, 'longitude': -80.0},
      {'latitude': 25.0, 'longitude': -80.1},
      {'latitude': 25.1, 'longitude': -80.1},
    ],
    'strokeWidth': 2,
    'strokeColor': 0xFFFF0000,
    'fillColor': 0x11FF0000,
    'zIndex': 0,
  }
]);
```

## Camera Controls

```dart
// Move camera to a specific position
await controller.cameraTo(25.0, -80.0, zoom: 14, bearing: 30);

// Fit bounds
await controller.fitBounds([
  const LatLng(25.0, -80.0),
  const LatLng(25.1, -80.1),
], padding: 60);
```

## Animated Car Position

```dart
await controller.updateCarPosition(
  'car1',
  const LatLng(25.02, -80.02),
  rotation: 90,
  durationMs: 300,
);
```

## Additional Features

* Map style can be supplied through the native side using `mapStyleJson`.
* Traffic layers and custom POI icons are also handled natively when enabled.
* Home05 integrates the map with a fixed 60 px bottom padding.

