import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload audio file to Supabase Storage
  Future<String?> uploadAudio(String filePath, String tempUserId, String type) async {
    try {
      final fileName = '${tempUserId}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final file = File(filePath);

      // Upload to Supabase Storage
      final response = await _supabase.storage
          .from('echoes') // Your Supabase bucket name
          .upload('$type/$fileName', file);

      if (response.isNotEmpty) {
        // Get public URL
        final publicUrl = _supabase.storage
            .from('echoes')
            .getPublicUrl('$type/$fileName');

        return publicUrl;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading to Supabase: $e');
      }
      // Fallback to demo URL for testing
      return 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav';
    }
  }

  // Upload audio bytes (for web)
  Future<String?> uploadAudioBytes(Uint8List bytes, String tempUserId, String type) async {
    try {
      final fileName = '${tempUserId}_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Upload bytes to Supabase Storage
      final response = await _supabase.storage
          .from('echoes')
          .uploadBinary('$type/$fileName', bytes);

      if (response.isNotEmpty) {
        // Get public URL
        final publicUrl = _supabase.storage
            .from('echoes')
            .getPublicUrl('$type/$fileName');

        return publicUrl;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading bytes to Supabase: $e');
      }
      // Fallback to demo URL
      return 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav';
    }
  }

  // Delete audio file
  Future<void> deleteAudio(String fileName) async {
    try {
      await _supabase.storage
          .from('echoes')
          .remove([fileName]);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting from Supabase: $e');
      }
    }
  }

  // Get file metadata
  Future<FileObject?> getFileMetadata(String fileName) async {
    try {
      final response = await _supabase.storage
          .from('echoes')
          .list(path: fileName);

      if (response.isNotEmpty) {
        return response.first;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file metadata: $e');
      }
    }
    return null;
  }

  // Check if file exists
  Future<bool> fileExists(String fileName) async {
    try {
      final metadata = await getFileMetadata(fileName);
      return metadata != null;
    } catch (e) {
      return false;
    }
  }

  // Get storage usage for user (if needed for analytics)
  Future<num?> getUserStorageUsage(String userId) async {
    try {
      final files = await _supabase.storage
          .from('echoes')
          .list();

      num totalSize = 0;
      for (final file in files) {
        if (file.name.startsWith('echo/$userId') || file.name.startsWith('reply/$userId')) {
          totalSize += file.metadata?['size'] ?? 0;
        }
      }

      return totalSize;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting storage usage: $e');
      }
      return null;
    }
  }
}
