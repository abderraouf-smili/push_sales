import 'package:flutter/material.dart';
import 'package:push_sale/core/responsive/responsive_layout.dart';
import 'package:push_sale/core/responsive/responsive_values.dart';

class AppResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool center;

  const AppResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveLayout(
        center: center,
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: ResponsiveValues.horizontalPadding(context),
                vertical: 16,
              ),
          child: child,
        ),
      ),
    );
  }
}
