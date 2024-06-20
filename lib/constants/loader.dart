import 'package:flutter/material.dart';
import 'package:slush/constants/color.dart';

class LoaderOverlay {
  static OverlayEntry? _loaderOverlayEntry;
  static bool _isVisible = false;

  static void show(BuildContext context) {
    if (!_isVisible) {
      _loaderOverlayEntry = OverlayEntry(builder: (BuildContext context) => _LoaderWidget(),);

      Overlay.of(context).insert(_loaderOverlayEntry!);
      _isVisible = true;
    }
  }

  static void hide() {
    if (_isVisible) {
      _loaderOverlayEntry?.remove();
      _isVisible = false;
    }
  }
}

class _LoaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(
          color: color.txtBlue,
        ),
      ),
    );
  }
}
