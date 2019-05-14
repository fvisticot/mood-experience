import 'package:flutter/material.dart';
import 'dart:math';

class MoodIndicator extends StatefulWidget {
  Color color;
  Color splashColor;
  double value;
  VoidCallback onPressed;

  MoodIndicator({this.value, this.color, this.splashColor, this.onPressed});

  @override
  createState() => MoodIndicatorState();
}

class MoodIndicatorState extends State<MoodIndicator> {
  MoodIndicatorState() {}

  @override
  Widget build(BuildContext context) {
    return Center(
        child: new Container(
      height: 100.0,
      width: 100.0,
      child: new CustomPaint(
        foregroundPainter: new MyPainter(
            lineColor: Colors.amber,
            completeColor: Colors.blueAccent,
            completePercent: 70.0,
            width: 8.0),
        child: new Padding(
          padding: const EdgeInsets.all(5.0),
          child: new RaisedButton(
            color: Colors.purple,
            splashColor: Colors.blueAccent,
            shape: new CircleBorder(),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(1.0),
                child: Text(
                  widget.value.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 30.0),
                ),
              ),
            ),
            onPressed: widget.onPressed,
          ),
        ),
      ),
    ));
  }

  @override
  void didUpdateWidget(MoodIndicator oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }
}

class MyPainter extends CustomPainter {
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;

  MyPainter(
      {this.lineColor, this.completeColor, this.completePercent, this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = new Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center = new Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, line);
    double arcAngle = 2 * pi * (completePercent / 100);
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, complete);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
