import 'dart:math';

import 'package:flutter/material.dart';

class OffsetHelper {

  final Offset _offset;
  OffsetHelper(this._offset);

  List<double> get _vector3 => List.of([_offset.dx, _offset.dy, 0]);

  Offset get offset => _offset;

  double get dx => _offset.dx;
  double get dy => _offset.dy;


  OffsetHelper applyMatrix(Matrix4 matrix) {
    List<double> v3 = matrix.applyToVector3Array(_vector3);
    return OffsetHelper(Offset(v3[0], v3[1]));
  }

  OffsetHelper rotate(double eulerAngle) {
    var newX = dx * cos(eulerAngle) - dy * sin(eulerAngle);
    var newY = dx * sin(eulerAngle) + dy * cos(eulerAngle);
    return OffsetHelper(Offset(newX, newY));
  }

  OffsetHelper translate(double translateX, double translateY) => OffsetHelper(Offset(dx + translateX, dy + translateY));

  OffsetHelper scale(double scaleX, double scaleY) => OffsetHelper(Offset(dx * scaleX, dy * scaleY));


}