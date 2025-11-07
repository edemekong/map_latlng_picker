import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'animated_pin.dart';

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

  const LatLngLocationPicker({super.key, required this.child, this.controller, this.onLocationPicked, this.pinWidget, this.pinOffset = 50, this.enabled = false, this.useHapticFeedback = true});

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

        // Default animated pin
        return AnimatedLocationPin(isElevated: _isPanning, color: Colors.red, innerColor: Colors.white, size: 45, stickHeight: 22,);
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
