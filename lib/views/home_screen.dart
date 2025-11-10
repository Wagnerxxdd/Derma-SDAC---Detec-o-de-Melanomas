import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/photo_service.dart';
import '../models/photo_model.dart';
import 'image_analysis_screen.dart';
import 'camera_instructions_screen.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'contributors_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PhotoService _photoService = PhotoService();
  List<PhotoModel> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final photos = await _photoService.getPhotos();
    setState(() {
      _photos = photos.reversed.toList();
    });
  }

  /// 📁 Escolher imagem da galeria e ir direto pra análise
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _photoService.savePhoto(pickedFile.path);
      await _loadPhotos();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageAnalysisScreen(imagePath: pickedFile.path),
          ),
        );
      }
    }
  }

  /// 📸 Abrir câmera com instruções → capturar foto → ir para análise
  Future<void> _openCameraFlow() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraInstructionsScreen(cameras: widget.cameras),
      ),
    );

    // Se a câmera retornar o caminho da imagem, já abre análise
    if (result is String && result.isNotEmpty) {
      await _photoService.savePhoto(result);
      await _loadPhotos();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageAnalysisScreen(imagePath: result),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ===== LOGO =====
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.teal.shade100,
                backgroundImage: const AssetImage('assets/logo.jpeg'),
              ),
            ),

            // ===== CABEÇALHO =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.teal),
                    tooltip: 'Sobre o projeto',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContributorsScreen()),
                      );
                    },
                  ),
                  const Text(
                    "Histórico",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.teal),
                    tooltip: 'Atualizar histórico',
                    onPressed: _loadPhotos,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ===== LISTA DE IMAGENS =====
            Expanded(
              child: _photos.isEmpty
                  ? const Center(
                child: Text(
                  'Nenhuma imagem registrada.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
                  : ListView.builder(
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  final photo = _photos[index];
                  final date = DateFormat('MMM d, yyyy').format(photo.date);
                  final time = DateFormat('h:mm a').format(photo.date);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ImageAnalysisScreen(imagePath: photo.path),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(photo.path),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),

                        // Data e hora
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(date, style: const TextStyle(fontSize: 13)),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(time, style: const TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ===== DIVISÓRIA =====
            const Divider(thickness: 1),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                "Nova Imagem",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            const Divider(thickness: 1),

            // ===== BOTÕES GALERIA / CÂMERA =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    text: "Galeria",
                    icon: Icons.photo_library_outlined,
                    onPressed: _pickImageFromGallery,
                  ),
                  _buildButton(
                    text: "Câmera",
                    icon: Icons.camera_alt_outlined,
                    onPressed: _openCameraFlow,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4EA39B),
        foregroundColor: Colors.white,
        minimumSize: const Size(140, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      icon: Icon(icon, size: 26),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
