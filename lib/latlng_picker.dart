/// A Flutter package for interactive location latitude and longitude picking with Google Maps.
///
/// This library provides a beautiful location latitude and longitude picker with physics-based animations
/// that wraps around the Google Maps Flutter widget.
///
/// ## Features
/// - Animated pin with bounce and elevation effects
/// - Haptic feedback support
/// - Customizable appearance
/// - Controller for programmatic control
/// - Works as a simple wrapper around GoogleMap
///
/// ## Basic Usage
/// ```dart
/// LatLngLocationPicker(
///   enabled: true,
///   onLocationPicked: (location) {
///     print('Selected: ${location.latitude}, ${location.longitude}');
///   },
///   child: GoogleMap(
///     initialCameraPosition: CameraPosition(
///       target: LatLng(37.7749, -122.4194),
///       zoom: 14,
///     ),
///   ),
/// )
/// ```
///
/// Author: Paul Jeremiah (@edeme_kong)
library latlng_picker;

export 'src/location_picker.dart';
export 'src/animated_pin.dart';
export 'src/pin_state.dart';
