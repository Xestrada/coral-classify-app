import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_extend/share_extend.dart';
import 'dart:io';
import 'dart:convert';
import './DetectDraw.dart';
import './DetectedData.dart';

class ClassifyPage extends StatelessWidget {

  final String path;
  /// Will follow order: [Map, String, double]. Data can be null
  final DetectedData data;

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
              onPressed: () => _deleteImage(context),
            ),
          ],
        );
      },
    );
  }

  void _saveImage(BuildContext context) async {
    final String jsonPath = "${path.substring(0, path.length - 4)}.json";
    Map<String, dynamic> _storableData = (data == null)
        ? DetectedData(rect: null, detectedClass: null, prob: null).toJson() :
        data.toJson();
    File jsonFile = File(jsonPath);
    jsonFile.writeAsString(jsonEncode(_storableData));
    Navigator.pop(context);
  }

  /// Share the Image
  void _shareImage() {
    ShareExtend.share(this.path, "Coral Image");
  }

  void _deleteImage(BuildContext context) async {
    File f = File(this.path);
    final String jsonPath = "${path.substring(0, path.length - 4)}.json";
    File jsonFile = File(jsonPath);

    try {
      await f.delete(recursive: false);
      await jsonFile.delete(recursive: false);
    } catch(e) {
      print(e);
    }

    Navigator.pop(context);
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
                        DetectDraw(
                          data.rect,
                          data.detectedClass,
                          data.prob,
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
          FractionallySizedBox(
            widthFactor: 0.85,
            heightFactor: 0.1,
            alignment: Alignment.topCenter,
            child: Stack(
              children: <Widget> [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(MdiIcons.imageEditOutline),
                    onPressed: () => {},
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () => _shareImage(),
                  ),
                ),
              ],
            ),
          ),
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
                    child: Icon(Icons.check),
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