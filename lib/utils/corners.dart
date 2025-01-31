import 'package:flutter/material.dart';
import 'package:pratishtha/smooth_corners/clip_smooth_rect.dart';
import 'package:pratishtha/smooth_corners/smooth_border_radius.dart';
import 'package:pratishtha/smooth_corners/smooth_rectangle_border.dart';

class SmoothCorners {
  static ShapeBorder shapeBorder({double? radius}) {
    return SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: 10,
        cornerSmoothing: 1,
      ),
    );
  }

  static ClipSmoothRect clipSmoothCorner(
      {double? radius, required Widget child}) {
    return ClipSmoothRect(
      radius: SmoothBorderRadius(
        cornerRadius: radius ?? 10,
        cornerSmoothing: 1,
      ),
      child: child,
    );
  }
}
