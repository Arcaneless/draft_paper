import 'package:draft_paper/com/arcaneless/screens/draftspace/draftspace.dart';
import 'package:draft_paper/com/arcaneless/screens/menu/draft_list.dart';
import 'package:flutter/material.dart';

import '../../parameter.dart';

class MainScreenWidget extends StatefulWidget {

  @override
  State createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appbarSize),
        child: AppBar(
          title: Text("Draft"),
          actions: <Widget>[

          ],
        ),
      ),
      body: DraftList(),
    );
  }
}