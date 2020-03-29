import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:reef_ai/Gallery.dart';
import 'package:reef_ai/CameraPage.dart';
import 'package:reef_ai/Settings.dart';
import 'package:reef_ai/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  startUpDetection = prefs.getBool('startUpDetection');
  FirebaseApp app = await FirebaseApp.configure(
      name: 'reef-ai',
      options: FirebaseOptions(
        projectID: 'reef-ai',
        googleAppID: '1:348443383043:android:81f13e78cefce4d4b68536',
        gcmSenderID: '348443383043',
        apiKey: 'AIzaSyCtKxOBXiMv661eHy0zuiJRbiP3j5NtIkk',
      ),
  );
  FirebaseStorage storage = FirebaseStorage(
      app: app,
      storageBucket: "gs://reef-ai.appspot.com/"
  );
  print(await storage.ref().getRoot().child('default_classification').getPath());
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
