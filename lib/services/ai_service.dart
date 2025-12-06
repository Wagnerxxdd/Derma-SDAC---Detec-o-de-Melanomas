import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';

class AiService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    // Carrega o modelo dos assets e o copia para um arquivo temporário.
    // Esta abordagem é mais robusta e evita deadlocks em alguns dispositivos.
    final modelData = await rootBundle.load('assets/models/derma_unet_v02.tflite');
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/model.tflite');
    await tempFile.writeAsBytes(
        modelData.buffer.asUint8List(modelData.offsetInBytes, modelData.lengthInBytes));

    _interpreter = await Interpreter.fromFile(tempFile);
  }

  Future<List<dynamic>> runInference(String imagePath) async {
    if (_interpreter == null) {
      throw Exception('Erro: O interpretador de IA não foi carregado.');
    }

    final imageBytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(imageBytes)!;
    final resizedImage = img.copyResize(image, width: 256, height: 256);

    final input = _imageToInputList(resizedImage);

    final output = List.filled(1 * 256 * 256 * 1, 0.0).reshape([1, 256, 256, 1]);

    _interpreter!.run(input, output);

    return output;
  }

  List<dynamic> _imageToInputList(img.Image image) {
    var buffer = Float32List(1 * 256 * 256 * 3);
    var bufferIndex = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        var pixel = image.getPixel(x, y);
        buffer[bufferIndex++] = pixel.r / 255.0;
        buffer[bufferIndex++] = pixel.g / 255.0;
        buffer[bufferIndex++] = pixel.b / 255.0;
      }
    }
    return buffer.reshape([1, 256, 256, 3]);
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
