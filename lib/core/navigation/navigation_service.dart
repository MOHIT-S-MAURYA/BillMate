import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A service class to handle navigation throughout the app with modern navigation features
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static NavigationService get instance => _instance;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get navigator => navigatorKey.currentState;
  BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to a new route
  Future<T?> navigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool replace = false,
    bool clearStack = false,
  }) async {
    if (clearStack) {
      return navigator?.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
        arguments: arguments,
      );
    } else if (replace) {
      return navigator?.pushReplacementNamed(routeName, arguments: arguments);
    } else {
      return navigator?.pushNamed(routeName, arguments: arguments);
    }
  }

  /// Navigate to a new route with a widget
  Future<T?> navigateToWidget<T extends Object?>(
    Widget widget, {
    bool replace = false,
    bool clearStack = false,
    PageTransitionType? transitionType,
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) async {
    final route = _createRoute<T>(
      widget,
      transitionType: transitionType ?? PageTransitionType.slideFromRight,
      transitionDuration: transitionDuration,
      transitionCurve: transitionCurve,
    );

    if (clearStack) {
      return navigator?.pushAndRemoveUntil<T>(route, (route) => false);
    } else if (replace) {
      return navigator?.pushReplacement<T, dynamic>(route);
    } else {
      return navigator?.push<T>(route);
    }
  }

  /// Pop the current route
  void goBack<T extends Object?>([T? result]) {
    if (canGoBack()) {
      navigator?.pop(result);
    } else {
      // If we can't go back, minimize the app (Android) or do nothing (iOS)
      SystemNavigator.pop();
    }
  }

  /// Check if we can go back
  bool canGoBack() {
    return navigator?.canPop() ?? false;
  }

  /// Pop until a specific route
  void popUntil(String routeName) {
    navigator?.popUntil(ModalRoute.withName(routeName));
  }

  /// Pop until predicate is true
  void popUntilPredicate(bool Function(Route<dynamic>) predicate) {
    navigator?.popUntil(predicate);
  }

  /// Show a modal bottom sheet with modern design
  Future<T?> showModernBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    double? heightFactor,
    BorderRadius? borderRadius,
  }) {
    return showModalBottomSheet<T>(
      context: context!,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height:
                heightFactor != null
                    ? MediaQuery.of(context).size.height * heightFactor
                    : null,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  borderRadius ??
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: child,
          ),
    );
  }

  /// Show a modern dialog
  Future<T?> showModernDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    Duration? transitionDuration,
  }) {
    return showGeneralDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      barrierLabel: barrierLabel,
      transitionDuration:
          transitionDuration ?? const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// Create a custom page route with transitions
  PageRoute<T> _createRoute<T>(
    Widget widget, {
    PageTransitionType transitionType = PageTransitionType.slideFromRight,
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionDuration:
          transitionDuration ?? const Duration(milliseconds: 300),
      reverseTransitionDuration:
          transitionDuration ?? const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = transitionCurve ?? Curves.easeInOut;
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        switch (transitionType) {
          case PageTransitionType.slideFromRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          case PageTransitionType.slideFromLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          case PageTransitionType.slideFromBottom:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          case PageTransitionType.slideFromTop:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          case PageTransitionType.fade:
            return FadeTransition(opacity: curvedAnimation, child: child);
          case PageTransitionType.scale:
            return ScaleTransition(scale: curvedAnimation, child: child);
          case PageTransitionType.rotation:
            return RotationTransition(turns: curvedAnimation, child: child);
        }
      },
    );
  }
}

/// Enum for different page transition types
enum PageTransitionType {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  fade,
  scale,
  rotation,
}

/// Extension to add navigation methods to BuildContext
extension NavigationExtension on BuildContext {
  NavigationService get navigation => NavigationService.instance;

  Future<T?> navigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool replace = false,
    bool clearStack = false,
  }) => navigation.navigateTo<T>(
    routeName,
    arguments: arguments,
    replace: replace,
    clearStack: clearStack,
  );

  Future<T?> navigateToWidget<T extends Object?>(
    Widget widget, {
    bool replace = false,
    bool clearStack = false,
    PageTransitionType? transitionType,
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) => navigation.navigateToWidget<T>(
    widget,
    replace: replace,
    clearStack: clearStack,
    transitionType: transitionType,
    transitionDuration: transitionDuration,
    transitionCurve: transitionCurve,
  );

  void goBack<T extends Object?>([T? result]) => navigation.goBack<T>(result);

  bool canGoBack() => navigation.canGoBack();

  void popUntil(String routeName) => navigation.popUntil(routeName);

  Future<T?> showModernBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    double? heightFactor,
    BorderRadius? borderRadius,
  }) => navigation.showModernBottomSheet<T>(
    child: child,
    isScrollControlled: isScrollControlled,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    heightFactor: heightFactor,
    borderRadius: borderRadius,
  );

  Future<T?> showModernDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    Duration? transitionDuration,
  }) => navigation.showModernDialog<T>(
    child: child,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    transitionDuration: transitionDuration,
  );
}
