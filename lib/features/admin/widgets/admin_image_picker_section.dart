import 'dart:io' show File;

import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/constants/constants.dart';

class AdminImagePickerSection extends StatelessWidget {
  final List<String> existingUrls;
  final List<XFile> newFiles;
  final List<String> deletedUrls;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final ValueChanged<String> onRemoveExisting;
  final ValueChanged<int> onRemoveNew;

  const AdminImagePickerSection({
    super.key,
    required this.existingUrls,
    required this.newFiles,
    required this.deletedUrls,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  @override
  Widget build(BuildContext context) {
    final activeExisting =
        existingUrls.where((url) => !deletedUrls.contains(url)).toList();
    final totalCount = activeExisting.length + newFiles.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '이미지',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '($totalCount)',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (totalCount > 0)
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images (not deleted)
                ...activeExisting.map((url) => _ExistingImageTile(
                      url: url,
                      onRemove: () => onRemoveExisting(url),
                    )),
                // New files
                ...newFiles.asMap().entries.map((entry) => _NewImageTile(
                      file: entry.value,
                      onRemove: () => onRemoveNew(entry.key),
                    )),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onPickFromGallery,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('갤러리'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mathBlue,
                side: const BorderSide(color: AppColors.mathBlue),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onPickFromCamera,
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('카메라'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mathBlue,
                side: const BorderSide(color: AppColors.mathBlue),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExistingImageTile extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;

  const _ExistingImageTile({required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 120,
                color: AppColors.backgroundLight,
                child: const Icon(Icons.broken_image, color: AppColors.textTertiary),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.mathRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewImageTile extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _NewImageTile({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb
                ? FutureBuilder<Uint8List>(
                    future: file.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        );
                      }
                      return const SizedBox(
                        width: 120,
                        height: 120,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                  )
                : Image.file(
                    File(file.path),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.mathGreen,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.mathRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
