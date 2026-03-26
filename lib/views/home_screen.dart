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

  Future<void> _confirmAndClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Text(
          'Deseja remover todos os itens do histórico?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _photoService.clearHistory();
    await _loadPhotos();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Histórico limpo com sucesso.')),
    );
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isScanExpanded = false;
    });
    _animationController.reverse();

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _photoService.savePhotoToHistory(pickedFile.path);
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

  Future<void> _deleteOnlyHistory(PhotoModel photo) async {
    await _photoService.deleteFromHistory(photo);
    await _loadPhotos();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagem removida apenas do histórico.')),
    );
  }

  Future<void> _deleteHistoryAndGallery(PhotoModel photo) async {
    final deletedInGallery = await _photoService.deleteFromGallery(photo.path);
    await _photoService.deleteFromHistory(photo);
    await _loadPhotos();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deletedInGallery
              ? 'Imagem removida do histórico e da galeria.'
              : 'Removida do histórico. Não foi possível confirmar exclusão da galeria.',
        ),
      ),
    );
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
                _buildHeader(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
          if (_isScanExpanded) _buildScanOverlay(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.teal.shade100,
            backgroundImage: const AssetImage('assets/logo.jpeg'),
          ),
          const SizedBox(width: 12),
          const Text(
            'Derma SDAC',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.teal),
            tooltip: 'Limpar histórico',
            onPressed: _confirmAndClearHistory,
          ),
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
                      final date =
                          DateFormat('MMM d, yyyy').format(photo.date);
                      final time = DateFormat('h:mm a').format(photo.date);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ImageAnalysisScreen(imagePath: photo.path),
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
                                PopupMenuButton<String>(
                                  tooltip: 'Ações da imagem',
                                  onSelected: (value) async {
                                    if (value == 'open') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ImageAnalysisScreen(
                                            imagePath: photo.path,
                                          ),
                                        ),
                                      );
                                    } else if (value == 'delete_history') {
                                      await _deleteOnlyHistory(photo);
                                    } else if (value == 'delete_all') {
                                      await _deleteHistoryAndGallery(photo);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem<String>(
                                      value: 'open',
                                      child: Text('Abrir análise'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete_history',
                                      child: Text('Excluir só do histórico'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete_all',
                                      child: Text('Excluir histórico + galeria'),
                                    ),
                                  ],
                                  child: Icon(
                                    Icons.more_vert,
                                    color: Colors.grey.shade500,
                                  ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.teal, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
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
      notchMargin: 8.0,
      color: Colors.white,
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.history,
              label: 'Histórico',
              index: 0,
            ),
            const SizedBox(width: 40), // Espaço para o botão flutuante
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
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
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
            color: isSelected ? Colors.teal : Colors.grey.shade600,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.teal : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _toggleScanMenu,
      child: const Icon(Icons.camera_alt, color: Colors.white),
      backgroundColor: Colors.teal,
      elevation: 4.0,
    );
  }
}