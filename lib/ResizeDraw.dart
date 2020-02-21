import 'package:flutter/material.dart';

class ResizeDraw extends CustomPainter {

  Size screenSize;
  Map rect;
  bool shouldPaint;
  ResizeDraw(this.rect, this.screenSize, this.shouldPaint);

  @override
  void paint(Canvas canvas, Size size) {

    if(rect != null && shouldPaint) {

      //Setup Paint
      Paint _resizePaint = Paint();
      _resizePaint.color = Colors.white;
      _resizePaint.style = PaintingStyle.fill;
      _resizePaint.strokeWidth = 2.0;

      // Draw Resize Circle Points
      double x, y, w, h;
      x = rect["x"] * size.width;
      y = rect["y"] * size.height;
      w = rect["w"] * size.width;
      h = rect["h"] * size.height;

      canvas.drawCircle(Offset(x + w/2.0, y), 20, _resizePaint); // Top
      canvas.drawCircle(Offset(x + w, y + h/2), 20, _resizePaint); // Right
      canvas.drawCircle(Offset(x + w/2.0, y + h), 20, _resizePaint); // Bottom
      canvas.drawCircle(Offset(x, y + h/2.0), 20, _resizePaint); // Left

    }

  }

  @override
  bool shouldRepaint(ResizeDraw old) => old.rect != rect;

  @override
  bool hitTest(Offset offset) {
    Path path = Path();
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