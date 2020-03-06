import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_extend/share_extend.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import './DetectDraw.dart';
import './DetectedData.dart';
import './ResizeDraw.dart';
import './InfoDraw.dart';
import './globals.dart';

class ClassifyPage extends StatefulWidget {

  final String path;

  /// Will follow order: [Map, String, double]. Data can be null
  final DetectedData data;

  const ClassifyPage({Key key, @required this.path, this.data}) : super(key: key);

  @override
  _ClassifyPageState createState() => _ClassifyPageState();

}

class _ClassifyPageState extends State<ClassifyPage> with SingleTickerProviderStateMixin {

  final _imageSize = 224; // Size that cropped image will be resized to
  AnimationController _loadingAnimation;
  Future<List> _detectFuture;
  GlobalKey _rectKey; // GlobalKey for detected object outline
  List<GlobalKey> _resizeKeys; // GlobalKey list for resize buttons
  DetectedData _data; // Detected data parsed from json
  Map _editingRect; // Map representing the editable outline of the detected object
  Paint _unselectedPaint, _selectedPaint, _editingPaint; // Paints
  File _imageFile, _jsonFile; // Files for json and png
  double _buttonSize; // Size of buttons
  bool _showData; // If detected object info should be shown
  bool _editMode; // Flag for edit mode
  bool _shouldDrag; // Flag for dragging option

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

    // Setup Animation Value
    final _loadingAnimation = AnimationController(vsync: this, duration: Duration(milliseconds: 1200));

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

  /// Run TFLite model on cropped image
  void _deepDetect() async {
    if(mainModelLoaded) {
      await _loadModel();
      mainModelLoaded = false;
    }
    Future<List> fut = _classifyCoral(await _cropDetected());
    setState(() {
      _detectFuture = fut;
    });
  }

  /// Parse object data from [results] and set to [_data]
  void _parseDetectedCoral(List results) {
    String coralType = "";
    double confidence = 0.0;
    int numClasses = results.length;

    for(var map in results) {
      coralType += "${map["label"]}, ";
      confidence += map["confidence"];
    }

    coralType = coralType.substring(0, coralType.length - 2);
    coralType = coralType.replaceAll("_", " ");
    confidence = confidence/numClasses;

    setState(() {
      _data.detectedClass = coralType;
      _data.prob = confidence;
    });

  }

  /// Crop the detected object from the current png image
  Future<img.Image> _cropDetected() async {
    img.Image tmp = img.decodeImage(await _imageFile.readAsBytes());
    tmp = img.copyCrop(
        tmp,
        (tmp.width * _editingRect["y"]).round(),
        (tmp.height * _editingRect["x"]).round(),
        (tmp.width * _editingRect["h"]).round(),
        (tmp.height * _editingRect["w"]).round()
    );
    tmp = img.copyRotate(tmp, 90);
    return img.copyResize(tmp,
        width: _imageSize,
        height: _imageSize
    );
  }

  /// Load Tflite Model
  Future<void> _loadModel() {
    return Tflite.loadModel(
      model: "assets/coral_classification.tflite",
      labels: "assets/coral_classification.txt",
      numThreads: 2,
    );
  }

  /// Classify the coral in [image]
  Future<List> _classifyCoral(img.Image image) async {

    List resultList;

    try {
      resultList = await Tflite.runModelOnBinary(
        binary: _imageToByteListFloat32(image, _imageSize, 127.5, 127.5),
        numResults: 12,
        threshold: 0.2,
      );
    } catch (e) {
      print("TFLite model error: $e");
    }

    // Return Detected Object and Confidence
    return resultList;

  }

  /// Convert [image] to Uint8List
  Uint8List _imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < image.height; i++) {
      for (var j = 0; j < image.width; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = img.getRed(pixel);
        buffer[pixelIndex++] = img.getGreen(pixel);
        buffer[pixelIndex++] = img.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  /// Convert [image] to Uint8List of Float32
  Uint8List _imageToByteListFloat32(img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  /// Get the Screen Size of the Device using [context]
  Size _screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Determine what paint to use
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
                    onPressed: () => _showData ? _deepDetect() : {},
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
        height: _screenSize(context).height,
        width: _screenSize(context).width,
        color: Colors.black,
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
      floatingActionButton: SafeArea(
        minimum: MediaQuery.of(context).padding,
        child: Stack(
          children: <Widget> [
            _editMode ? _editModeButtons() : _classifyButtons(),
            FutureBuilder<List>(
              future: _detectFuture,
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.none || snapshot.connectionState == ConnectionState.done) {
                  if(snapshot?.data != null) {
                    SchedulerBinding.instance.addPostFrameCallback((_) => _parseDetectedCoral(snapshot.data));
                  }
                  return SizedBox.shrink();
                } else {
                  return Container(
                    color: Colors.black.withOpacity(0.5),
                    height: _screenSize(context).height,
                    width: _screenSize(context).width,
                    child: Center(
                      child: SpinKitCubeGrid(
                        color: Colors.white,
                        size: 50.0,
                        controller: _loadingAnimation,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}