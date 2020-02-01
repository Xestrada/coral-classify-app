import 'package:flutter/material.dart';

class ObjectRect extends CustomPainter {
  Map rect;
  ObjectRect(this.rect);

  @override
  void paint(Canvas canvas, Size size) {

    if(rect != null) {
      final paint = Paint();
      paint.color = Colors.white;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
      double x, y, w, h;
      x = rect["x"] * size.width;
      y = rect["y"] * size.height;
      w = rect["x"] * size.width;
      h = rect["x"] * size.height;
      Rect rect1 = Offset(x, y) & Size(w, h);
      canvas.drawRect(rect1, paint);
    }

  }

  @override
  bool shouldRepaint(ObjectRect old) => old.rect != rect;

}