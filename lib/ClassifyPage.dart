import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_extend/share_extend.dart';
import 'package:overlay_container/overlay_container.dart';
import 'dart:io';
import 'dart:convert';
import './DetectDraw.dart';
import './DetectedData.dart';

class ClassifyPage extends StatefulWidget {

  final String path;

  /// Will follow order: [Map, String, double]. Data can be null
  final DetectedData data;

  const ClassifyPage({Key key, @required this.path, this.data}) : super(key: key);

  @override
  _ClassifyPageState createState() => _ClassifyPageState();

}

class _ClassifyPageState extends State<ClassifyPage> {

  bool _showData;

  @override
  void initState() {
    super.initState();
    _showData = false;
  }

  /// Show the Delete Dialog
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

  /// Save the Image and any Detected Data
  void _saveImage(BuildContext context) async {
    final String jsonPath = "${widget.path.substring(0, widget.path.length - 4)}.json";
    Map<String, dynamic> _storableData = (widget.data == null)
        ? DetectedData(rect: null, detectedClass: null, prob: null).toJson() :
        widget.data.toJson();
    File jsonFile = File(jsonPath);
    jsonFile.writeAsString(jsonEncode(_storableData));
    Navigator.pop(context);
  }

  /// Share the Image
  void _shareImage() {
    ShareExtend.share(this.widget.path, "Coral Image");
  }

  /// Delete the Image and any detected Data
  void _deleteImage(BuildContext context) async {
    File f = File(this.widget.path);
    final String jsonPath = "${widget.path.substring(0, widget.path.length - 4)}.json";
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

  // Tooggle Show Data
  //TODO - Only toggle when clicked inside Rect
  void _showImageData() {
    print(MediaQuery.of(context).size);
    setState(() {
      _showData = !_showData;
    });
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
                  children: <Widget> [
                    Align(
                      alignment: Alignment.center,
                      child: Image.file(File(widget.path)),
                    ),
                    CustomPaint(
                      painter: DetectDraw(
                        widget.data?.rect,
                        MediaQuery.of(context).size,
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: GestureDetector(
                        onTap: () => _showImageData(),
                        child: CustomPaint(
                          painter: DetectDraw(
                            widget.data?.rect,
                            MediaQuery.of(context).size,
                          ),
                        ),
                      ),
                    ),
                    OverlayContainer(
                      show: _showData,
                      position: OverlayContainerPosition(
                        // Left position.
                        0,
                        // Bottom position.
                        0,
                      ),
                      // The content inside the overlay.
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.grey[300],
                              blurRadius: 3,
                              spreadRadius: 6,
                            )
                          ],
                        ),
                        child: Text("I render outside the \nwidget hierarchy."),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: new BoxDecoration(
              borderRadius: new BorderRadius.circular(5.0),
                color: Colors.white,
              ),
              height: 0.1,
              width: 0.1,
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