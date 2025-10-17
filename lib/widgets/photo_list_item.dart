import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/photo_model.dart';
import '../views/image_analysis_screen.dart';

class PhotoListItem extends StatelessWidget {
  final PhotoModel photo;

  const PhotoListItem({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, yyyy').format(photo.date);
    final time = DateFormat('h:mm a').format(photo.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageAnalysisScreen(imagePath: photo.path),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(photo.path),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBox(date),
              const SizedBox(height: 6),
              _buildInfoBox(time),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}