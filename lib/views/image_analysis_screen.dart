import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../services/ai_service.dart';

class ImageAnalysisScreen extends StatefulWidget {
  final String imagePath;

  const ImageAnalysisScreen({super.key, required this.imagePath});

  @override
  State<ImageAnalysisScreen> createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends State<ImageAnalysisScreen> {
  final AiService _aiService = AiService();
  bool _isAnalyzing = false;
  String _analysisMessage = "";
  double? _malignantProbability;
  double? _benignProbability;
  Uint8List? _segmentationMask;

  // O modelo não é mais carregado no initState

  @override
  void dispose() {
    // O dispose agora é tratado dentro do _runAnalysis, 
    // mas é uma boa prática chamar para o caso de a tela ser descartada inesperadamente.
    _aiService.close(); 
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    if (!mounted) return;
    setState(() {
      _isAnalyzing = true;
      _analysisMessage = "Carregando modelo de IA...";
      _segmentationMask = null;
      _malignantProbability = null;
    });

    try {
      await _aiService.loadModel();

      if (!mounted) return;
      setState(() {
        _analysisMessage = "Analisando imagem...";
      });

      final output = await _aiService.runInference(widget.imagePath);

      final List<dynamic> batch = output;
      final List<dynamic> image = batch[0];
      
      double positivePixels = 0;
      final maskImage = img.Image(width: 256, height: 256);

      for (int y = 0; y < 256; y++) {
        final List<dynamic> row = image[y];
        for (int x = 0; x < 256; x++) {
          final List<dynamic> pixel = row[x];
          final double value = (pixel[0] as num).toDouble();
          
          if (value > 0.5) {
            positivePixels++;
            maskImage.setPixel(x, y, img.ColorRgba8(255, 0, 0, 128));
          } else {
            maskImage.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
          }
        }
      }

      final totalPixels = 256 * 256;
      final malignantProb = (positivePixels / totalPixels) * 100;
      final encodedMask = Uint8List.fromList(img.encodePng(maskImage));

      if (mounted) {
        setState(() {
          _malignantProbability = malignantProb;
          _benignProbability = 100 - malignantProb;
          _segmentationMask = encodedMask;
        });
      }

    } catch (e, s) {
      print("Erro durante a análise: $e");
      print("Stack trace: $s");
    } finally {
      _aiService.close(); // Garante que o interpreter seja liberado após o uso.
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Análise da Imagem"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(File(widget.imagePath)),
                  if (_segmentationMask != null)
                    Image.memory(_segmentationMask!),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_isAnalyzing)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(_analysisMessage),
                ],
              )
            else if (_malignantProbability != null)
              Column(
                children: [
                  Text(
                    "Probabilidade de melanoma maligno:",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  LinearProgressIndicator(
                    value: _malignantProbability! / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    color: Colors.redAccent,
                  ),
                  Text("${_malignantProbability!.toStringAsFixed(1)}%"),
                  const SizedBox(height: 20),
                  Text(
                    "Probabilidade de melanoma benigno:",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  LinearProgressIndicator(
                    value: _benignProbability! / 100,
                    minHeight: 10,
                     backgroundColor: Colors.grey[300],
                    color: Colors.green,
                  ),
                  Text("${_benignProbability!.toStringAsFixed(1)}%"),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: const Text("Voltar para início"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4EA39B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _runAnalysis,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text("Analisar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4EA39B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
