// Achievement icon image section — preview with delete + pick buttons.
import 'dart:io' show File;

import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/constants/constants.dart';

class AchievementIconImageSection extends StatelessWidget {
  final String? existingIconUrl;
  final XFile? newIconFile;
  final bool iconDeleted;
  final VoidCallback onRemove;
  final ValueChanged<ImageSource> onPickImage;

  const AchievementIconImageSection({
    super.key,
    required this.existingIconUrl,
    required this.newIconFile,
    required this.iconDeleted,
    required this.onRemove,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasExisting = existingIconUrl != null && !iconDeleted;
    final hasNewFile = newIconFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasExisting || hasNewFile)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacing8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  child: hasNewFile
                      ? (kIsWeb
                          ? FutureBuilder<Uint8List>(
                              future: newIconFile!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return const SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                );
                              },
                            )
                          : Image.file(
                              File(newIconFile!.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ))
                      : Image.network(
                          existingIconUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: AppColors.backgroundLight,
                            child: const Icon(Icons.broken_image,
                                color: AppColors.textTertiary),
                          ),
                        ),
                ),
                if (hasNewFile)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: AppDimensions.spacing2),
                      decoration: BoxDecoration(
                        color: AppColors.mathGreen,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radius4),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.spacing4),
                      decoration: const BoxDecoration(
                        color: AppColors.mathRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => onPickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('갤러리'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mathBlue,
                side: const BorderSide(color: AppColors.mathBlue),
              ),
            ),
            const SizedBox(width: AppDimensions.spacing8),
            OutlinedButton.icon(
              onPressed: () => onPickImage(ImageSource.camera),
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
