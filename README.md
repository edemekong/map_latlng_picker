# LatLng Picker

A beautiful Flutter package that provides an interactive location latitude and longitude picker with physics-based animations for Google Maps. Pick locations with style using an animated pin that bounces and elevates with realistic physics.

<!-- Add your demo GIF or image here -->

![Demo](demo.gif)

## What is it?

**LatLng Picker** is a wrapper widget for Google Maps Flutter that adds an intuitive latitude and longitude picking experience. Instead of placing markers, users can pan the map while a fixed center pin shows where they're selecting. The pin features smooth animations with:

- Fixed center positioning
- Physics-based bounce effects
- Elevation animations with dynamic shadows
- Haptic feedback
- Fully customizable appearance

## Under the Hood

This package uses:

- **[google_maps_flutter](https://pub.dev/packages/google_maps_flutter)** - The official Google Maps plugin for Flutter
- **Flutter's Animation Framework** - For smooth, physics-based pin animations
- **Custom AnimationControllers** - To orchestrate bounce, stretch, and shadow effects

## How to Use

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  latlng_picker: ^0.0.1
  google_maps_flutter: ^2.5.0
```

### Basic Usage

Simply wrap your `GoogleMap` widget with `LatLngLocationPicker`:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlng_picker/latlng_picker.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final LatLngLocationPickerController _controller = LatLngLocationPickerController();
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick Location')),
      body: LatLngLocationPicker(
        controller: _controller,
        enabled: true,
        onLocationPicked: (location) {
          setState(() {
            _selectedLocation = location;
          });
          print('Selected: ${location.latitude}, ${location.longitude}');
        },
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(37.7749, -122.4194),
            zoom: 14,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.isEnabled
            ? _controller.disable?.call()
            : _controller.enable?.call();
        },
        child: Icon(_controller.isEnabled ? Icons.check : Icons.location_on),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Advanced Usage with Custom Pin

```dart
LatLngLocationPicker(
  enabled: true,
  pinOffset: 60,
  useHapticFeedback: true,
  onLocationPicked: (location) {
    // Handle picked location
  },
  pinWidget: AnimatedLocationPin(
    state: _isPanning ? PinState.elevated : PinState.idle,
    color: Colors.blue,
    innerColor: Colors.white,
    size: 50,
    stickHeight: 25,
    shadowDistance: 20,
  ),
  child: GoogleMap(
    initialCameraPosition: CameraPosition(
      target: LatLng(37.7749, -122.4194),
      zoom: 14,
    ),
  ),
)
```

## Parameters

### LatLngLocationPicker

| Parameter           | Type                              | Default      | Description                                                       |
| ------------------- | --------------------------------- | ------------ | ----------------------------------------------------------------- |
| `child`             | `Widget`                          | **required** | The GoogleMap widget to wrap                                      |
| `controller`        | `LatLngLocationPickerController?` | `null`       | Controller to enable/disable picker programmatically              |
| `onLocationPicked`  | `OnLatLngLocationPicked?`         | `null`       | Callback fired when user releases the map                         |
| `pinWidget`         | `Widget?`                         | `null`       | Custom pin widget (uses AnimatedLocationPin by default)           |
| `pinOffset`         | `double`                          | `50`         | Vertical offset from center (useful for pins with bottom pointer) |
| `enabled`           | `bool`                            | `false`      | Whether location picker is enabled by default                     |
| `useHapticFeedback` | `bool`                            | `true`       | Enable haptic feedback on pan start/end                           |

### AnimatedLocationPin

| Parameter           | Type        | Default                       | Description                                      |
| ------------------- | ----------- | ----------------------------- | ------------------------------------------------ |
| `state`             | `PinState?` | `null`                        | Advanced mode: Control pin state (idle/elevated) |
| `isElevated`        | `bool`      | `false`                       | Simple mode: Whether pin is elevated             |
| `color`             | `Color`     | `Colors.red`                  | Main circle color                                |
| `innerColor`        | `Color`     | `Colors.white`                | Inner dot color                                  |
| `stickColor`        | `Color?`    | `null`                        | Stick color (defaults to main color)             |
| `stickBorderRadius` | `double`    | `0`                           | Border radius of the stick                       |
| `shadowColor`       | `Color`     | `Colors.black26`              | Shadow color                                     |
| `size`              | `double`    | `40`                          | Pin size (circle diameter)                       |
| `stickHeight`       | `double`    | `20`                          | Height of the stick                              |
| `shadowDistance`    | `double`    | `15`                          | Shadow distance when elevated (advanced mode)    |
| `duration`          | `Duration`  | `Duration(milliseconds: 200)` | Animation duration (simple mode)                 |

### LatLngLocationPickerController

| Method/Property | Type            | Description                   |
| --------------- | --------------- | ----------------------------- |
| `enable()`      | `VoidCallback?` | Enable location picking mode  |
| `disable()`     | `VoidCallback?` | Disable location picking mode |
| `isEnabled`     | `bool`          | Get current enabled state     |
| `dispose()`     | `void`          | Clean up controller resources |

## Pin Animation Modes

### Simple Mode (Boolean)

Use `isElevated` for basic on/off elevation:

```dart
AnimatedLocationPin(
  isElevated: _isPanning,
)
```

### Advanced Mode (PinState)

Use `state` for enhanced animations with smoother transitions:

```dart
AnimatedLocationPin(
  state: _isPanning ? PinState.elevated : PinState.idle,
)
```

## Examples

### Example 1: Basic Location Picker

```dart
LatLngLocationPicker(
  enabled: true,
  onLocationPicked: (location) {
    print('Location: ${location.latitude}, ${location.longitude}');
  },
  child: GoogleMap(
    initialCameraPosition: CameraPosition(
      target: LatLng(0, 0),
      zoom: 10,
    ),
  ),
)
```

### Example 2: With Controller

```dart
final controller = LatLngLocationPickerController();

// Enable picker
controller.enable?.call();

// Disable picker
controller.disable?.call();

// Check state
if (controller.isEnabled) {
  // Picker is active
}
```

### Example 3: Custom Styled Pin

```dart
LatLngLocationPicker(
  enabled: true,
  pinWidget: AnimatedLocationPin(
    isElevated: _isPanning,
    color: Colors.purple,
    innerColor: Colors.yellow,
    size: 60,
    stickHeight: 30,
    stickBorderRadius: 4,
  ),
  child: GoogleMap(
    initialCameraPosition: CameraPosition(
      target: LatLng(37.7749, -122.4194),
      zoom: 14,
    ),
  ),
)
```

## Features

- Smooth physics-based animations  
- Customizable pin appearance  
- Haptic feedback support  
- Controller for programmatic control  
- Works as a simple wrapper - no map recreation needed  
- Preserves all GoogleMap properties and callbacks  
- Two animation modes (simple boolean and advanced state-based)  
- Dynamic shadow effects

## Author

**Paul Jeremiah**  
Twitter: [@edeme_kong](https://x.com/edeme_kong)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
# latlng_picker
