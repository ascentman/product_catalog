import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

typedef LayoutBuilder = Widget Function(BuildContext context);

class AdaptiveLayout extends StatelessWidget {
  final LayoutBuilder phoneLayout;
  final LayoutBuilder tabletLayout;

  const AdaptiveLayout({
    super.key,
    required this.phoneLayout,
    required this.tabletLayout,
  });

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;
  }

  static bool isPhone(BuildContext context) => !isTablet(context);

  @override
  Widget build(BuildContext context) {
    return isTablet(context) ? tabletLayout(context) : phoneLayout(context);
  }
}
