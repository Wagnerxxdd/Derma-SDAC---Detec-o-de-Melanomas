import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/photo_service.dart';
import '../models/photo_model.dart';
import 'image_analysis_screen.dart';
import 'camera_instructions_screen.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'contributors_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final PhotoService _photoService = PhotoService();
  List<PhotoModel> _photos = [];
  int _currentIndex = 0;
  bool _isScanExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    final photos = await _photoService.getPhotos();
    setState(() {
      _photos = photos.reversed.toList();
    });
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isScanExpanded = false;
    });
    _animationController.reverse();

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _photoService.savePhoto(pickedFile.path);
      await _loadPhotos();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageAnalysisScreen(imagePath: pickedFile.path),
          ),
        );
      }
    }
  }

  Future<void> _openCameraFlow() async {
    setState(() {
      _isScanExpanded = false;
    });
    _animationController.reverse();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraInstructionsScreen(cameras: widget.cameras),
      ),
    );

    if (result is String && result.isNotEmpty) {
      await _photoService.savePhoto(result);
      await _loadPhotos();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageAnalysisScreen(imagePath: result),
          ),
        );
      }
    }
  }

  void _toggleScanMenu() {
    setState(() {
      _isScanExpanded = !_isScanExpanded;
    });

    if (_isScanExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF4),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ===== HEADER COM LOGO E TÍTULO =====
                _buildHeader(),

                // ===== CONTEÚDO PRINCIPAL =====
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),

          // ===== MENU FLUTUANTE DE SCAN =====
          if (_isScanExpanded) _buildScanOverlay(),
        ],
      ),

      // ===== BOTTOM NAVIGATION BAR =====
      bottomNavigationBar: _buildBottomNavBar(),

      // ===== BOTÃO SCAN CENTRAL FLUTUANTE =====
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Logo circular
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.teal.shade100,
            backgroundImage: const AssetImage('assets/logo.jpeg'),
          ),
          const SizedBox(width: 12),

          // Título
          const Text(
            'Derma SDAC',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const Spacer(),

          // Botão RGX
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'RGX',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Botão de refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.teal),
            onPressed: _loadPhotos,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_currentIndex == 0) {
      // Tela de Histórico
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Histórico',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: _photos.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Nenhum registro encontrado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clique em Scan para carregar uma imagem',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                final date = DateFormat('MMM d, yyyy').format(photo.date);
                final time = DateFormat('h:mm a').format(photo.date);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImageAnalysisScreen(
                              imagePath: photo.path),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(photo.path),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                              const Icon(Icons.image,
                                  size: 60, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      // Tela "Sobre"
      return const ContributorsScreen();
    }
  }

  Widget _buildScanOverlay() {
    return GestureDetector(
      onTap: _toggleScanMenu,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildScanOption(
                    icon: Icons.photo_library,
                    label: 'Galeria',
                    onTap: _pickImageFromGallery,
                  ),
                  const SizedBox(height: 16),
                  _buildScanOption(
                    icon: Icons.camera_alt,
                    label: 'Câmera',
                    onTap: _openCameraFlow,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF4EA39B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4EA39B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Início',
              index: 0,
            ),
            const SizedBox(width: 80), // Espaço para o FAB central
            _buildNavItem(
              icon: Icons.info_outline,
              label: 'Sobre',
              index: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4EA39B) : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFF4EA39B) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF4EA39B), Color(0xFF3D8B85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4EA39B).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _toggleScanMenu,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.search,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }
}
