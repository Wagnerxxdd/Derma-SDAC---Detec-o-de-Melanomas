import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import '../services/photo_service.dart';
import 'history_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final PhotoService _photoService = PhotoService();
  bool _flashOn = false;
  double _currentZoom = 1.0;
  double _maxZoom = 1.0;
  double _minZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initialize(widget.cameras);
    _maxZoom = await _cameraService.controller.getMaxZoomLevel();
    _minZoom = await _cameraService.controller.getMinZoomLevel();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    setState(() => _flashOn = !_flashOn);
    await _cameraService.controller.setFlashMode(
      _flashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> _takePicture() async {
    try {
      final image = await _cameraService.takePicture();
      await _photoService.savePhoto(image.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📸 Foto salva em: ${image.path}')),
      );

      Navigator.pop(context); // volta para a tela anterior
    } catch (e) {
      debugPrint('Erro ao tirar foto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Câmera'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off,
              color: _flashOn ? Colors.yellow : Colors.white,
            ),
            tooltip: 'Flash',
            onPressed: _toggleFlash,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _cameraService.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // ====== VISOR DA CÂMERA ======
                CameraPreview(_cameraService.controller),

                // ====== SLIDER DE ZOOM ======
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Slider(
                        activeColor: Colors.teal,
                        value: _currentZoom,
                        min: _minZoom,
                        max: _maxZoom,
                        onChanged: (value) async {
                          setState(() => _currentZoom = value);
                          await _cameraService.controller.setZoomLevel(value);
                        },
                      ),
                      Text(
                        "Zoom: ${_currentZoom.toStringAsFixed(1)}x",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}