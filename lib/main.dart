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

  CameraController camControl;
  bool camInit = false;
  String topText = "";

  void initializeCamera() async {
    topText = "Camera is Initializing";
    List<CameraDescription> cameras = await availableCameras();
    camControl = CameraController(cameras[0], ResolutionPreset.medium);
    camControl.initialize().then( (onValue) {
      camInit = true;
      topText = "Camera is Initialized";
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
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
              topText,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            camInit ? Expanded(
              child: OverflowBox(
                maxWidth: double.infinity,
                child: AspectRatio(
                  aspectRatio: camControl.value.aspectRatio,
                  child: CameraPreview(camControl)
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
