import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_extend/share_extend.dart';
import 'dart:io';
import 'dart:convert';
import './DetectDraw.dart';
import './DetectedData.dart';

class ClassifyPage extends StatefulWidget {

  final String path;

  /// Will follow order: [Map, String, double]. Data can be null
  DetectedData data;

  ClassifyPage({Key key, @required this.path, this.data}) : super(key: key);

  @override
  _ClassifyPageState createState() => _ClassifyPageState();

}

class _ClassifyPageState extends State<ClassifyPage> {

  Paint _unselectedPaint, _selectedPaint, _editingPaint;
  bool _showData;
  bool _editMode;

  @override
  void initState() {
    super.initState();
    _editMode = false;
    _showData = false;
    _selectedPaint = Paint();
    _unselectedPaint = Paint();
    _editingPaint = Paint();
    _selectedPaint.color = Colors.blue;
    _unselectedPaint.color = Colors.yellow;
    _editingPaint.color = Colors.red;
    _editingPaint.style = _unselectedPaint.style = _selectedPaint.style
    = PaintingStyle.stroke;
    _selectedPaint.strokeWidth = 2.5;
    _editingPaint.strokeWidth = _unselectedPaint.strokeWidth = 1.0;

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

  /// Toggle [_showData]
  void _showImageData() {
    setState(() {
      _showData = !_showData;
    });
  }

  /// Toggle [_editMode]
  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
      _showData = false;
    });
  }

  /// Get the Screen Size of the Device using [context]
  Size _screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Determine the best place on the screen to display the data of
  /// the detected object
  Alignment _determineAlignment() {

    if(widget.data?.rect == null) {
      return Alignment(0, 0);
    } else if(-widget.data?.rect["x"] + (widget.data?.rect["w"] * 2.8) < 1.0) {
      return Alignment(
          -widget.data?.rect["x"] + (widget.data?.rect["w"] * 2.8),
          -widget.data?.rect["y"]
      );
    } else if(-widget.data?.rect["x"] - (widget.data?.rect["w"] * 3.1) > -1.0) {
      return Alignment(
          -widget.data?.rect["x"] - (widget.data?.rect["w"] * 3.1),
          -widget.data?.rect["y"]
      );
    } else if(-widget.data?.rect["y"] + (widget.data?.rect["h"] * 1.45) < 1.0) {
      return Alignment(
        -widget.data?.rect["x"],
        -widget.data?.rect["y"] + (widget.data?.rect["h"] * 1.45)
      );
    } else {
      return Alignment(
        -widget.data?.rect["x"],
        -widget.data?.rect["y"] - (widget.data?.rect["h"] * 1.56)
      );
    }

  }

  ///Determine what paint to use
  Paint _determinePaint() {
    if(_editMode) {
      return _editingPaint;
    } else if(_showData) {
      return _selectedPaint;
    } else {
      return _unselectedPaint;
    }
  }

  /// Create buttons for editing mode
  Widget _editModeButtons() {
    return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: 0.85,
            heightFactor: 0.1,
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: <Widget> [
                Align(
                  alignment: Alignment.centerRight,
                  child: FloatingActionButton(
                    heroTag: null,
                    child: Icon(Icons.check),
                    onPressed: () => _toggleEditMode(),
                  ),
                ),
              ],
            ),
          ),
        ]
    );
  }

  /// Create the buttons for the main Classify Page
  Widget _classifyButtons() {
    return Stack(
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
                    onPressed: () => _toggleEditMode(),
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
                    child: Icon(_showData ? MdiIcons.eye : MdiIcons.eyeOff),
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
                child: Stack(
                  children: <Widget> [
                    Align(
                      alignment: Alignment.center,
                      child: Image.file(File(widget.path)),
                    ),
                    Container(
                      height: _screenSize(context).height,
                      width: _screenSize(context).width,
                      child: GestureDetector(
                        onTap: () => _showImageData(),
                        child: CustomPaint(
                          painter: DetectDraw(
                            widget.data?.rect,
                            _screenSize(context),
                            _determinePaint()
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: _determineAlignment(),
                      child: Container(
                        width: _showData ? 170 : 0,
                        height: _showData ? 100 : 0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              height: 2,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.grey,
                                  offset: Offset(5.0, 5.0),
                                ),
                              ],
                            ),
                            text: 'Type: ',
                            children: <TextSpan>[
                              TextSpan(
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                                text: '${widget.data?.detectedClass}\n',
                              ),
                              TextSpan(
                                text: 'Confidence: ',
                              ),
                              TextSpan(
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                                text: '${((widget.data?.prob ?? 1)*10000).floor()/100}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SafeArea(
        minimum: MediaQuery.of(context).padding,
        child: _editMode ? _editModeButtons() : _classifyButtons(),
      ),
    );
  }
}