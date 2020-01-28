import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

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
  Future<void> _camFuture;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _initializeCamera();
  }

  void _initializeCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    _camControl = CameraController(cameras.first, ResolutionPreset.medium);
    _camFuture = _camControl.initialize();
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
              "Just Text",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            FutureBuilder<void>(
              future: _camFuture,
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.done) {
                  return Expanded (
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        child: AspectRatio(
                            aspectRatio: _camControl.value.aspectRatio,
                            child: CameraPreview(_camControl)
                        )
                      )
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator()
                  );
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
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
                builder: (context) => DisplayPictureScreen(imagePath: path)
              ),
            );
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Display the Image"),
      ),
      body: Image.file(File(imagePath)),
    );
  }
}
