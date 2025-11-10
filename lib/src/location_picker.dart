import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_latlng_picker/map_latlng_picker.dart' show PinState;
import 'animated_pin.dart';

class AnimatePinData {
  /// Pin state (for advanced mode with PinState enum)
  /// If provided, takes precedence over [isElevated]
  final PinState? state;

  /// Whether the pin is currently elevated (for simple boolean mode)
  /// Ignored if [state] is provided
  final bool isElevated;

  /// Main circle color
  final Color color;

  /// Inner circle color
  final Color innerColor;

  /// Stick color (if null, uses main color)
  final Color? stickColor;

  /// Stick border radius
  final double stickBorderRadius;

  /// Shadow color
  final Color shadowColor;

  /// Pin size (diameter of the circle)
  final double size;

  /// Stick height
  final double stickHeight;

  /// Shadow distance when elevated (used in advanced mode)
  final double shadowDistance;

  /// Animation duration for lift/drop (used in simple mode)
  final Duration duration;

  const AnimatePinData({
    this.state,
    this.isElevated = false,
    required this.color,
    required this.innerColor,
    this.stickColor,
    this.stickBorderRadius = 4.0,
    required this.shadowColor,
    this.size = 40.0,
    this.stickHeight = 20.0,
    this.shadowDistance = 10.0,
    this.duration = const Duration(milliseconds: 300),
  });
}

/// Callback when location is picked (when user releases the map)
typedef OnLatLngLocationPicked = void Function(LatLng location);

/// Controller to enable/disable location picking mode
class LatLngLocationPickerController {
  /// Enable or disable location picking mode
  VoidCallback? enable;
  VoidCallback? disable;
  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  void dispose() {
    enable = null;
    disable = null;
  }
}

/// A wrapper widget for GoogleMap that provides location picking functionality
/// with a fixed center pin that animates and provides haptic feedback
class LatLngLocationPicker extends StatefulWidget {
  /// The GoogleMap widget to wrap
  final Widget child;

  /// Controller to manage location picker state
  final LatLngLocationPickerController? controller;

  /// Callback when location is picked
  final OnLatLngLocationPicked? onLocationPicked;

  /// Custom pin widget (optional)
  /// If not provided, uses AnimatedLocationPin by default
  final Widget? pinWidget;

  /// Pin offset from center (useful if pin has pointer at bottom)
  final double pinOffset;

  /// Whether location picker is enabled by default
  final bool enabled;

  /// Whether to use haptic feedback
  final bool useHapticFeedback;

  final AnimatePinData? pinData;

  const LatLngLocationPicker({super.key, required this.child, this.controller, this.onLocationPicked, this.pinWidget, this.pinOffset = 50, this.enabled = false, this.useHapticFeedback = true, this.pinData});

  @override
  State<LatLngLocationPicker> createState() => _LatLngLocationPickerState();
}

class _LatLngLocationPickerState extends State<LatLngLocationPicker> {
  bool _isEnabled = false;
  bool _isPanning = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.enabled;

    // Setup controller callbacks
    if (widget.controller != null) {
      widget.controller!.enable = _enablePicker;
      widget.controller!.disable = _disablePicker;
      widget.controller!._isEnabled = _isEnabled;
    }
  }

  @override
  void didUpdateWidget(covariant LatLngLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(_isEnabled != widget.enabled && oldWidget.enabled != widget.enabled) {
      if(widget.enabled) {
        _enablePicker();
      } else {
        _disablePicker();
      }
    }
  }

  void _enablePicker() {
    setState(() {
      _isEnabled = true;
      if (widget.controller != null) {
        widget.controller!._isEnabled = true;
      }
    });
  }

  void _disablePicker() {
    setState(() {
      _isEnabled = false;
      _isPanning = false;
      if (widget.controller != null) {
        widget.controller!._isEnabled = false;
      }
    });
  }

  void _onCameraMoveStarted() {
    if (!_isEnabled) return;

    setState(() {
      _isPanning = true;
    });

    // Haptic feedback
    if (widget.useHapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  void _onCameraIdle(LatLng center) {
    if (!_isEnabled || !_isPanning) return;

    setState(() {
      _isPanning = false;
    });

    // Haptic feedback
    if (widget.useHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    // Notify location picked
    if (widget.onLocationPicked != null) {
      widget.onLocationPicked!(center);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Wrap GoogleMap and inject callbacks
        _GoogleMapWrapper(onCameraMoveStarted: _onCameraMoveStarted, onCameraIdle: _onCameraIdle, child: widget.child),

        // Fixed center pin
        if (_isEnabled)
          Center(
            child: Transform.translate(offset: Offset(0, -widget.pinOffset), child: _buildPin()),
          ),
      ],
    );
  }

  Widget _buildPin() {
    return Builder(
      builder: (context) {
        if (widget.pinWidget != null) {
          return widget.pinWidget!;
        }

        final AnimatePinData? pinData = widget.pinData;

        final bool isPanning =pinData?.isElevated ?? _isPanning;
        final PinState? state =pinData?.state;
        final PinState effectiveState = state ?? (isPanning ? PinState.elevated : PinState.idle);
        final Color stickColor = pinData?.stickColor ?? pinData?.color ?? Colors.red;
        final double stickBorderRadius = pinData?.stickBorderRadius ?? 4.0;
        final Color shadowColor = pinData?.shadowColor ?? Colors.black54;
        final double shadowDistance = pinData?.shadowDistance ?? 10.0;
        final Duration duration = pinData?.duration ?? const Duration(milliseconds: 300);
        final double size = pinData?.size ?? 45.0;
        final double stickHeight = pinData?.stickHeight ?? 22.0;
        final Color color = pinData?.color ?? Colors.red;
        final Color innerColor = pinData?.innerColor ?? Colors.white; 

        // Default animated pin
        return AnimatedLocationPin(
          state: effectiveState,
          color: color,
          innerColor: innerColor,
          stickColor: stickColor,
          stickBorderRadius: stickBorderRadius,
          shadowColor: shadowColor,
          size: size,
          stickHeight: stickHeight,
          shadowDistance: shadowDistance,
          duration: duration,
        );
      },
    );
  }
}

class _GoogleMapWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onCameraMoveStarted;
  final Function(LatLng)? onCameraIdle;

  const _GoogleMapWrapper({required this.child, this.onCameraMoveStarted, this.onCameraIdle});

  @override
  State<_GoogleMapWrapper> createState() => _GoogleMapWrapperState();
}

class _GoogleMapWrapperState extends State<_GoogleMapWrapper> {
  GoogleMapController? mapController;
  LatLng? _currentCenter;

  @override
  Widget build(BuildContext context) {
    assert(
      widget.child is GoogleMap,
      'LatLngLocationPicker child must be a GoogleMap widget',
    );

    if (widget.child is GoogleMap) {
      final googleMap = widget.child as GoogleMap;

      return GoogleMap(
      key: googleMap.key,
      initialCameraPosition: googleMap.initialCameraPosition,
      style: googleMap.style,
      onMapCreated: (controller) {
        mapController = controller;
        googleMap.onMapCreated?.call(controller);
      },
      gestureRecognizers: googleMap.gestureRecognizers,
      webGestureHandling: googleMap.webGestureHandling,
      webCameraControlPosition: googleMap.webCameraControlPosition,
      webCameraControlEnabled: googleMap.webCameraControlEnabled,
      compassEnabled: googleMap.compassEnabled,
      mapToolbarEnabled: googleMap.mapToolbarEnabled,
      cameraTargetBounds: googleMap.cameraTargetBounds,
      mapType: googleMap.mapType,
      minMaxZoomPreference: googleMap.minMaxZoomPreference,
      rotateGesturesEnabled: googleMap.rotateGesturesEnabled,
      scrollGesturesEnabled: googleMap.scrollGesturesEnabled,
      zoomControlsEnabled: googleMap.zoomControlsEnabled,
      zoomGesturesEnabled: googleMap.zoomGesturesEnabled,
      liteModeEnabled: googleMap.liteModeEnabled,
      tiltGesturesEnabled: googleMap.tiltGesturesEnabled,
      fortyFiveDegreeImageryEnabled: googleMap.fortyFiveDegreeImageryEnabled,
      myLocationEnabled: googleMap.myLocationEnabled,
      myLocationButtonEnabled: googleMap.myLocationButtonEnabled,
      layoutDirection: googleMap.layoutDirection,
      padding: googleMap.padding,
      indoorViewEnabled: googleMap.indoorViewEnabled,
      trafficEnabled: googleMap.trafficEnabled,
      buildingsEnabled: googleMap.buildingsEnabled,
      markers: googleMap.markers,
      polygons: googleMap.polygons,
      polylines: googleMap.polylines,
      circles: googleMap.circles,
      clusterManagers: googleMap.clusterManagers,
      heatmaps: googleMap.heatmaps,
      tileOverlays: googleMap.tileOverlays,
      groundOverlays: googleMap.groundOverlays,
      onCameraMoveStarted: () {
        widget.onCameraMoveStarted?.call();
        googleMap.onCameraMoveStarted?.call();
      },
      onCameraMove: (position) {
        _currentCenter = position.target;
        googleMap.onCameraMove?.call(position);
      },
      onCameraIdle: () async {
        if (_currentCenter != null) {
        widget.onCameraIdle?.call(_currentCenter!);
        }
        googleMap.onCameraIdle?.call();
      },
      onTap: googleMap.onTap,
      onLongPress: googleMap.onLongPress,
      cloudMapId: googleMap.cloudMapId,
      );
    }

    return widget.child;
  }
}
