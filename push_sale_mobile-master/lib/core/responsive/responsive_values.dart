import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

class ResponsiveValues {
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.compact;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.phone;

  static double pageMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.desktop) return 1040;
    if (width >= AppBreakpoints.tablet) return 900;
    if (width >= AppBreakpoints.phone) return 720;
    return double.infinity;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.tablet) return 32;
    if (width >= AppBreakpoints.phone) return 24;
    return 16;
  }
}
