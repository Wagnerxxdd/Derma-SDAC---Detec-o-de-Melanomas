import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/photo_model.dart';

class PhotoService {
  static const String _boxName = "photos";

  // Canal para chamar código nativo Android
  static const MethodChannel _channel =
  MethodChannel('com.example.detecao_de_melanomas/photos');

  /// Salva foto na galeria (Android) + Hive
  Future<void> savePhoto(String path) async {
    // Chama o Android para salvar a imagem na galeria
    try {
      await _channel.invokeMethod('saveImageToGallery', {'path': path});
    } on PlatformException catch (e) {
      print("Erro ao salvar na galeria: $e");
    }

    // Salva no Hive (histórico interno do app)
    final box = await Hive.openBox<PhotoModel>(_boxName);
    final photo = PhotoModel(path: path, date: DateTime.now());
    await box.add(photo);
  }

  /// Recupera todas as fotos salvas no Hive
  Future<List<PhotoModel>> getPhotos() async {
    final box = await Hive.openBox<PhotoModel>(_boxName);
    return box.values.toList();
  }
}