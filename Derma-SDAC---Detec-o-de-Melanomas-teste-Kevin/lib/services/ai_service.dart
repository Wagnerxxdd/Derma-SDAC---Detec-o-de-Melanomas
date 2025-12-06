import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Serviço responsável por enviar imagens para o backend de IA
/// e retornar as probabilidades de melanoma maligno/benigno.
///
/// Assim que o backend enviar o endpoint, basta ajustar a constante [apiUrl].
class AIService {
  // 🔗 Substitua esta URL quando o backend enviar o endpoint real
  static const String apiUrl = "https://api.seu-backend.com/analyze";

  /// Analisa uma imagem localmente e retorna as probabilidades.
  ///
  /// Retorna um mapa com as chaves:
  ///  - "malignant": probabilidade (0–100)
  ///  - "benign": probabilidade (0–100)
  ///
  /// Em caso de erro de rede ou resposta inválida, lança uma Exception.
  Future<Map<String, double>> analyzeImage(String imagePath) async {
    try {
      // Lê os bytes da imagem e converte para base64
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      // Envia a requisição HTTP
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer SEU_TOKEN_AQUI', // se o back exigir
        },
        body: jsonEncode({'image': base64Image}),
      );

      // Log básico (útil para debug)
      print("📤 Enviando imagem para análise...");
      print("📥 Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Garante que o backend devolva os campos esperados
        final malignant = (data['malignant_probability'] ?? 0.0) * 100;
        final benign = (data['benign_probability'] ?? 0.0) * 100;

        return {
          'malignant': malignant,
          'benign': benign,
        };
      } else {
        throw Exception('Erro na resposta da IA: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Erro ao analisar imagem: $e");
      rethrow;
    }
  }
}
