import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:tflite/tflite.dart';
import './Gallery.dart';
import './ObjectRect.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  await Tflite.loadModel(
    model: "assets/ssd_mobilenet.tflite",
    labels: "assets/ssd_mobilenet.txt",
    numThreads: 1,
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
      home: CameraPage(
          title: 'Camera Page',
          cameras: cameras,
      ),
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

  CameraController _camControl;
  Future<void> _camFuture;
  Map _savedRect;
  bool _isDetecting;

  @override
  void initState() {
    super.initState();
    _isDetecting = false;
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // Setup Camera Control
    _camControl = CameraController(widget.cameras.first, ResolutionPreset.high);
    _camFuture = _camControl.initialize().then((_) async {
      await _camControl.startImageStream((CameraImage image) =>
          _processCameraImage(image)
      );
    });

  }

  @override
  void dispose() {
    _camControl?.dispose();
    super.dispose();
  }

  // Find Corals from a CameraImage
  Future<Map> _findCorals(CameraImage image) async {

    List resultList = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(),
      model: "SSDMobileNet",
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      threshold: 0.4,
    );

    List<String> possibleCoral = ['dog', 'cat', 'bear', 'teddy bear', 'sheep'];
    Map biggestRect;
    double rectSize, rectMax = 0.0;

    if(resultList != null) {
      for (var item in resultList) {
        if (possibleCoral.contains(item["detectedClass"])) {
          Map aRect = item["rect"];
          rectSize = aRect["w"] * aRect["h"];
          if (rectSize > rectMax) {
            rectMax = rectSize;
            biggestRect = aRect;
          }
        }
      }
    }

    return biggestRect;

  }

  // Process a CameraImage from the camera
  void _processCameraImage(CameraImage image) async {
    if(!_isDetecting) {
      _isDetecting = true;
      // Detect Corals
      Future findCoralFuture = _findCorals(image);
      List results = await Future.wait(
        [findCoralFuture, Future.delayed(Duration(milliseconds: 500))]
      );
      _isDetecting = false;
      setState(() {
        _savedRect = results[0];
      });
    }
  }

  /// Take a picture
  void _takePicture(BuildContext context) async {
    try {
      await _camFuture;

      final String path = join(
          (await getTemporaryDirectory()).path,
          '${DateTime.now()}.png'
      );

      await _camControl.takePicture(path);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Gallery(imagePath: path),
        ),
      );
    } catch (e) {
      print(e);
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
              child:OverflowBox(
                maxWidth: double.infinity,
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
                        return AspectRatio(
                          aspectRatio: _camControl.value.aspectRatio,
                          child: CameraPreview(_camControl),
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
      floatingActionButton: Stack(
        children: <Widget> [
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.camera_alt),
              onPressed: () => _takePicture(context),
            ),
          ),
        ],
      ),
    );
  }
}
