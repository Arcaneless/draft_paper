import 'dart:ui';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'package:draft_paper/gesture_recognizer.dart';
import 'package:draft_paper/offset_helper.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class CanvasPoints {
  CanvasPoints({this.paint, this.points});

  Paint paint;
  Offset points;
}

class TransformablePainter extends CustomPainter {

  TransformablePainter(this.points, this.transformation);
  List<CanvasPoints> points;
  Matrix4 transformation;
  List<Offset> offsets = List();

  final Paint rectPaint = Paint()
                          ..strokeWidth = 1.0
                          ..color = Colors.black
                          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.transform(transformation.storage);
    canvas.drawRect(Offset(-size.width / 2, -size.height / 2) & size, rectPaint);

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
  double _realRotate = 0.0;
  double _rotate = 0;
  Offset _realTranslation = Offset.zero;
  Offset _initPoint;
  Offset _translation = Offset.zero;

  // the matrices
  Matrix4 realMatrix = Matrix4.identity();
  Matrix4 matrix = Matrix4.identity();

  void _addPoints(Offset offset) {
    setState(() {
      offset = OffsetHelper(offset)
                .rotate(-_realRotate)
                .scale(1/_realScale, 1/_realScale)
                .translate(-matrix.getTranslation().x, -matrix.getTranslation().y)
                .offset;

      points.add(CanvasPoints(
          points: offset,
          paint: Paint()
            ..isAntiAlias = true
            ..color = Colors.black
            ..strokeWidth = 0.2
      ));
    });
  }

  void _endPoints(CanvasPoints offset) {
    setState(() {
      points.add(offset);
    });
  }

  void _scaleStart(Offset focalPoint) {
    _initPoint = focalPoint;
  }

  void _scaleUpdate(Offset newFocalPoint, double scale) {
    _scale = scale;
    _translation = newFocalPoint - _initPoint;
    _translation = OffsetHelper(_translation).rotate(-_realRotate).scale(-1/_realScale, -1/_realScale).offset;
    //_realTranslation = newFocalPoint;
    developer.log(_translation.toString());
    matrixUpdate();
  }

  void _scaleEnd(DragEndDetails details) {
    _realScale *= _scale;
    _realTranslation += _translation;

    if (_realScale < 0.5) {
      _realScale = _scale = 1.0;
      _realRotate = _rotate = 0.0;
      _realTranslation = _translation = Offset.zero;
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
    matrixEnd();
  }

  void matrixUpdate() {
    setState(() {
      matrix = realMatrix.clone()
        ..translate(_translation.dx, _translation.dy)
        ..scale(_scale)
        ..rotateZ(_rotate);
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
                onPanEnd: _endPoints,
                onScalingStart: _scaleStart,
                onScalingUpdate: _scaleUpdate,
                onScalingEnd: _scaleEnd,
                onRotatingUpdate: _rotateUpdate,
                onRotatingEnd: _rotateEnd,
                size: MediaQuery.of(context).size
              ),
              (CustomGestureRecognizer instance) => {}
          )
        },
        child: CustomPaint(
          size: MediaQuery.of(context).size,
          painter: TransformablePainter(points, matrix),
        ),
      ),
    );
  }
}

//Container(
//child: Transform(
//origin: Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2),
//transform: matrix,
//child: CustomPaint(
//size: MediaQuery.of(context).size,
//painter: CanvasPainter(points, matrix),
//),
//),
//),