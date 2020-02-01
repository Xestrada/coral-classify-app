import 'package:flutter/material.dart';

class ObjectRect extends CustomPainter {
  Map rect;
  String objectName;
  double prob;
  ObjectRect(this.rect, this.objectName, this.prob);

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

      // Draw Text describing Object
      TextSpan span = new TextSpan(
        style: new TextStyle(color: Colors.white),
        text: (objectName + "\n" + (prob*100).toString() + "%"),
      );
      TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, new Offset(x, y));

    }

  }

  @override
  bool shouldRepaint(ObjectRect old) => old.rect != rect;

}