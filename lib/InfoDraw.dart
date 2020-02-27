import 'package:flutter/material.dart';

class InfoDraw extends CustomPainter {

  Size screenSize;
  Map rect;
  String detectedClass;
  double prob;
  bool showData;

  double boxWidth;
  double boxHeight;

  InfoDraw(this.rect, this.screenSize, this.detectedClass, this.prob, this.showData) {
    boxWidth = 180;
    boxHeight = 120;
  }

  @override
  void paint(Canvas canvas, Size size) {

    if(rect != null) {

      Paint paint = Paint();
      paint.color = Colors.white;
      paint.style = PaintingStyle.fill;

      // Draw Rectangle holding Info
      Offset o = _determineAlignment();
      Rect drawRect = o & Size(boxWidth, boxHeight);

      // Draw Text
      TextPainter textPaint = TextPainter();
      textPaint.text = TextSpan(
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          height: 2,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.grey,
              offset: Offset(5.0, 5.0),
            ),
          ],
        ),
        text: 'Type: ',
        children: <TextSpan>[
          TextSpan(
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
            text: '${detectedClass ?? "N/A"}\n',
          ),
          TextSpan(
            text: 'Confidence: ',
          ),
          TextSpan(
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
            text: '${((prob ?? 1)*10000).floor()/100}',
          ),
        ],
      );
      textPaint.textAlign = TextAlign.left;
      textPaint.textDirection = TextDirection.ltr;
      textPaint.layout();

      if(showData) {
        canvas.drawRect(drawRect, paint);
        textPaint.paint(canvas, o);
      }

    }

  }

  @override
  bool shouldRepaint(InfoDraw old) => (old.rect != rect) || (old.showData != showData);

  @override
  bool hitTest(Offset offset) => false;

  Offset _determineAlignment() {

    double x, y, w, h;
    x = rect["x"] * screenSize.width;
    y = rect["y"] * screenSize.height;
    w = rect["w"] * screenSize.width;
    h = rect["h"] * screenSize.height;

    List<double> xy = [ // Center
        (x + w/2.0) - boxWidth/2.0,
        (y + h/2.0) - boxHeight/2.0
    ];

    if(xy[1] - h/2.0 - boxHeight/2.0 > 0.0) { //Top
      xy[1] -= h/2.0 + boxHeight/2.0;
    } else if(xy[0] + w/2.0 + boxWidth < screenSize.width) { // Right
      xy[0] += w/2.0 + boxWidth/2.0;
    } else if(xy[1] + h/2.0 + boxHeight < screenSize.height){
      xy[1] += h/2.0 + boxHeight/2.0;
    } else if(xy[0] - w/2.0 - boxWidth/2.0 > 0.0) {
      xy[0] -= w/2.0 + boxWidth/2.0;
    }

    return Offset(xy[0], xy[1]);
  }

}