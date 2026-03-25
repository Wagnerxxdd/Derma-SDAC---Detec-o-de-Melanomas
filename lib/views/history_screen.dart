import 'dart:io';
import 'package:flutter/material.dart';
import '../services/photo_service.dart';
import '../models/photo_model.dart';
import 'image_analysis_screen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
      _photos = photos.reversed.toList(); // Mais recente primeiro
    });
  }

  Future<void> _deleteOnlyHistory(PhotoModel photo) async {
    await _photoService.deleteFromHistory(photo);
    await _loadPhotos();
  }

  Future<void> _deleteHistoryAndGallery(PhotoModel photo) async {
    await _photoService.deleteFromGallery(photo.path);
    await _photoService.deleteFromHistory(photo);
    await _loadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Fotos')),
      body: _photos.isEmpty
          ? const Center(child: Text('Nenhuma foto registrada.'))
          : ListView.builder(
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImageAnalysisScreen(imagePath: photo.path),
                  ),
                );
              },
              child: Column(
                children: [
                  Image.file(File(photo.path)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tirada em: ${photo.date}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delete_history') {
                              await _deleteOnlyHistory(photo);
                            } else if (value == 'delete_all') {
                              await _deleteHistoryAndGallery(photo);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem<String>(
                              value: 'delete_history',
                              child: Text('Excluir só do histórico'),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete_all',
                              child: Text('Excluir histórico + galeria'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}