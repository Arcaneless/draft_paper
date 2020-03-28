import 'package:draft_paper/com/arcaneless/screens/draftspace/draftspace.dart';
import 'package:flutter/material.dart';

class DraftList extends StatefulWidget {


  @override
  State createState() => _DraftListState();
}

class _DraftListState extends State<DraftList> {

  void _createNewDraftSpace(context, title) {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new DraftSpaceWidget(title: title))
    );
  }

  // testing
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, position) {
        return GestureDetector(
          onTap: () => _createNewDraftSpace(context, Text(position.toString())),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(position.toString(), style: TextStyle(fontSize: 22.0),),
            ),
          ),
        );
      },
    );
  }
}