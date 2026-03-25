import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import '../services/photo_service.dart';
import '../views/image_analysis_screen.dart'; // tela de análise

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final PhotoService _photoService = PhotoService();
  FlashMode _flashMode = FlashMode.off;
  double _currentZoom = 1.0;
  double _maxZoom = 1.0;
  double _minZoom = 1.0;
  Offset? _focusPoint;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initialize(widget.cameras);
    _maxZoom = await _cameraService.controller.getMaxZoomLevel();
    _minZoom = await _cameraService.controller.getMinZoomLevel();
    await _cameraService.controller.setFlashMode(_flashMode);
    setState(() {});
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    final nextMode = switch (_flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      _ => FlashMode.off,
    };

    await _cameraService.controller.setFlashMode(nextMode);
    setState(() => _flashMode = nextMode);
  }

  Future<void> _setFocusPoint(Offset localPosition, Size previewSize) async {
    final dx = (localPosition.dx / previewSize.width).clamp(0.0, 1.0);
    final dy = (localPosition.dy / previewSize.height).clamp(0.0, 1.0);
    final point = Offset(dx, dy);

    await _cameraService.controller.setFocusPoint(point);
    await _cameraService.controller.setExposurePoint(point);

    setState(() {
      _focusPoint = localPosition;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _focusPoint = null;
      });
    });
  }

  IconData get _flashIcon {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  String get _flashTooltip {
    switch (_flashMode) {
      case FlashMode.auto:
        return 'Flash automático';
      case FlashMode.always:
        return 'Flash ligado';
      default:
        return 'Flash desligado';
    }
  }

  Future<void> _takePicture() async {
    try {
      final image = await _cameraService.takePicture();
      await _photoService.savePhoto(image.path);

      if (!mounted) return;
      // ✅ Depois de tirar a foto, abre a tela de análise
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ImageAnalysisScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao tirar foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao tirar foto: $e')),
      );
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
            icon: Icon(_flashIcon, color: Colors.white),
            tooltip: _flashTooltip,
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _cameraService.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final previewSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) =>
                      _setFocusPoint(details.localPosition, previewSize),
                  child: Stack(
                    children: [
                      // ====== VISOR DA CÂMERA ======
                      CameraPreview(_cameraService.controller),

                      if (_focusPoint != null)
                        Positioned(
                          left: _focusPoint!.dx - 24,
                          top: _focusPoint!.dy - 24,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.tealAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

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
                            const SizedBox(height: 8),
                            const Text(
                              'Toque na tela para focar',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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
