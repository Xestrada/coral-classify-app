import 'package:flutter/material.dart';
import 'dart:io';

class ClassifyPage extends StatelessWidget {

  final FileSystemEntity image;

  const ClassifyPage({Key key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Container(
          color: Colors.black,
          child: Column(
            children: <Widget>[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 10,
                  child: Image.file(File(image.path)),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FractionallySizedBox(
          widthFactor: 0.85,
          heightFactor: 0.1,
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: <Widget> [
              Align(
                alignment: Alignment.centerLeft,
                child: FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.remove_red_eye),
                  onPressed: () => {},
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  heroTag: null,
                  child: Icon(Icons.delete_forever),
                  onPressed: () => {},
                ),
              ),
            ],
          ),
        )
    );
  }

}