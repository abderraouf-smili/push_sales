import 'package:flutter/widgets.dart';

import 'responsive_values.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final bool center;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: ResponsiveValues.pageMaxWidth(context)),
      child: child,
    );

    if (!center) {
      return content;
    }

    return Align(
      alignment: Alignment.topCenter,
      child: content,
    );
  }
}
