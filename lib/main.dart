import 'package:draft_paper/com/arcaneless/screens/draftspace/canvas.dart';
import 'package:draft_paper/com/arcaneless/screens/draftspace/draftspace.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(Draft());

class Draft extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DraftSpaceWidget(),
    );
  }
}