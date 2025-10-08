import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/photo_service.dart';
import '../models/photo_model.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'package:camera/camera.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // ====== LOGO NO TOPO ======
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.teal.shade100,
                backgroundImage: const AssetImage('assets/logo.jpeg'),
              ),
            ),

            const SizedBox(height: 25),

            // ====== LISTA DE IMAGENS ======
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
                        // Miniatura da imagem
                        ClipRRect(
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

            // ====== LINHA DIVISÓRIA ======
            const Divider(thickness: 1),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                "Nova Imagem",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            const Divider(thickness: 1),

            // ====== BOTÕES GALERIA / CÂMERA ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    text: "Galeria",
                    icon: Icons.photo_library_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HistoryScreen()),
                      ).then((_) => _loadPhotos());
                    },
                  ),
                  _buildButton(
                    text: "Câmera",
                    icon: Icons.camera_alt_outlined,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CameraScreen(cameras: widget.cameras),
                        ),
                      );
                      _loadPhotos();
                    },
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