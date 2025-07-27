import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billmate/core/navigation/navigation_service.dart';
import 'package:billmate/shared/constants/app_colors.dart';

/// A modern back button widget with haptic feedback and customizable appearance
class ModernBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final bool showTooltip;
  final String? tooltip;
  final bool enableHapticFeedback;
  final IconData? icon;

  const ModernBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.size = 24,
    this.padding,
    this.showTooltip = true,
    this.tooltip,
    this.enableHapticFeedback = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor =
        color ?? Theme.of(context).iconTheme.color ?? AppColors.textPrimary;
    final defaultTooltip =
        tooltip ?? MaterialLocalizations.of(context).backButtonTooltip;

    Widget backButton = IconButton(
      onPressed: () {
        if (enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        if (onPressed != null) {
          onPressed!();
        } else {
          NavigationService.instance.goBack();
        }
      },
      icon: Icon(
        icon ?? Icons.arrow_back_ios_new_rounded,
        color: defaultColor,
        size: size,
      ),
      padding: padding ?? const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );

    if (showTooltip) {
      backButton = Tooltip(message: defaultTooltip, child: backButton);
    }

    return backButton;
  }
}

/// A widget that handles swipe gestures for navigation
class SwipeNavigationWrapper extends StatelessWidget {
  final Widget child;
  final bool enableSwipeBack;
  final bool enableSwipeForward;
  final VoidCallback? onSwipeBack;
  final VoidCallback? onSwipeForward;
  final double swipeThreshold;
  final bool enableHapticFeedback;

  const SwipeNavigationWrapper({
    super.key,
    required this.child,
    this.enableSwipeBack = true,
    this.enableSwipeForward = false,
    this.onSwipeBack,
    this.onSwipeForward,
    this.swipeThreshold = 0.3,
    this.enableHapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (!enableSwipeBack && !enableSwipeForward) return;

        final velocity = details.primaryVelocity ?? 0;

        // Check if swipe is fast enough
        if (velocity.abs() > 500) {
          if (enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }

          // Swipe right (back gesture)
          if (velocity > 0 && enableSwipeBack) {
            if (onSwipeBack != null) {
              onSwipeBack!();
            } else if (NavigationService.instance.canGoBack()) {
              NavigationService.instance.goBack();
            }
          }
          // Swipe left (forward gesture)
          else if (velocity < 0 &&
              enableSwipeForward &&
              onSwipeForward != null) {
            onSwipeForward!();
          }
        }
      },
      child: child,
    );
  }
}

/// A custom app bar with modern navigation features
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  final double? titleSpacing;
  final double toolbarHeight;
  final PreferredSizeWidget? bottom;
  final bool enableSwipeBack;
  final VoidCallback? onBackPressed;

  const ModernAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.titleSpacing,
    this.toolbarHeight = kToolbarHeight,
    this.bottom,
    this.enableSwipeBack = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: actions,
      leading: _buildLeading(context),
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? AppColors.background,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      elevation: elevation,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      bottom: bottom,
    );

    if (enableSwipeBack) {
      appBar = SwipeNavigationWrapper(
        enableSwipeBack: true,
        onSwipeBack: onBackPressed,
        child: appBar,
      );
    }

    return appBar;
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (automaticallyImplyLeading && NavigationService.instance.canGoBack()) {
      return ModernBackButton(onPressed: onBackPressed, color: foregroundColor);
    }

    return null;
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));
}

/// A page wrapper that provides modern navigation features
class ModernNavigationPage extends StatelessWidget {
  final Widget child;
  final bool enableSwipeBack;
  final bool enableSwipeForward;
  final VoidCallback? onSwipeBack;
  final VoidCallback? onSwipeForward;
  final bool enableSystemBackGesture;

  const ModernNavigationPage({
    super.key,
    required this.child,
    this.enableSwipeBack = true,
    this.enableSwipeForward = false,
    this.onSwipeBack,
    this.onSwipeForward,
    this.enableSystemBackGesture = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Wrap with swipe navigation if enabled
    if (enableSwipeBack || enableSwipeForward) {
      content = SwipeNavigationWrapper(
        enableSwipeBack: enableSwipeBack,
        enableSwipeForward: enableSwipeForward,
        onSwipeBack: onSwipeBack,
        onSwipeForward: onSwipeForward,
        child: content,
      );
    }

    // Handle system back button (Android)
    if (enableSystemBackGesture) {
      content = PopScope(
        canPop: NavigationService.instance.canGoBack(),
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && onSwipeBack != null) {
            onSwipeBack!();
          } else if (!didPop) {
            NavigationService.instance.goBack();
          }
        },
        child: content,
      );
    }

    return content;
  }
}

/// A floating action button with modern navigation features
class ModernFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool enableHapticFeedback;
  final String? heroTag;

  const ModernFloatingActionButton({
    super.key,
    this.onPressed,
    this.child,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.shape,
    this.enableHapticFeedback = true,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed:
          onPressed != null
              ? () {
                if (enableHapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                onPressed!();
              }
              : null,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation ?? 6,
      shape: shape ?? const CircleBorder(),
      heroTag: heroTag,
      tooltip: tooltip,
      child: child,
    );
  }
}

/// Extended floating action button with modern features
class ModernFloatingActionButtonExtended extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget label;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool enableHapticFeedback;
  final String? heroTag;
  final EdgeInsetsGeometry? padding;

  const ModernFloatingActionButtonExtended({
    super.key,
    this.onPressed,
    this.icon,
    required this.label,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.shape,
    this.enableHapticFeedback = true,
    this.heroTag,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed:
          onPressed != null
              ? () {
                if (enableHapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                onPressed!();
              }
              : null,
      icon: icon,
      label: label,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation ?? 6,
      shape: shape,
      heroTag: heroTag,
      tooltip: tooltip,
    );
  }
}
