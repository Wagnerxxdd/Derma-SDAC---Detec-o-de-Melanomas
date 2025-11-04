import 'dart:io';
import 'package:flutter/material.dart';

class ImageAnalysisScreen extends StatefulWidget {
  final String imagePath;

  const ImageAnalysisScreen({super.key, required this.imagePath});

  @override
  State<ImageAnalysisScreen> createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends State<ImageAnalysisScreen> {
  bool _isAnalyzing = false;
  double? _malignantProbability;
  double? _benignProbability;

  Future<void> _simulateAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    // Simula o tempo de "análise" da IA
    await Future.delayed(const Duration(seconds: 2));

    // Simula resultados (fixos aqui, mas pode vir do backend)
    const malignant = 72.0;
    const benign = 28.0;

    setState(() {
      _isAnalyzing = false;
      _malignantProbability = malignant;
      _benignProbability = benign;
    });
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
            // ====== IMAGEM ======
            Expanded(
              child: Image.file(File(widget.imagePath)),
            ),
            const SizedBox(height: 20),

            // ====== ESTADOS ======
            if (_isAnalyzing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Analisando imagem..."),
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
                    color: Colors.green,
                  ),
                  Text("${_benignProbability!.toStringAsFixed(1)}%"),
                  const SizedBox(height: 30),

                  // ✅ Botão para voltar à tela inicial
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: const Text("Voltar para início"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _simulateAnalysis,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text("Analisar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
