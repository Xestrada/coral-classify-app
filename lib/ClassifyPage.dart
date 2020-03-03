import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_extend/share_extend.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:convert';
import './DetectDraw.dart';
import './DetectedData.dart';
import './ResizeDraw.dart';
import './InfoDraw.dart';

class ClassifyPage extends StatefulWidget {

  final String path;

  /// Will follow order: [Map, String, double]. Data can be null
  final DetectedData data;

  const ClassifyPage({Key key, @required this.path, this.data}) : super(key: key);

  @override
  _ClassifyPageState createState() => _ClassifyPageState();

}

class _ClassifyPageState extends State<ClassifyPage> {

  GlobalKey _rectKey;
  List<GlobalKey> _resizeKeys;
  DetectedData _data;
  Map _editingRect;
  Paint _unselectedPaint, _selectedPaint, _editingPaint;
  File _imageFile, _jsonFile;
  double _buttonSize;
  bool _showData;
  bool _editMode;
  bool _shouldDrag;

  @override
  void initState() {
    super.initState();
    // Init Variables
    _buttonSize = 55;
    _editMode = false;
    _showData = false;
    _shouldDrag = true;
    _imageFile = File(this.widget.path);
    _jsonFile = File(
        "${this.widget.path.substring(0, this.widget.path.length - 4)}.json"
    );
    // Setup Global Keys
    _rectKey = GlobalKey();
    _resizeKeys = [GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey()];
    // Setup all Paints
    _selectedPaint = Paint();
    _unselectedPaint = Paint();
    _editingPaint = Paint();
    _selectedPaint.color = Colors.blue;
    _unselectedPaint.color = Colors.yellow;
    _editingPaint.color = Colors.red;
    _editingPaint.style = _unselectedPaint.style = _selectedPaint.style
    = PaintingStyle.stroke;
    _editingPaint.strokeWidth = 3.0;
    _selectedPaint.strokeWidth = 2.5;
    _unselectedPaint.strokeWidth = 1.0;
    //Create modifiable data
    _editingRect = widget.data?.rect == null
        ? {"x":0.0, "y":0.0, "w":0.0, "h": 0.0} : Map.from(widget.data.rect);
    _data = widget.data?.rect == null ?
    DetectedData(
      rect: {"x":0.0, "y":0.0, "w":0.0, "h": 0.0},
      prob: 0,
      detectedClass: null,
    ) :  widget.data;
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
    Map<String, dynamic> _storableData = (_data == null)
        ? DetectedData(rect: null, detectedClass: null, prob: null).toJson() :
    _data.toJson();
    _jsonFile.writeAsString(jsonEncode(_storableData));
    Navigator.pop(context);
  }

  /// Share the Image
  void _shareImage() {
    ShareExtend.share(this.widget.path, "Coral Image");
  }

  /// Delete the Image and any detected Data
  void _deleteImage(BuildContext context) async {

    try {
      await _imageFile.delete(recursive: false);
      await _jsonFile.delete(recursive: false);
    } catch(e) {
      print(e);
    }

    Navigator.pop(context); // Pop Dialog
    Navigator.pop(context); // Return to Original Page

  }

  /// Toggle [_shouldDrag]
  void _toggleShouldDrag() {
    setState(() {
      _shouldDrag = !_shouldDrag;
    });
  }

  /// Toggle [_showData]
  void _showImageData() {
    setState(() {
      _showData = !_showData;
    });
  }

  /// Toggle [_editMode] and create default rect if none created
  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
      _showData = false;
      if(_editingRect["w"] == 0 && _editingRect["h"] == 0) {
        _editingRect["w"] = 0.5;
        _editingRect["h"] = 0.5;
      }
    });
  }

  /// Manage dragging of detection box
  void _moveRectDrag(DragUpdateDetails details, BuildContext context) {
    double tempX = _editingRect["x"] + (details.delta.dx/_screenSize(context).width);
    double tempY = _editingRect["y"] + (details.delta.dy/_screenSize(context).height);
    setState(() {
      _editingRect["x"] = tempX;
      _editingRect["y"] = tempY;
    });
  }

  /// Resize Detected Object
  void _resizeRect(DragUpdateDetails details, bool xDir, bool positive) {

    if(xDir){

      double posX = _editingRect["x"];
      double width = _editingRect["w"];
      width = positive ? width + (details.delta.dx/_screenSize(context).width) :
      width - (details.delta.dx/_screenSize(context).width);
      posX = !positive ?
      posX + details.delta.dx/_screenSize(context).width : posX;
      setState(() {
        _editingRect["x"] = posX;
        _editingRect["w"] = width;
      });

    } else {

      double height = _editingRect["h"];
      double posY = _editingRect["y"];
      posY = !positive ?
      posY + details.delta.dy/_screenSize(context).height : posY;
      height = positive ? height + (details.delta.dy/_screenSize(context).height) :
      height - (details.delta.dy/_screenSize(context).height);
      setState(() {
        _editingRect["y"] = posY;
        _editingRect["h"] = height;
      });

    }

  }

  /// Either save edited rect size and location to [_data.rect] or
  /// set [_editingRect] to copy of [_data.rect]
  void _saveEditedRect(bool shouldSave) {
    setState(() {
      if(shouldSave) {
        _data.rect = Map.from(_editingRect);
      } else {
        _editingRect = Map.from(_data.rect);
      }
    });

    _toggleEditMode();
  }

  /// Determine what drawn CustomPaint widget is being dragged
  void _determineWhichDragged(DragUpdateDetails details) {
    final RenderBox box = _rectKey.currentContext.findRenderObject();
    final List<RenderBox> resizeAreas = [ // TLBR
      _resizeKeys[0].currentContext.findRenderObject(),
      _resizeKeys[1].currentContext.findRenderObject(),
      _resizeKeys[2].currentContext.findRenderObject(),
      _resizeKeys[3].currentContext.findRenderObject()
    ];
    Offset _rectOffset = box.globalToLocal(details.globalPosition);
    List<Offset> _resizeOffsets = [ // TLBR
      resizeAreas[0].globalToLocal(details.globalPosition),
      resizeAreas[1].globalToLocal(details.globalPosition),
      resizeAreas[2].globalToLocal(details.globalPosition),
      resizeAreas[3].globalToLocal(details.globalPosition),
    ];

    if(_editMode) {
      // Rectangle is being dragged
      if(_shouldDrag){
        if (box.hitTest(BoxHitTestResult(), position: _rectOffset)) {
          _moveRectDrag(details, context);
        }
      } else { // Resize Dragging
        if(resizeAreas[0].hitTest(BoxHitTestResult(), position: _resizeOffsets[0])) {
          //Top Drag
          _resizeRect(details, false, false);
        } else if(resizeAreas[1].hitTest(BoxHitTestResult(), position: _resizeOffsets[1])) {
          //Right Drag
          _resizeRect(details, true, true);
        } else if(resizeAreas[2].hitTest(BoxHitTestResult(), position: _resizeOffsets[2])) {
          //Bottom Drag
          _resizeRect(details, false, true);
        } else if(resizeAreas[3].hitTest(BoxHitTestResult(), position: _resizeOffsets[3])) {
          //Left Drag
          _resizeRect(details, true, false);
        }
      }

    }
  }

  Image _cropDetected() {
    //return img.copyCrop(img.pn, x, y, w, h);
  }

  /// Get the Screen Size of the Device using [context]
  Size _screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
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

  /// Create buttons for edit mode
  Widget _editModeButtons() {
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
                  alignment: Alignment.center,
                  child: IconButton(
                    iconSize: _buttonSize,
                    icon: Icon(_shouldDrag ? MdiIcons.resize : MdiIcons.dragVariant),
                    onPressed: () => _toggleShouldDrag(),
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
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                    height: _buttonSize,
                    child: Icon(Icons.check),
                    shape: new CircleBorder(),
                    color: Colors.blue,
                    onPressed: () => _saveEditedRect(true),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: MaterialButton(
                    height: _buttonSize,
                    color: Colors.red,
                    child: Icon(Icons.close),
                    shape: new CircleBorder(),
                    onPressed: () => _saveEditedRect(false),
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
                  child: MaterialButton(
                    height: _buttonSize,
                    color: Colors.red,
                    child: Icon(Icons.delete_forever),
                    shape: new CircleBorder(),
                    onPressed: () => _showDeleteDialog(context),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: MaterialButton(
                    height: _buttonSize,
                    color: _showData ? Colors.blue : Colors.grey,
                    child: Icon(_showData ? MdiIcons.eye : MdiIcons.eyeOff),
                    shape: new CircleBorder(),
                    onPressed: () => {},
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                    height: _buttonSize,
                    color: Colors.blue,
                    child: Icon(Icons.check),
                    shape: new CircleBorder(),
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
                      child: Image.file(_imageFile),
                    ),
                    Container(
                      height: _screenSize(context).height,
                      width: _screenSize(context).width,
                      child: GestureDetector(
                        onTapUp: (details) {
                          final RenderBox box = _rectKey.currentContext.findRenderObject();
                          Offset _rectOffset = box.globalToLocal(details.globalPosition);
                          if(box.hitTest(BoxHitTestResult(), position: _rectOffset) && !_editMode) {
                            _showImageData();
                          }
                        },
                        onPanUpdate: (details) => _determineWhichDragged(details),
                        child: Stack( // Custom Paint Drawings
                          fit: StackFit.expand,
                          children: <Widget> [
                            CustomPaint(
                              key: _rectKey,
                              painter: DetectDraw(
                                Map.from(_editingRect),
                                _screenSize(context),
                                _determinePaint()
                              ),
                            ),
                            CustomPaint( // Top
                              key: _resizeKeys[0],
                              painter: ResizeDraw(
                                  _editingRect["x"] + _editingRect["w"]/2.0,
                                  _editingRect["y"],
                                  _screenSize(context),
                                  _editMode && !_shouldDrag
                              ),
                            ),
                            CustomPaint( // Right
                              key: _resizeKeys[1],
                              painter: ResizeDraw(
                                  _editingRect["x"] + _editingRect["w"],
                                  _editingRect["y"] + _editingRect["h"]/2.0,
                                  _screenSize(context),
                                  _editMode && !_shouldDrag
                              ),
                            ),
                            CustomPaint( // Bottom
                              key: _resizeKeys[2],
                              painter: ResizeDraw(
                                  _editingRect["x"] + _editingRect["w"]/2.0,
                                  _editingRect["y"] + _editingRect["h"],
                                  _screenSize(context),
                                  _editMode && !_shouldDrag
                              ),
                            ),
                            CustomPaint( // Left
                              key: _resizeKeys[3],
                              painter: ResizeDraw(
                                  _editingRect["x"],
                                  _editingRect["y"] + _editingRect["h"]/2.0,
                                  _screenSize(context),
                                  _editMode && !_shouldDrag
                              ),
                            ),
                            CustomPaint( // Detected Object Info
                              painter: InfoDraw(
                                Map.from(_editingRect),
                                _screenSize(context),
                                _data?.detectedClass,
                                _data?.prob,
                                _showData
                              ),
                            ),
                          ],
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