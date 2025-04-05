import 'package:flutter/material.dart';
import '../Models/WordData.dart';
import '../utils/audio_player.dart';

class WordDisplay extends StatelessWidget {
  final WordData word;

  const WordDisplay({super.key, required this.word});

  Future<void> playAudio(bool isEnglish) async {
    String audioPath = isEnglish ? word.audioEn! : word.audioVn!;
    await AudioPlayerUtil.playAssetAudio(audioPath.replaceFirst('assets/', ''));
  }

  Widget _buildImageWidget(String imagePath) {
    return Image(
      image: AssetImage(imagePath),
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image $imagePath: $error');
        return Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        );
      },
    );
  }

  Widget _buildWordRow(String text, bool isEnglish) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => playAudio(isEnglish),
            icon: const Icon(Icons.volume_up),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImageWidget(word.image!),
          ),
          const SizedBox(height: 16),
          _buildWordRow(word.en!, true),
          _buildWordRow(word.vn!, false),
        ],
      ),
    );
  }
}
