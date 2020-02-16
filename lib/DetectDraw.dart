import 'package:flutter/material.dart';

class DetectDraw extends CustomPainter {


  Size screenSize;
  Map rect;
  DetectDraw(this.rect, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {

    if(rect != null) {
      print(size);
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
      Rect drawRect = Offset(x, y) & Size(w, h);
      canvas.drawRect(drawRect, paint);

    }

  }

  @override
  bool shouldRepaint(DetectDraw old) => old.rect != rect;

  @override
  bool hitTest(Offset offset) {
    Path path = Path();
    double x, y, w, h;
    x = rect["x"] * screenSize.width;
    y = rect["y"] * screenSize.height;
    w = rect["x"] * screenSize.width;
    h = rect["x"] * screenSize.height;
    Rect drawRect = Offset(x, y) & Size(w, h);
    path.addRect(drawRect);
    path.close();
    return path.contains(offset);
  }

}