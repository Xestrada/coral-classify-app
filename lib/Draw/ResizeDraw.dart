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

      canvas.drawCircle(
          Offset(x * screenSize.width, y * screenSize.height),
          25,
          _resizePaint
      );

    }

  }

  @override
  bool shouldRepaint(ResizeDraw old) => true;

  @override
  bool hitTest(Offset offset) {
    final Offset center = Offset(x * screenSize.width, y * screenSize.height);
    Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          height: 200,
          width: 200,
        ),
        Radius.circular(center.dx)
      )
    );
    path.close();
    return path.contains(offset);
  }

}