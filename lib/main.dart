import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import './Gallery.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _camControl = CameraController(widget.cameras.first, ResolutionPreset.medium);
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
                        builder: (context) => Gallery(imagePath: path),
                    ),
                  );
                } catch (e) {
                  print(e);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
