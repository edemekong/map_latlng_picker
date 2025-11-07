import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlng_picker/src/animated_pin.dart';
import 'package:latlng_picker/src/location_picker.dart';
import 'package:latlng_picker/src/pin_state.dart';

void main() {
  group('PinState', () {
    test('has correct enum values', () {
      expect(PinState.values.length, 2);
      expect(PinState.values, contains(PinState.idle));
      expect(PinState.values, contains(PinState.elevated));
    });
  });

  group('AnimatedLocationPin', () {
    testWidgets('renders with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(),
          ),
        ),
      );

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders with custom colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(
              color: Colors.blue,
              innerColor: Colors.yellow,
              stickColor: Colors.green,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
    });

    testWidgets('renders with custom size', (WidgetTester tester) async {
      const customSize = 60.0;
      const customStickHeight = 30.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(
              size: customSize,
              stickHeight: customStickHeight,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
    });

    testWidgets('simple mode: animates when isElevated changes from true to false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(isElevated: true),
          ),
        ),
      );

      await tester.pump();

      // Change to not elevated - should trigger bounce animation
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(isElevated: false),
          ),
        ),
      );

      // Verify animation is running
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
    });

    testWidgets('advanced mode: uses PinState for animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(state: PinState.idle),
          ),
        ),
      );

      await tester.pump();

      // Change to elevated state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(state: PinState.elevated),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      // Change back to idle - should trigger bounce
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(state: PinState.idle),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
    });

    testWidgets('advanced mode: state takes precedence over isElevated',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(
              state: PinState.idle,
              isElevated: true, // Should be ignored
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
      await tester.pump();
    });

    testWidgets('renders shadow in simple mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(isElevated: false),
          ),
        ),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('renders shadow in advanced mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(state: PinState.idle),
          ),
        ),
      );

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
      // Shadow is rendered as a Container in advanced mode
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('custom shadow properties work', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(
              shadowColor: Colors.red,
              shadowDistance: 25.0,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
    });

    testWidgets('custom stick border radius works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(
              stickBorderRadius: 8.0,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
    });

    testWidgets('animations complete successfully in simple mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(isElevated: true),
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(isElevated: false),
          ),
        ),
      );

      // Let animation complete
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
    });

    testWidgets('animations complete successfully in advanced mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(state: PinState.elevated),
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLocationPin(state: PinState.idle),
          ),
        ),
      );

      // Let animation complete
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
    });
  });

  group('LatLngLocationPickerController', () {
    test('initializes with disabled state', () {
      final controller = LatLngLocationPickerController();
      expect(controller.isEnabled, false);
    });

    test('enable callback can be set and called', () {
      final controller = LatLngLocationPickerController();
      bool enabledCalled = false;

      controller.enable = () {
        enabledCalled = true;
      };

      controller.enable?.call();
      expect(enabledCalled, true);
    });

    test('disable callback can be set and called', () {
      final controller = LatLngLocationPickerController();
      bool disabledCalled = false;

      controller.disable = () {
        disabledCalled = true;
      };

      controller.disable?.call();
      expect(disabledCalled, true);
    });

    test('dispose clears callbacks', () {
      final controller = LatLngLocationPickerController();
      controller.enable = () {};
      controller.disable = () {};

      controller.dispose();

      expect(controller.enable, isNull);
      expect(controller.disable, isNull);
    });
  });

  group('LatLngLocationPicker', () {
    testWidgets('renders with GoogleMap child', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatLngLocationPicker(
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 10,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LatLngLocationPicker), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('does not show pin when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatLngLocationPicker(
              enabled: false,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 10,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedLocationPin), findsNothing);
    });

    testWidgets('shows pin when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatLngLocationPicker(
              enabled: true,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 10,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
    });

    testWidgets('shows custom pin widget when provided',
        (WidgetTester tester) async {
      final customPin = Container(
        key: const Key('custom_pin'),
        width: 50,
        height: 50,
        color: Colors.blue,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatLngLocationPicker(
              enabled: true,
              pinWidget: customPin,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 10,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom_pin')), findsOneWidget);
      expect(find.byType(AnimatedLocationPin), findsNothing);
    });

    testWidgets('controller can enable picker', (WidgetTester tester) async {
      final controller = LatLngLocationPickerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatLngLocationPicker(
              controller: controller,
              enabled: false,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 10,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedLocationPin), findsNothing);
      expect(controller.isEnabled, false);

      // Enable via controller
      controller.enable?.call();
      await tester.pump();

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
      expect(controller.isEnabled, true);
    });

    testWidgets('controller can disable picker', (WidgetTester tester) async {
      final controller = LatLngLocationPickerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatLngLocationPicker(
              controller: controller,
              enabled: true,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 10,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedLocationPin), findsOneWidget);
      expect(controller.isEnabled, true);

      // Disable via controller
      controller.disable?.call();
      await tester.pump();

      expect(find.byType(AnimatedLocationPin), findsNothing);
      expect(controller.isEnabled, false);
    });

    testWidgets('onLocationPicked callback can be set',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatLngLocationPicker(
              enabled: true,
              onLocationPicked: (location) {
                // Callback is set and will be called on camera idle
              },
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.7749, -122.4194),
                  zoom: 10,
                ),
              ),
            ),
          ),
        ),
      );

      // Note: Actually triggering map pan in tests is complex due to GoogleMap
      // being a platform view. This test verifies the structure is correct.
      expect(find.byType(LatLngLocationPicker), findsOneWidget);
    });

    testWidgets('custom pin offset is applied', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatLngLocationPicker(
              enabled: true,
              pinOffset: 100,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 10,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('preserves GoogleMap properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatLngLocationPicker(
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 10,
                ),
                mapType: MapType.satellite,
                compassEnabled: true,
                onMapCreated: (controller) {
                  // Map created callback is preserved
                },
                onCameraMove: (position) {
                  // Camera move callback preserved
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('works without controller', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatLngLocationPicker(
              enabled: true,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 10,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LatLngLocationPicker), findsOneWidget);
      expect(find.byType(AnimatedLocationPin), findsOneWidget);
    });

    testWidgets('works without onLocationPicked callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatLngLocationPicker(
              enabled: true,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 10,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LatLngLocationPicker), findsOneWidget);
    });
  });
}
