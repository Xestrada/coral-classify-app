import 'package:flutter/material.dart';
import 'dart:io';

class Gallery extends StatelessWidget {

  const Gallery({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            Center(
              child: Text("Gallery of All Images Taken"),
            ),
          ],
        ),
      ),
    );
  }
}