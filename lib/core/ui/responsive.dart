import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  final double width;

  Responsive(this.width);

  static Responsive of(BuildContext context) {
    return Responsive(MediaQuery.of(context).size.width);
  }

  // ───────────────── BREAKPOINTS ─────────────────

  ScreenSize get screenSize {
    if (width < 768) return ScreenSize.mobile;
    if (width < 1200) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;

  // ───────────────── LAYOUT HELPERS ─────────────────

  double get contentWidth {
    if (width < 768) return width;
    if (width < 1200) return width;
    if (width < 1440) return 1200;
    if (width < 1800) return 1400;
    return width * 0.85;
  }

  EdgeInsets get pagePadding {
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(16);
      case ScreenSize.tablet:
        return const EdgeInsets.all(24);
      case ScreenSize.desktop:
        return const EdgeInsets.all(32);
    }
  }
}

// ✅ EXTENSION (USO CONSIGLIATO)
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive.of(this);
}