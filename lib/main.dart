import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:tflite/tflite.dart';
import './Gallery.dart';
import './ObjectRect.dart';
import './ClassifyPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  await Tflite.loadModel(
    model: "assets/ssd_mobilenet.tflite",
    labels: "assets/ssd_mobilenet.txt",
    numThreads: 4,
  );
  runApp(CoralClassify(cameras: cameras));
}

class CoralClassify extends StatelessWidget {

  final List<CameraDescription> cameras;
  CoralClassify({this.cameras});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coral Classify',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => CameraPage(
          title: 'Camera Page',
          cameras: cameras,
        ),
        '/gallery': (context) => Gallery(),
      }
    );
  }
}

class CameraPage extends StatefulWidget {
  final String title;
  final List<CameraDescription> cameras;
  CameraPage({Key key,
    this.title,
    @required this.cameras,
  }) : super(key: key);
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {

  /// Used to control the camera
  CameraController _camControl;
  /// Used to initialize the camera
  Future<void> _camFuture;
  /// A Map representing the location in an image that contains an object
  Map _savedRect;
  /// The type of object detected
  String _savedObjectType;
  /// Confidence that it is the type of Object
  double _savedProb;
  /// Flag determining when a coral is being detected
  bool _isDetecting;
  // Flag Determining if an ImageStream is running
  bool _isImageStreaming;
  //Flag controlling ImageStreaming
  bool _shouldImageStream;

  @override
  void initState() {

    super.initState();
    _isDetecting = false;
    _shouldImageStream = true;
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // Setup Camera Control
    _camControl = CameraController(widget.cameras.first, ResolutionPreset.max, enableAudio: false);
    _camFuture = _camControl.initialize().then((_) async {
      await _camControl.startImageStream((CameraImage image) =>
          _processCameraImage(image)
      );
      _isImageStreaming = true;
    });

  }

  @override
  void dispose() {
    _camControl?.dispose();
    super.dispose();
  }

  /// Find Corals in [image]
  Future<List> _findCorals(CameraImage image) async {

    List resultList = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(),
      model: "SSDMobileNet",
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      threshold: 0.2,

    );

    List<String> possibleCoral = ['dog', 'cat']; // List of possible Objects
    Map biggestRect; // Biggest Rect of detected Object
    double maxProb = 0.0;
    String objectType; // Detected Object name
    double prob; // Confidence in Class

    if(resultList != null) {
      for (var item in resultList) {
        if (possibleCoral.contains(item["detectedClass"])) {
          // Choose Object with greatest confidence
          if (item["confidenceInClass"] > maxProb) {
            biggestRect = item["rect"];
            objectType = item["detectedClass"];
            maxProb = prob = item["confidenceInClass"];
          }
        }
      }
    }

    // Return Map of rectangle, type of detected Object, and confidence
    return [biggestRect, objectType, prob];

  }

  /// Process [image] through TensorFlow model
  void _processCameraImage(CameraImage image) async {
    if(!_isDetecting) {
      _isDetecting = true;
      // Detect Corals
      List results = await Future.wait(
        [_findCorals(image), Future.delayed(Duration(milliseconds: 1100))]
      );
      _isDetecting = false;
      setState(() {
        _savedRect = results[0][0];
        _savedObjectType = results[0][1];
        _savedProb = results[0][2];
      });
    }
  }

  /// Take a picture and create a new page using [context] showing the image
  void _takePicture(BuildContext context) async {
    // Ensure camera is ready and available
    await _camFuture;

    final String path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png'
    );

    try {

      // Stop Image Stream.
      if(_isImageStreaming && _shouldImageStream) {
        await _camControl.stopImageStream();
        _isImageStreaming = false;
      }
      // TODO - Fix issue with delay being necessary to take picture
      // Attempt to take picture
      await Future.delayed(Duration(milliseconds: 4));
      await _camControl.takePicture(path);
      // Go to ClassifyPage
      _goToClassifyPage(context, path);
      //Restart ImageStreaming
      if(!_isImageStreaming && _shouldImageStream) {
        await _camControl.startImageStream((CameraImage image) =>
            _processCameraImage(image)
        );
        _isImageStreaming = true;
      }

    } catch (e) {
      print(e);
    }
  }

  /// Go to ClassifyPage while opening image at [path]
  void _goToClassifyPage(BuildContext context, String path) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClassifyPage(path: path)
        )
    );
  }

  /// Go to the Gallery Page
  void _goToGallery(BuildContext context) async {
    //Stop ImageStream
    if(_isImageStreaming && _shouldImageStream) {
      await _camControl.stopImageStream();
      _isImageStreaming = false;
    }
    // Go to Gallery and wait until popped
    await Navigator.pushNamed(
      context,
      '/gallery'
    );
    //Restart ImageStreaming
    if(!_isImageStreaming && _shouldImageStream) {
      await _camControl.startImageStream((CameraImage image) =>
          _processCameraImage(image)
      );
      _isImageStreaming = true;
    }
  }

  /// Toggle the ImageStream that allows for Object Detection
  void _toggleImageStream() async {
    //Toggle state
    setState(() {
      _shouldImageStream = !_shouldImageStream;
    });
    // Set Camera depending on state
    if(_shouldImageStream) {
      await _camControl.startImageStream((CameraImage image) =>
          _processCameraImage(image)
      );
      _isImageStreaming = true;
    } else {
      await _camControl.stopImageStream();
      _isImageStreaming = false;
    }
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
                child: FutureBuilder<void>(
                  future: _camFuture,
                  // ignore: missing_return
                  builder: (context, snapshot) {
                    switch(snapshot.connectionState) {
                      case ConnectionState.waiting:
                        {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } break;
                      case ConnectionState.active:
                        continue done;
                      done:
                      case ConnectionState.done: {
                        return Stack (
                            fit: StackFit.expand,
                            children: <Widget> [
                              CameraPreview(_camControl),
                              CustomPaint(
                                painter:
                                  ObjectRect(
                                      _savedRect,
                                      _savedObjectType,
                                      _savedProb
                                  )
                              ),
                            ]
                        );
                      } break;
                      case ConnectionState.none: {
                        continue def;
                      }
                      def:
                      default: {
                        return Center(
                          child: Text(
                            "Failed ot Initialize Cameras",
                          ),
                        );
                      }
                    }
                  }
                ),
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
                child: Icon(_shouldImageStream ? MdiIcons.eye : MdiIcons.eyeOff),
                onPressed: () => _toggleImageStream(),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: FloatingActionButton(
                heroTag: null,
                child: Icon(Icons.camera_alt),
                onPressed: () => _takePicture(context),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                heroTag: null,
                child: Icon(Icons.photo_album),
                onPressed: () => _goToGallery(context),
              ),
            ),
          ],
        ),
      )
    );
  }
}
