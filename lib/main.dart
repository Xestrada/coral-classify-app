import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:reef_ai/Gallery.dart';
import 'package:reef_ai/CameraPage.dart';
import 'package:reef_ai/Settings.dart';
import 'package:reef_ai/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  startUpDetection = prefs.getBool('startUpDetection');
  runApp(ReefAI(cameras: cameras));
}

class ReefAI extends StatelessWidget {

  final List<CameraDescription> cameras;
  ReefAI({this.cameras});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reef AI',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => CameraPage(
          title: 'Camera Page',
          cameras: cameras,
        ),
        '/gallery': (context) => Gallery(),
        '/settings': (context) => Settings()
      }
    );
  }
}
