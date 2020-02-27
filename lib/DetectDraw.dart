import 'package:flutter/material.dart';

class DetectDraw extends CustomPainter {

  Paint customPaint;
  Size screenSize;
  Map rect;
  DetectDraw(this.rect, this.screenSize, this.customPaint);

  @override
  void paint(Canvas canvas, Size size) {

    if(rect != null) {
      // Draw Rectangle Surrounding Object
      double x, y, w, h;
      x = rect["x"] * size.width;
      y = rect["y"] * size.height;
      w = rect["w"] * size.width;
      h = rect["h"] * size.height;
      Rect drawRect = Offset(x, y) & Size(w, h);
      canvas.drawRect(drawRect, customPaint);
    }

  }

  @override
  bool shouldRepaint(DetectDraw old) => old.rect != rect;

  @override
  bool hitTest(Offset offset) {
    Path path = Path();
    // Add rectangle
    double x, y, w, h;
    x = rect["x"] * screenSize.width;
    y = rect["y"] * screenSize.height;
    w = rect["w"] * screenSize.width;
    h = rect["h"] * screenSize.height;
    Rect drawRect = Offset(x, y) & Size(w, h);
    path.addRect(drawRect);
    path.close();
    return path.contains(offset);
  }

}