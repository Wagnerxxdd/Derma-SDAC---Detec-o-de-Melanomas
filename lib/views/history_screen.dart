import 'dart:io';
import 'package:flutter/material.dart';
import '../services/photo_service.dart';
import '../models/photo_model.dart';

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
            child: Column(
              children: [
                Image.file(File(photo.path)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Tirada em: ${photo.date}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}