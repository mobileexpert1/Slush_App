import 'package:flutter/material.dart';

class CustomSliderThumb extends SliderComponentShape {
  final int displayValue;
  CustomSliderThumb({required this.displayValue});
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(40, 40); // Adjust the size as needed
  }
  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;
    // Draw the thumb circle
    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 10.0, paint);
    // Draw the value indicator
    final TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      text: '$displayValue km',
    );
    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: textDirection,
    );
    tp.layout();
    final Offset textCenter = Offset(
      center.dx - (tp.width / 2),
      center.dy - 50, // Adjust the offset as needed
    );
    // Draw a rounded rectangle as a background for the value indicator
    final Rect rect = Rect.fromCenter(
      center: textCenter + Offset(tp.width / 2, tp.height / 2),
      width: tp.width + 8, // Adjust the width padding as needed
      height: tp.height + 10, // Adjust the height padding as needed
    );
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(4));
    final Paint rrectPaint = Paint()..color = Colors.blue;
    canvas.drawRRect(rrect, rrectPaint);
    tp.paint(canvas, textCenter);
  }
}