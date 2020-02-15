import 'package:flutter/material.dart';

class DetectDraw extends CustomPainter {
  Map rect;
  DetectDraw(this.rect);

  @override
  void paint(Canvas canvas, Size size) {

    if(rect != null) {

      // Draw Rectangle Surrounding Object
      final paint = Paint();
      paint.color = Colors.yellow;
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
  bool shouldRepaint(DetectDraw old) => old.rect != rect;

}