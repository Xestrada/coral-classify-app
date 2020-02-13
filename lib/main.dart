import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import './Gallery.dart';
import './CameraPage.dart';

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
