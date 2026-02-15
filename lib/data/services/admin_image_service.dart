import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/app_logger.dart';

/// Generic admin image service for uploading/deleting images to any Storage path
class AdminImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  static const _uuid = Uuid();

  /// Pick an image from gallery or camera
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      AppLogger.error('Failed to pick image', tag: 'AdminImageService', error: e);
      return null;
    }
  }

  /// Upload an image to a given storage path
  /// [storagePath] e.g. 'achievements/achievementId'
  /// Returns the download URL
  Future<String> uploadImage(String storagePath, File file) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child(storagePath).child(fileName);

    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final url = await ref.getDownloadURL();
    AppLogger.info('Image uploaded: $url', tag: 'AdminImageService');
    return url;
  }

  /// Delete a single image by its download URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      AppLogger.info('Image deleted: $imageUrl', tag: 'AdminImageService');
    } catch (e) {
      AppLogger.error('Failed to delete image', tag: 'AdminImageService', error: e);
    }
  }

  /// Delete all images under a given storage path
  Future<void> deleteAllImages(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final result = await ref.listAll();
      for (final item in result.items) {
        await item.delete();
      }
      AppLogger.info(
        'All images deleted at $storagePath (${result.items.length} files)',
        tag: 'AdminImageService',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to delete all images at $storagePath',
        tag: 'AdminImageService',
        error: e,
      );
    }
  }
}
