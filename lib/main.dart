import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:reef_ai/Gallery/Gallery.dart';
import 'package:reef_ai/Camera/CameraPage.dart';
import 'package:reef_ai/Settings/Settings.dart';
import 'package:reef_ai/Data/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  startUpDetection = prefs.getBool('startUpDetection');
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.storage
  ].request();
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
