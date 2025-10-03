import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/photo_model.dart';
import 'views/camera_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PhotoModelAdapter());

  // Inicializa câmeras
  cameras = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detecção de Melanomas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CameraScreen(cameras: cameras),
    );
  }
}