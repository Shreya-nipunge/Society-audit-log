import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadDocument({
    required File file,
    required String fileName,
  }) async {
    try {
      final ext = p.extension(fileName);
      final String safeFileName = '${DateTime.now().millisecondsSinceEpoch}_${fileName.replaceAll(' ', '_')}';
      
      final ref = _storage.ref().child('society_documents/$safeFileName');
      
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: _getContentType(ext)),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('CloudStorage: Error uploading file: $e');
      return null;
    }
  }

  String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
} // Will write implementation here
