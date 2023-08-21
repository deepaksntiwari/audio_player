import 'dart:ui';

import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  final double height;
  final double width;
  final Widget widget;
  final double borderRadius;

  const GlassBox(
      {super.key,
      required this.height,
      required this.width,
      required this.widget,
      required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(children: [
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 2,
              sigmaY: 2,
            ),
            child: SizedBox(),
          ),
          //below container is for gradient
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                gradient: LinearGradient(colors: [
                  Colors.white.withOpacity(0.4),
                  Colors.white.withOpacity(0.1),
                ])),
          ),
          widget
        ]),
      ),
    );
  }
}
