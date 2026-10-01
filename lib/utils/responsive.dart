import 'package:flutter/material.dart';

// ─── Breakpoints ──────────────────────────────────────────────

/// Breakpoint constants for responsive layout.
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

// ─── Responsive Widget ───────────────────────────────────────

/// Widget to select different layout based on screen size.
///
/// ```dart
/// Responsive(
///   mobile: MobileLayout(),
///   tablet: TabletLayout(),   // optional, fallback to mobile
///   desktop: DesktopLayout(),
/// )
/// ```
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return desktop;
        } else if (constraints.maxWidth >= Breakpoints.tablet) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

// ─── Extension ───────────────────────────────────────────────

/// Extension on [BuildContext] for quick access to responsive helpers.
///
/// ```dart
/// final cols = context.responsive(mobile: 2, tablet: 3, desktop: 4);
/// final padding = context.responsive<double>(mobile: 16, desktop: 32);
/// ```
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.desktop;
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  /// Select value based on current breakpoint.
  /// [tablet] is optional — if null, will fallback to [mobile].
  T responsive<T>({required T mobile, T? tablet, required T desktop}) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
}
