import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';

class CameraInstructionsScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const CameraInstructionsScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 20),

            // ===== IMAGEM DE INSTRUÇÃO =====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Image.asset(
                  'assets/camera.jpeg',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // ===== BOTÃO ABRIR CÂMERA =====
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Abre a câmera e espera o resultado (foto tirada)
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CameraScreen(cameras: cameras),
                      ),
                    );

                    // Se recebeu uma imagem, retorna ela pro HomeScreen
                    if (result is String && result.isNotEmpty) {
                      Navigator.pop(context, result);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4EA39B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.camera_alt_outlined, size: 26),
                  label: const Text(
                    'Abrir Câmera',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
