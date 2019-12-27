import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;



class CustomGestureRecognizer extends ImmediateMultiDragGestureRecognizer {

  final List<Touch> touches = [];
  Function onPanStart; // the starting offset
  Function onPanUpdate; // current offset
  Function onPanEnd; // null
  Function onScalingStart; // the focal point
  Function onScalingUpdate;  //the focal point, the scale
  Function onScalingEnd; // drag end details
  Function onRotatingUpdate;
  Function onRotatingEnd;

  double initScalingDistance = 0;
  double initAngle = 0;

  CustomGestureRecognizer({
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onScalingStart,
    this.onScalingUpdate,
    this.onScalingEnd,
    this.onRotatingUpdate,
    this.onRotatingEnd
  }) {
    onStart = (Offset offset) {
      final touch = Touch(
        startOffset: offset,
        onUpdate: (drag, details) => _onUpdate(drag, details),
        onEnd: (drag, details) => _onEnd(drag, details),
      );
      this._onStart(touch);
      return touch;
    };
  }

  void _onStart(Touch touch) {
    touches.add(touch);
    if (touches.length == 1) {
      // if the touch is a pan start
      onPanStart(touch.startOffset);
    } else if (touches.length == 2) {
      // if the touch is a two finger start
      initScalingDistance = (touches[0].currentOffset - touches[1].currentOffset).distance;
      // pass the middle point: aka the focal point
      onScalingStart((touches[0].currentOffset + touches[1].currentOffset) / 2);

      // find the init angle
      initAngle = (touches[0].currentOffset - touches[1].currentOffset).direction;
    }
  }

  void _onUpdate(Touch touch, DragUpdateDetails details) {
    assert(touches.isNotEmpty); // make sure touches is not empty
    touch.currentOffset = details.localPosition;

    if (touches.length == 1) {
      onPanUpdate(touch.currentOffset);
    } else if (touches.length == 2) {
      // Scaling update
      var newDistance = (touches[0].currentOffset - touches[1].currentOffset).distance;
      onScalingUpdate((touches[0].currentOffset + touches[1].currentOffset) / 2, newDistance / initScalingDistance);

      // Rotating check
      var newAngle = (touches[0].currentOffset - touches[1].currentOffset).direction;
      onRotatingUpdate(newAngle - initAngle);
    }
  }

  void _onEnd(Touch touch, DragEndDetails details) {
    touches.remove(touch);

    if (touches.length == 0) {
      // end the panning gesture
      onPanEnd(null);
    } else if (touches.length == 1) {
      // end the scaling gesture
      onScalingEnd(details);
      onRotatingEnd(details);
    }

  }

  @override
  String get debugDescription {
    return 'Custom Gesture';
  }



}

class Touch extends Drag {

  Offset startOffset;
  Offset currentOffset;
  final void Function(Drag drag, DragUpdateDetails details) onUpdate;
  final void Function(Drag drag, DragEndDetails details) onEnd;

  Touch({
    this.startOffset,
    this.onUpdate,
    this.onEnd
  }) {
    currentOffset = startOffset;
  }

  @override
  void end(DragEndDetails details) {
    super.end(details);
    onEnd(this, details);
  }

  @override
  void update(DragUpdateDetails details) {
    super.update(details);
    onUpdate(this, details);
  }
}
