import 'package:flutter/material.dart';
import 'dart:io';

class ClassifyPage extends StatelessWidget {

  final String path;

  const ClassifyPage({Key key, this.path}) : super(key: key);
  
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Delete Image"),
          content: Text("Are you sure you want to delete this image and it's detected contents?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Yes"),
              color: Colors.red,
              onPressed: () => {},
            ),
          ],
        );
      },

    );
  }

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
                  child: Image.file(File(path)),
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
                  onPressed: () => _showDeleteDialog(context),
                ),
              ),
            ],
          ),
        )
    );
  }

}