import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/app_logger.dart';

class ProblemImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  static const _uuid = Uuid();

  /// Pick an image from gallery or camera
  /// Returns XFile for cross-platform compatibility (works on web and mobile)
  Future<XFile?> pickXFile({ImageSource source = ImageSource.gallery}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      return pickedFile;
    } catch (e) {
      AppLogger.error('Failed to pick image', tag: 'ProblemImageService', error: e);
      return null;
    }
  }

  /// Pick an image and return as dart:io File (mobile only, returns null on web)
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    if (kIsWeb) return null;
    final xFile = await pickXFile(source: source);
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Upload an image to Firebase Storage (cross-platform via XFile)
  Future<String> uploadXFile(String problemId, XFile xFile) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('problems').child(problemId).child(fileName);

    if (kIsWeb) {
      final bytes = await xFile.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      await ref.putFile(
        File(xFile.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );
    }

    final url = await ref.getDownloadURL();
    AppLogger.info('Image uploaded: $url', tag: 'ProblemImageService');
    return url;
  }

  /// Upload an image to Firebase Storage (mobile only - uses dart:io File)
  /// Returns the download URL
  Future<String> uploadImage(String problemId, File file) async {
    if (kIsWeb) {
      throw UnsupportedError('uploadImage with dart:io File is not supported on web. Use uploadXFile instead.');
    }
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('problems').child(problemId).child(fileName);

    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final url = await ref.getDownloadURL();
    AppLogger.info('Image uploaded: $url', tag: 'ProblemImageService');
    return url;
  }

  /// Delete a single image by its download URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      AppLogger.info('Image deleted: $imageUrl', tag: 'ProblemImageService');
    } catch (e) {
      AppLogger.error('Failed to delete image', tag: 'ProblemImageService', error: e);
    }
  }

  /// Delete all images for a problem
  Future<void> deleteAllImages(String problemId) async {
    try {
      final ref = _storage.ref().child('problems').child(problemId);
      final result = await ref.listAll();
      for (final item in result.items) {
        await item.delete();
      }
      AppLogger.info(
        'All images deleted for problem $problemId (${result.items.length} files)',
        tag: 'ProblemImageService',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to delete all images for problem $problemId',
        tag: 'ProblemImageService',
        error: e,
      );
    }
  }
}
