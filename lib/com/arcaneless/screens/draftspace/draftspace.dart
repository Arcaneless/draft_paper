import 'package:draft_paper/com/arcaneless/screens/draftspace/canvas.dart';
import 'package:flutter/material.dart';


GlobalKey<CanvasWidgetState> canvasKey = GlobalKey<CanvasWidgetState>();
class DraftSpaceWidget extends StatefulWidget {

  @override
  State createState() => _DraftSpaceWidgetState();
}

class _DraftSpaceWidgetState extends State<DraftSpaceWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.undo,
              color: Colors.white
            ),
            onPressed: () {
              canvasKey.currentState.undo();
            },
          ),
          IconButton(
            icon: Icon(
                Icons.redo,
                color: Colors.white
            ),
            onPressed: () {
              canvasKey.currentState.redo();
            },
          ),
        ],
      ),
      body: CanvasWidget(),
    );
  }
}