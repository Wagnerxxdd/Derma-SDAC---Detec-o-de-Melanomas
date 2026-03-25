import 'dart:io';
import 'package:flutter/material.dart';
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
  bool? _isMalignant;

  Map<String, dynamic>? _abcde;

  @override
  void dispose() {
    _aiService.close();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    if (!mounted) return;

    setState(() {
      _isAnalyzing = true;
      _analysisMessage = "Carregando modelos...";
      _malignantProbability = null;
      _abcde = null;
    });

    try {
      await _aiService.loadModels();

      if (!mounted) return;

      setState(() {
        _analysisMessage = "Segmentando e analisando...";
      });

      final results = await _aiService.runAnalysis(widget.imagePath);

      if (mounted) {
        final prob = (results['probabilidade'] as num).toDouble();

        setState(() {
          _malignantProbability = prob;
          _benignProbability = 100 - prob;
          _isMalignant = results['isMelanoma'];
          _abcde = results['abcde'];
        });
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e")),
        );
      }
    } finally {
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
        title: const Text("Resultado da IA"),
        backgroundColor: const Color(0xFF4EA39B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            /// IMAGEM
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// LOADING
            if (_isAnalyzing)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_analysisMessage),
                ],
              )

            /// RESULTADO
            else if (_malignantProbability != null)
              Column(
                children: [

                  /// ALERTA
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isMalignant!
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isMalignant!
                            ? Colors.red.shade200
                            : Colors.green.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isMalignant!
                              ? "ALERTA: MELANOMA POSSÍVEL"
                              : "BAIXA PROBABILIDADE",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isMalignant!
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isMalignant!
                              ? "Procure um dermatologista o quanto antes. Não confie 100% neste resultado."
                              : "Não identificamos sinais fortes de melanoma, mas se notar algo estranho procure um médico.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Não substitui diagnóstico médico",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// BARRAS
                  _buildBar("Probabilidade Maligna", _malignantProbability!),
                  const SizedBox(height: 16),
                  _buildBar("Benigno", _benignProbability!, isGreen: true),

                  const SizedBox(height: 24),

                  /// ABCDE
                  if (_abcde != null) _buildABCDE(),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
                    child: const Text("Finalizar"),
                  )
                ],
              )

            /// BOTÃO
            else
              ElevatedButton(
                onPressed: _runAnalysis,
                child: const Text("Iniciar Análise"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double value, {bool isGreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toStringAsFixed(1)}%"),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value / 100,
          color: isGreen ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _buildABCDE() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Análise ABC",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        _abcItem("A - Assimetria", _abcde!["assimetria"]),
        _abcItem("B - Borda", _abcde!["borda"]),
        _abcItem("C - Cor", _abcde!["cor"]),
      ],
    );
  }

  Widget _abcItem(String title, double value) {

    final isBad = value > 0.5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            isBad ? "Alterado" : "Normal",
            style: TextStyle(
              color: isBad ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
