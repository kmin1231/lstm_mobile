import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  ResponsiveLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double screenWidth = constraints.maxWidth;
        print("Current screen width: $screenWidth");

        double containerWidth;
        double containerHeight;

        if (screenWidth <= 450) {
          containerWidth = screenWidth;
          containerHeight = screenWidth * (780 / 360);
        } else {
          containerWidth = 360;
          containerHeight = 780;
        }

        return Container(
          width: containerWidth,
          height: containerHeight,
          child: child,
        );
      },
    );
  }
}