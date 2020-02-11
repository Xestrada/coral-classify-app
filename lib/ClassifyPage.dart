import 'package:flutter/material.dart';
import 'dart:io';
import './ObjectRect.dart';

class ClassifyPage extends StatelessWidget {

  final String path;
  /// Will follow order: [Map, String, double]. Data can be null
  final List data;

  const ClassifyPage({Key key, @required this.path, this.data}) : super(key: key);
  
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

  void _saveImage(BuildContext context) {
    // Should save JSON data to path
    Navigator.pop(context);
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
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget> [
                    Image.file(File(path)),
                    CustomPaint(
                        painter: data != null ?
                        ObjectRect(
                          data[0],
                          data[1],
                          data[2],
                        ) : null
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: <Widget>[
//          FractionallySizedBox(
//            widthFactor: 0.85,
//            heightFactor: 0.25,
//            alignment: Alignment.topCenter,
//            child: Stack(
//              children: <Widget> [
//                Align(
//                  alignment: Alignment.centerLeft,
//                  child: FloatingActionButton(
//                    heroTag: null,
//                    child: Icon(Icons.arrow_back),
//                    onPressed: () => Navigator.pop(context),
//                  ),
//                ),
//                Align(
//                  alignment: Alignment.center,
//                  child: FloatingActionButton(
//                    heroTag: null,
//                    child: Icon(Icons.remove_red_eye),
//                    onPressed: () => {},
//                  ),
//                ),
//                Align(
//                  alignment: Alignment.centerRight,
//                  child: FloatingActionButton(
//                    backgroundColor: Colors.red,
//                    heroTag: null,
//                    child: Icon(Icons.delete_forever),
//                    onPressed: () => _showDeleteDialog(context),
//                  ),
//                ),
//              ],
//            ),
//          ),
          FractionallySizedBox(
            widthFactor: 0.85,
            heightFactor: 0.1,
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: <Widget> [
                Align(
                  alignment: Alignment.centerLeft,
                  child: FloatingActionButton(
                    backgroundColor: Colors.red,
                    heroTag: null,
                    child: Icon(Icons.delete_forever),
                    onPressed: () => _showDeleteDialog(context),
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
                    heroTag: null,
                    child: Icon(Icons.save_alt),
                    onPressed: () => _saveImage(context),
                  ),
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }
}