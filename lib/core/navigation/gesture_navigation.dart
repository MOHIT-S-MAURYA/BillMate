import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuration for modern gesture navigation
class GestureNavigationConfig {
  /// Minimum velocity for swipe gestures (px/s)
  static const double minimumSwipeVelocity = 500.0;

  /// Minimum distance for swipe gestures (fraction of screen width)
  static const double minimumSwipeDistance = 0.2;

  /// Enable haptic feedback for gestures
  static const bool enableHapticFeedback = true;

  /// Duration for page transitions
  static const Duration transitionDuration = Duration(milliseconds: 300);

  /// Curve for page transitions
  static const Curve transitionCurve = Curves.easeInOut;
}

/// Advanced gesture detector for navigation
class AdvancedGestureNavigator extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final bool enableSwipeBack;
  final bool enableSwipeForward;
  final bool enableVerticalSwipes;
  final bool enableTapGestures;
  final double sensitivityMultiplier;

  const AdvancedGestureNavigator({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onDoubleTap,
    this.onLongPress,
    this.enableSwipeBack = true,
    this.enableSwipeForward = false,
    this.enableVerticalSwipes = false,
    this.enableTapGestures = false,
    this.sensitivityMultiplier = 1.0,
  });

  @override
  State<AdvancedGestureNavigator> createState() =>
      _AdvancedGestureNavigatorState();
}

class _AdvancedGestureNavigatorState extends State<AdvancedGestureNavigator>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isDragging = false;
  double _dragPosition = 0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: GestureNavigationConfig.transitionDuration,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: GestureNavigationConfig.transitionCurve,
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragPosition = details.globalPosition.dx;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final dragDistance = details.globalPosition.dx - _dragPosition;
    final progress = (dragDistance / screenWidth).clamp(-1.0, 1.0);

    if (widget.enableSwipeBack && progress > 0) {
      setState(() {
        _slideController.value = progress * widget.sensitivityMultiplier;
      });
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0;
    final threshold =
        GestureNavigationConfig.minimumSwipeVelocity *
        widget.sensitivityMultiplier;

    if (velocity.abs() > threshold) {
      _triggerHapticFeedback();

      if (velocity > 0 &&
          widget.enableSwipeBack &&
          widget.onSwipeRight != null) {
        _slideController.forward().then((_) {
          widget.onSwipeRight!();
          _slideController.reset();
        });
      } else if (velocity < 0 &&
          widget.enableSwipeForward &&
          widget.onSwipeLeft != null) {
        widget.onSwipeLeft!();
      } else {
        _slideController.reverse();
      }
    } else {
      _slideController.reverse();
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (!widget.enableVerticalSwipes) return;

    final velocity = details.primaryVelocity ?? 0;
    final threshold =
        GestureNavigationConfig.minimumSwipeVelocity *
        widget.sensitivityMultiplier;

    if (velocity.abs() > threshold) {
      _triggerHapticFeedback();

      if (velocity < 0 && widget.onSwipeUp != null) {
        widget.onSwipeUp!();
      } else if (velocity > 0 && widget.onSwipeDown != null) {
        widget.onSwipeDown!();
      }
    }
  }

  void _handleDoubleTap() {
    if (widget.enableTapGestures && widget.onDoubleTap != null) {
      _triggerHapticFeedback();
      widget.onDoubleTap!();
    }
  }

  void _handleLongPress() {
    if (widget.enableTapGestures && widget.onLongPress != null) {
      _triggerHapticFeedback();
      widget.onLongPress!();
    }
  }

  void _triggerHapticFeedback() {
    if (GestureNavigationConfig.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );

    return GestureDetector(
      onHorizontalDragStart: _handleHorizontalDragStart,
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      onVerticalDragEnd: _handleVerticalDragEnd,
      onDoubleTap: _handleDoubleTap,
      onLongPress: _handleLongPress,
      child: content,
    );
  }
}

/// Modern navigation bar with gesture support
class ModernNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ModernNavigationBarItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;
  final bool enableHapticFeedback;

  const ModernNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.enableHapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [
          if (elevation != null && elevation! > 0)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: elevation!,
              offset: const Offset(0, -2),
            ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children:
              items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (enableHapticFeedback) {
                        HapticFeedback.lightImpact();
                      }
                      onTap(index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? (selectedItemColor ??
                                              Theme.of(context).primaryColor)
                                          .withValues(alpha: 0.1)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color:
                                  isSelected
                                      ? selectedItemColor ??
                                          Theme.of(context).primaryColor
                                      : unselectedItemColor ?? Colors.grey,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: isSelected ? 12 : 11,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? selectedItemColor ??
                                          Theme.of(context).primaryColor
                                      : unselectedItemColor ?? Colors.grey,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

/// Navigation bar item for modern navigation
class ModernNavigationBarItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final Widget? badge;

  const ModernNavigationBarItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badge,
  });
}

/// Page transition animations
class PageTransitions {
  /// Slide from right transition (iOS style)
  static Widget slideFromRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end);
    final offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }

  /// Slide from bottom transition (Material style)
  static Widget slideFromBottom(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end);
    final offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }

  /// Fade transition
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  /// Scale transition with fade
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
