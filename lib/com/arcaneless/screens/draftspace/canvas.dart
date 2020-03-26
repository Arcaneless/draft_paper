import 'dart:ui';
import 'package:draft_paper/com/arcaneless/util/gesture_recognizer.dart';
import 'package:draft_paper/com/arcaneless/util/offset_helper.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class CanvasPath {
  CanvasPath({this.paint, this.path});

  Paint paint;
  Path path;

  void addPoint(Offset o) {
    path.lineTo(o.dx, o.dy);
  }
}

enum CanvasPaint {
  HIGHTLIGHT,
  PEN,
  ERASER,
}

// default layer 50
class TransformablePainter extends CustomPainter {

  TransformablePainter(this.path, this.transformation);
  List<CanvasPath> _undoList = List();
  CanvasPath path;
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

    canvas.drawPath(path.path, path.paint);
  }



  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;


}

class CanvasWidget extends StatefulWidget {
  CanvasWidget({Key key}) : super(key: key);

  @override
  State createState() => CanvasWidgetState();

}

class CanvasWidgetState extends State<CanvasWidget> {

  List<CanvasPath> points = List();
  List<CanvasPath> _tempUndo = List();
  List<List<CanvasPath>> _undoList = List();
  List<List<CanvasPath>> _redoList = List();

  // value to form the matrix
  double _realScale = 1.0;
  double _scale = 1.0;
  double _realRotate = 0.0;
  double _rotate = 0;
  Offset _initPoint = Offset.zero;
  Offset _translation = Offset.zero;

  // the matrices
  Matrix4 realMatrix = Matrix4.identity();
  Matrix4 matrix = Matrix4.identity();

  void _addPoints(Offset offset) {
    setState(() {
      offset = OffsetHelper(offset)
          .translate(-matrix
          .getTranslation()
          .x, -matrix
          .getTranslation()
          .y)
          .scale(1 / _realScale, 1 / _realScale)
          .rotate(-_realRotate)
          .offset;

      CanvasPath point = CanvasPath(
          point: offset,
          paint: Paint()
            ..isAntiAlias = true
            ..color = Colors.black
            ..strokeWidth = 0.5 * 1 / _realScale
      );

      points.add(point);
      _tempUndo.add(point);
    });
  }

  void _endPoints(CanvasPath offset) {
    setState(() {
      points.add(null);
      _tempUndo.add(null);
      _undoList.add(_tempUndo);
      _tempUndo.clear();
    });
  }

  void _scaleStart(Offset focalPoint) {
    _initPoint = focalPoint;
  }

  // TODO: scale center fix
  void _scaleUpdate(Offset newFocalPoint, double scale) {
    _scale = scale;
    _translation = newFocalPoint - _initPoint;
    _translation = OffsetHelper(_translation).rotate(-_realRotate).scale(1/_realScale, 1/_realScale).offset;
    //_realTranslation = newFocalPoint;
    developer.log(_translation.toString());
    matrixUpdate();
  }

  void _scaleEnd(DragEndDetails details) {
    _realScale *= _scale;

    if (_realScale < 0.5) {
      _realScale = _scale = 1.0;
      _realRotate = _rotate = 0.0;
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

  // undoing the paint
  void undo() {
    _tempUndo.clear();
    _tempUndo = _undoList.removeLast();
  }

  // redoing the paint as long as there is no drawing
  void redo() {

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