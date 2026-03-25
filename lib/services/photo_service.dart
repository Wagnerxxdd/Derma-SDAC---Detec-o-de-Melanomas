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
    await savePhotoToGallery(path);
    await savePhotoToHistory(path);
  }

  /// Salva foto apenas no histórico interno do app (Hive)
  Future<void> savePhotoToHistory(String path) async {
    final box = await Hive.openBox<PhotoModel>(_boxName);
    final photo = PhotoModel(path: path, date: DateTime.now());
    await box.add(photo);
  }

  /// Salva foto apenas na galeria do dispositivo (Android)
  Future<void> savePhotoToGallery(String path) async {
    // Chama o Android para salvar a imagem na galeria
    try {
      await _channel.invokeMethod('saveImageToGallery', {'path': path});
    } on MissingPluginException {
      print("Salvar na galeria não disponível nesta plataforma.");
    } on PlatformException catch (e) {
      print("Erro ao salvar na galeria: $e");
    }
  }

  /// Recupera todas as fotos salvas no Hive
  Future<List<PhotoModel>> getPhotos() async {
    final box = await Hive.openBox<PhotoModel>(_boxName);
    return box.values.toList();
  }

  /// Limpa todo o histórico interno do app (Hive)
  Future<void> clearHistory() async {
    final box = await Hive.openBox<PhotoModel>(_boxName);
    await box.clear();
  }

  /// Exclui apenas do histórico interno (Hive)
  Future<void> deleteFromHistory(PhotoModel photo) async {
    if (photo.isInBox) {
      await photo.delete();
      return;
    }

    final box = await Hive.openBox<PhotoModel>(_boxName);
    final keyToDelete = box.keys.cast<dynamic>().firstWhere(
      (key) {
        final value = box.get(key);
        return value != null &&
            value.path == photo.path &&
            value.date == photo.date;
      },
      orElse: () => null,
    );

    if (keyToDelete != null) {
      await box.delete(keyToDelete);
    }
  }

  /// Exclui arquivo da galeria do dispositivo pelo caminho
  Future<bool> deleteFromGallery(String path) async {
    try {
      final deleted = await _channel.invokeMethod<bool>(
        'deleteImageFromGallery',
        {'path': path},
      );
      return deleted ?? false;
    } on MissingPluginException {
      print("Exclusão na galeria não disponível nesta plataforma.");
      return false;
    } on PlatformException catch (e) {
      print("Erro ao excluir da galeria: $e");
      return false;
    }
  }
}