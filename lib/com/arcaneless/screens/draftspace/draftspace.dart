import 'package:draft_paper/com/arcaneless/screens/draftspace/canvas.dart';
import 'package:flutter/material.dart';


GlobalKey<CanvasWidgetState> canvasKey = GlobalKey<CanvasWidgetState>();
final appbarSize = 50.0;
class DraftSpaceWidget extends StatefulWidget {

  @override
  State createState() => _DraftSpaceWidgetState();
}

class _DraftSpaceWidgetState extends State<DraftSpaceWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appbarSize),
        child: AppBar(
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
      ),
      body: CanvasWidget(key: canvasKey,)
    );
  }
}