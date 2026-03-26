import 'package:camera/camera.dart';

class CameraService {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  CameraController get controller => _controller;
  Future<void> get initializeControllerFuture => _initializeControllerFuture;

  Future<void> initialize(List<CameraDescription> cameras) async {
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
  }

  Future<XFile> takePicture() async {
    await _initializeControllerFuture;
    return await _controller.takePicture();
  }

  void dispose() {
    _controller.dispose();
  }
}
