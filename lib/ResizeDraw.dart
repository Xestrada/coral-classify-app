import 'package:flutter/material.dart';

class ResizeDraw extends CustomPainter {

  Size screenSize;
  double x, y;
  bool shouldPaint;
  ResizeDraw(this.x, this.y, this.screenSize, this.shouldPaint);

  @override
  void paint(Canvas canvas, Size size) {

    if(shouldPaint) {

      //Setup Paint
      Paint _resizePaint = Paint();
      _resizePaint.color = Colors.white;
      _resizePaint.style = PaintingStyle.fill;
      _resizePaint.strokeWidth = 2.0;

      canvas.drawCircle(Offset(x, y), 20, _resizePaint);

    }

  }

  @override
  bool shouldRepaint(ResizeDraw old) => old.x != x || old.y != y;

  @override
  bool hitTest(Offset offset) {
    print("touched");
    return true;
  }

}