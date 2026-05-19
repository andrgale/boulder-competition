import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  // static double contentWidth(BuildContext context) {
  //   final width = MediaQuery.of(context).size.width;

  //   if (width > 1600) {
  //     return 1400;
  //   }

  //   if (width > 1200) {
  //     return 1100;
  //   }

  //   return width;
  // }

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 768) {
      return width;
    }

    if (width < 1200) {
      return width;
    }

    if (width < 1440) {
      return 1200;
    }

    if (width < 1800) {
      return 1400;
    }

    if (width > 1200) {
      return width * 0.85;
    }

    return 1600;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(32);
    }

    if (isTablet(context)) {
      return const EdgeInsets.all(24);
    }

    return const EdgeInsets.all(16);
  }
}