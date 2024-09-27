import 'package:flutter/material.dart';
import 'package:pratishtha/widgets/loadingWidget.dart';

class LoadingFunc {
  static OverlayEntry? ov;
  static show(BuildContext context) {
    ov = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.center,
            child: Center(child: loadingWidget()),
          ),
        );
      },
    );
    Overlay.of(context).insert(ov!);
  }

  static end() {
    ov!.remove();
  }
}
