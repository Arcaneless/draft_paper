import 'dart:ui';

import 'package:draft_paper/gesture_recognizer.dart';
import 'package:draft_paper/offset_helper.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class CanvasPoints {
  CanvasPoints({this.paint, this.points});

  Paint paint;
  Offset points;
}

class CanvasPainter extends CustomPainter {

  CanvasPainter(this.points);
  List<CanvasPoints> points;
  List<Offset> offsets = List();

  final Paint rectPaint = Paint()
                          ..strokeWidth = 1.0
                          ..color = Colors.black
                          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, rectPaint);

    for (int i=0; i<points.length-1; i++) {
      if (points[i] != null && points[i+1] != null) {
        canvas.drawLine(points[i].points, points[i+1].points, points[i].paint);
      } else if (points[i] != null && points[i+1] == null) {
        offsets.clear();
        offsets.add(points[i].points);
        canvas.drawPoints(PointMode.points, offsets, points[i].paint);
      }
    }
  }



  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;


}

class CanvasWidget extends StatefulWidget {


  @override
  State createState() => _CanvasWidgetState();

}

class _CanvasWidgetState extends State<CanvasWidget> {

  List<CanvasPoints> points = List();

  // value to form the matrix
  double _realScale = 1.0;
  double _scale = 1.0;
  double _realRotate = 0;
  double _rotate = 0;
  Offset _initPoint = Offset.zero;
  Offset _translation = Offset.zero;
  Offset _realTranslation = Offset.zero;

  // the matrices
  Matrix4 realMatrix = Matrix4.identity();
  Matrix4 matrix = Matrix4.identity();

  void _addPoints(Offset offset) {
    if (offset == null) {
      points.add(null);
      return;
    }
    // translating related to center, scale, then go back to left-top corner
    offset = OffsetHelper(offset)
          .translate(-MediaQuery.of(context).size.width / 2, -MediaQuery.of(context).size.height / 2)
          .translate(-_realTranslation.dx, -_realTranslation.dy)
          .rotate(-_realRotate)
          .scale(1/_realScale, 1/_realScale)
          .translate(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2)
          .offset;
    setState(() {
      points.add(CanvasPoints(
          points: offset,
          paint: Paint()
            ..isAntiAlias = true
            ..color = Colors.black
            ..strokeWidth = 1.0
      ));
    });
  }

  void _scaleStart(Offset focalPoint) {
    _initPoint = focalPoint;
  }

  void _scaleUpdate(Offset newFocalPoint, double scale) {
    _scale = scale;
    _translation = newFocalPoint - _initPoint;
    matrixUpdate();
  }

  void _scaleEnd(DragEndDetails details) {
    _realScale *= _scale;
    if (_realScale < 1.0) {
      _realScale = _scale = 1.0;
      matrix = Matrix4.identity();
    }
    matrixEnd();
  }

  void _rotateUpdate(double angle) {
    _rotate = angle;
    matrixUpdate();
  }

  void _rotateEnd(DragEndDetails details) {
    _realRotate += _rotate;
    _realTranslation += _translation;
    matrixEnd();
  }

  void matrixUpdate() {
    setState(() {
      matrix = realMatrix.clone()
        ..scale(_scale)
        ..rotateZ(_rotate)
        ..translate(_translation.dx, _translation.dy);
    });
  }

  void matrixEnd() {
    setState(() {
      realMatrix = matrix;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          CustomGestureRecognizer : GestureRecognizerFactoryWithHandlers<CustomGestureRecognizer>(
              () => CustomGestureRecognizer(
                onPanStart: _addPoints,
                onPanUpdate: _addPoints,
                onPanEnd: _addPoints,
                onScalingStart: _scaleStart,
                onScalingUpdate: _scaleUpdate,
                onScalingEnd: _scaleEnd,
                onRotatingUpdate: _rotateUpdate,
                onRotatingEnd: _rotateEnd
              ),
              (CustomGestureRecognizer instance) => {}
          )
        },
        child: Transform(
          origin: Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2),
          transform: matrix,
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: CanvasPainter(points),
          ),
        ),
      ),
    );
  }
}