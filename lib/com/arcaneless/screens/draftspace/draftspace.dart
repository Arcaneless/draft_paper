import 'package:draft_paper/com/arcaneless/screens/draftspace/canvas.dart';
import 'package:draft_paper/com/arcaneless/screens/menu/mainscreen.dart';
import 'package:flutter/material.dart';

import '../../parameter.dart';


GlobalKey<CanvasWidgetState> _canvasKey = GlobalKey<CanvasWidgetState>();
class DraftSpaceWidget extends StatefulWidget {
  final Text title;
  const DraftSpaceWidget({this.title});

  @override
  State createState() => _DraftSpaceWidgetState(title: title);
}

class _DraftSpaceWidgetState extends State<DraftSpaceWidget> {
  final Text title;
  _DraftSpaceWidgetState({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appbarSize),
        child: AppBar(
          title: title,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                  Icons.undo,
                  color: Colors.white
              ),
              onPressed: () {
                _canvasKey.currentState.undo();
              },
            ),
            IconButton(
              icon: Icon(
                  Icons.redo,
                  color: Colors.white
              ),
              onPressed: () {
                _canvasKey.currentState.redo();
              },
            ),
          ],
        ),
      ),
      body: CanvasWidget(key: _canvasKey,),
    );
  }
}