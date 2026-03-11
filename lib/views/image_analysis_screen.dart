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
<<<<<<< HEAD

=======
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
  bool _isAnalyzing = false;
  String _analysisMessage = "";
  double? _malignantProbability;
  double? _benignProbability;
  bool? _isMalignant;

  @override
  void dispose() {
<<<<<<< HEAD
    _aiService.close();
=======
    _aiService.close(); 
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    if (!mounted) return;
<<<<<<< HEAD

=======
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
    setState(() {
      _isAnalyzing = true;
      _analysisMessage = "Carregando modelos de IA...";
      _malignantProbability = null;
    });

    try {
      await _aiService.loadModels();

      if (!mounted) return;
<<<<<<< HEAD

      setState(() {
        _analysisMessage = "Segmentando lesão e analisando com IA...";
      });

      final results = await _aiService.runAnalysis(widget.imagePath);

      if (mounted) {
        final prob = (results['probabilidade'] as num).toDouble();

        setState(() {
          _malignantProbability = prob;
          _benignProbability = 100 - prob;
          _isMalignant = results['isMelanoma'];
        });
      }
    } catch (e, s) {
      print("Erro durante a análise: $e");
      print("Stack trace: $s");

=======
      setState(() {
        _analysisMessage = "Realizando classificação com MLP...";
      });

      final results = await _aiService.runFullAnalysis(widget.imagePath);

      if (mounted) {
        setState(() {
          _malignantProbability = (results['malignantProb'] as num).toDouble();
          _benignProbability = 100 - (results['malignantProb'] as num).toDouble();
          _isMalignant = results['isMalignant'];
        });
      }

    } catch (e, s) {
      print("Erro durante a análise: $e");
      print("Stack trace: $s");
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro na análise: $e")),
        );
      }
    } finally {
<<<<<<< HEAD
=======
      _aiService.close();
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
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
<<<<<<< HEAD
        padding: const EdgeInsets.all(16),
=======
        padding: const EdgeInsets.all(16.0),
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
<<<<<<< HEAD
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
=======
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(File(widget.imagePath), fit: BoxFit.cover),
                ],
              ),
            ),
            const SizedBox(height: 24),

>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
            if (_isAnalyzing)
              Column(
                children: [
                  const CircularProgressIndicator(color: Color(0xFF4EA39B)),
                  const SizedBox(height: 16),
<<<<<<< HEAD
                  Text(
                    _analysisMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
=======
                  Text(_analysisMessage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
                ],
              )
            else if (_malignantProbability != null)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
<<<<<<< HEAD
                      color: _isMalignant!
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isMalignant!
                            ? Colors.red.shade200
                            : Colors.green.shade200,
                      ),
=======
                      color: _isMalignant! ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _isMalignant! ? Colors.red.shade200 : Colors.green.shade200),
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
                    ),
                    child: Column(
                      children: [
                        Text(
<<<<<<< HEAD
                          _isMalignant!
                              ? "ALERTA: MELANOMA POSSÍVEL"
                              : "BAIXA PROBABILIDADE",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isMalignant!
                                ? Colors.red.shade700
                                : Colors.green.shade700,
=======
                          _isMalignant! ? "ALERTA: MELANOMA POSSÍVEL" : "BAIXA PROBABILIDADE",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isMalignant! ? Colors.red.shade700 : Colors.green.shade700,
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
<<<<<<< HEAD
                          "Esta análise é baseada em IA e não substitui diagnóstico médico.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
=======
                          "Esta análise é baseada em IA e não substitui um diagnóstico médico.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
<<<<<<< HEAD
                  _buildResultBar(
                    "Probabilidade Maligna (MLP)",
                    _malignantProbability!,
                    Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  _buildResultBar(
                    "Confiança Benigna",
                    _benignProbability!,
                    Colors.green,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
=======
                  _buildResultBar("Probabilidade Maligna (MLP)", _malignantProbability!, Colors.redAccent),
                  const SizedBox(height: 16),
                  _buildResultBar("Confiança Benigna", _benignProbability!, Colors.green),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
                    icon: const Icon(Icons.home),
                    label: const Text("Finalizar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4EA39B),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
<<<<<<< HEAD
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
=======
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _runAnalysis,
                icon: const Icon(Icons.psychology),
                label: const Text("Iniciar Análise Inteligente"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4EA39B),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
<<<<<<< HEAD
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
=======
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
>>>>>>> c55b47425c73b1f3ce8449a35c617e22aa0d352a
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("${percentage.toStringAsFixed(1)}%"),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
        ),
      ],
    );
  }
}
