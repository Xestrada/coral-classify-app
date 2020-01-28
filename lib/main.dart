import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

void main() => runApp(CoralClassify());

class CoralClassify extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coral Classify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraPage(title: 'Camera Page'),
    );
  }
}

class CameraPage extends StatefulWidget {
  CameraPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {

  CameraController _camControl;
  bool _camInit = false;
  String _topText = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _initializeCamera();
  }

  void _initializeCamera() async {
    _topText = "Camera is Initializing";
    List<CameraDescription> cameras = await availableCameras();
    _camControl = CameraController(cameras.first, ResolutionPreset.medium);
    _camControl.initialize().then( (_) {
      _camInit = true;
      _topText = "Camera is Initialized";
      setState(() {});
    });
  }

  @override
  void dispose() {
    _camControl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            Text(
              _topText,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            _camInit ? Expanded(
              child: OverflowBox(
                maxWidth: double.infinity,
                child: AspectRatio(
                  aspectRatio: _camControl.value.aspectRatio,
                  child: CameraPreview(_camControl)
                )
              )
            ) : Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
      ),
    );
  }

}
