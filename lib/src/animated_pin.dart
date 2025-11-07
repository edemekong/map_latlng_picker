import 'package:flutter/material.dart';
import 'pin_state.dart';

/// Animated pin widget with physics-based bounce and shadow effects
/// 
/// Supports two modes:
/// - Simple mode: Use [isElevated] for basic boolean elevation state
/// - Advanced mode: Use [state] for PinState enum with enhanced animations
class AnimatedLocationPin extends StatefulWidget {
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

  const AnimatedLocationPin({
    super.key,
    this.state,
    this.isElevated = false,
    this.color = Colors.red,
    this.innerColor = Colors.white,
    this.stickColor,
    this.stickBorderRadius = 0,
    this.shadowColor = Colors.black26,
    this.size = 40,
    this.stickHeight = 20,
    this.shadowDistance = 15,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<AnimatedLocationPin> createState() => _AnimatedLocationPinState();
}

class _AnimatedLocationPinState extends State<AnimatedLocationPin>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _liftController;

  late Animation<double> _squashAnimation;
  late Animation<double> _stretchAnimation;
  late Animation<double> _shadowOpacity;
  late Animation<double> _shadowDistance;

  bool _wasElevated = false;
  PinState _previousState = PinState.idle;

  bool get _isAdvancedMode => widget.state != null;
  bool get _currentElevated => _isAdvancedMode 
      ? widget.state == PinState.elevated 
      : widget.isElevated;

  @override
  void initState() {
    super.initState();
    _wasElevated = _currentElevated;
    _previousState = widget.state ?? PinState.idle;

    // Lift animation controller (for advanced mode)
    _liftController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Bounce animation controller
    _bounceController = AnimationController(
      duration: _isAdvancedMode 
          ? const Duration(milliseconds: 450)
          : const Duration(milliseconds: 400),
      vsync: this,
    );

    _setupAnimations();
  }

  void _setupAnimations() {
    if (_isAdvancedMode) {
      // Advanced mode: Enhanced bounce with more pronounced effect
      _squashAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.35)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 15,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.35, end: 0.92)
              .chain(CurveTween(curve: Curves.bounceOut)),
          weight: 25,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.92, end: 1.08)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.08, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 30,
        ),
      ]).animate(_bounceController);

      _stretchAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.65)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 15,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.65, end: 1.15)
              .chain(CurveTween(curve: Curves.bounceOut)),
          weight: 25,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.15, end: 0.96)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.96, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 30,
        ),
      ]).animate(_bounceController);

      // Shadow animations for advanced mode
      _shadowOpacity = Tween<double>(begin: 0.0, end: 0.35).animate(
        CurvedAnimation(parent: _liftController, curve: Curves.easeOut),
      );

      _shadowDistance = Tween<double>(begin: 0.0, end: widget.shadowDistance).animate(
        CurvedAnimation(parent: _liftController, curve: Curves.easeOut),
      );
    } else {
      // Simple mode: Basic bounce effect
      _squashAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.3, end: 0.95)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 20,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.95, end: 1.05)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.05, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 30,
        ),
      ]).animate(_bounceController);

      _stretchAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.7)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.7, end: 1.1)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 20,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 0.98)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.98, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 30,
        ),
      ]).animate(_bounceController);
    }
  }

  @override
  void didUpdateWidget(AnimatedLocationPin oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isAdvancedMode) {
      // Advanced mode: Handle state transitions
      if (widget.state != _previousState) {
        switch (widget.state!) {
          case PinState.idle:
            if (_previousState == PinState.elevated) {
              // Dropping - trigger bounce
              _liftController.reverse();
              _bounceController.forward(from: 0);
            }
            break;
          case PinState.elevated:
            // Lifting up
            _liftController.forward();
            break;
        }
        _previousState = widget.state!;
      }
    } else {
      // Simple mode: Detect when pin drops (was elevated, now not)
      if (_wasElevated && !widget.isElevated) {
        _bounceController.forward(from: 0);
      }
      _wasElevated = widget.isElevated;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _liftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stickWidth = widget.size * 0.15;

    if (_isAdvancedMode) {
      // Advanced mode: Use lift controller for smooth shadow transitions
      return AnimatedBuilder(
        animation: Listenable.merge([_bounceController, _liftController]),
        builder: (context, child) {
          // Calculate shadow size based on state
          final shadowWidth = widget.state == PinState.elevated 
              ? stickWidth * 1.2 
              : stickWidth * 0.8;
          final shadowHeight = widget.state == PinState.elevated
              ? stickWidth * 0.4
              : stickWidth * 0.25;
          final shadowOpacity = widget.state == PinState.elevated
              ? _shadowOpacity.value
              : _shadowOpacity.value * 0.5;
              
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The pin with bounce effect
              Transform.scale(
                scaleX: _squashAnimation.value,
                scaleY: _stretchAnimation.value,
                child: _buildPin(),
              ),

              // Shadow with smooth distance animation
              SizedBox(height: _shadowDistance.value),
              Container(
                width: shadowWidth,
                height: shadowHeight,
                decoration: BoxDecoration(
                  color: widget.shadowColor.withOpacity(shadowOpacity),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Simple mode: Use AnimatedContainer for shadow
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pin (circle + stick) with bounce
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.scale(
                scaleX: _squashAnimation.value,
                scaleY: _stretchAnimation.value,
                child: child,
              );
            },
            child: _buildPin(),
          ),

          // Shadow that clips to map when dropping
          AnimatedContainer(
            duration: widget.duration,
            curve: Curves.easeOut,
            // When elevated, shadow has gap; when idle, clips to pin tip
            margin: EdgeInsets.only(top: widget.isElevated ? 8 : 0),
            width: widget.isElevated ? stickWidth * 1.2 : stickWidth * 0.8,
            height: widget.isElevated ? stickWidth * 0.4 : stickWidth * 0.25,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(widget.isElevated ? 0.3 : 0.2),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPin() {
    final stickWidth = widget.size * 0.15;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circle with inner dot
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.35,
              height: widget.size * 0.35,
              decoration: BoxDecoration(
                color: widget.innerColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        // Stick
        Container(
          width: stickWidth,
          height: widget.stickHeight,
          decoration: BoxDecoration(
            color: widget.stickColor ?? widget.color,
            borderRadius: BorderRadius.circular(widget.stickBorderRadius),
          ),
        ),
      ],
    );
  }
}