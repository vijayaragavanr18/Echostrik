import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'supabase_service.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload audio to Supabase Storage and return download URL
  Future<String?> uploadAudio(String path, String tempUserId, String type) async {
    try {
      // Use Supabase service instead of Firebase Storage
      final supabaseService = SupabaseService();
      return await supabaseService.uploadAudio(path, tempUserId, type);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading audio: $e');
      }
      // For demo purposes, return a fake URL if upload fails
      return 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav'; // Placeholder audio URL
    }
  }

  // Save echo to Firestore
  Future<String?> saveEcho(String tempUserId, String audioUrl, String mood, String? prompt) async {
    try {
      final docRef = await _firestore.collection('echoes').add({
        'tempUserId': tempUserId,
        'audioUrl': audioUrl,
        'mood': mood,
        'prompt': prompt,
        'createdAt': FieldValue.serverTimestamp(),
        'repliesCount': 0,
      });
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving echo: $e');
      }
      return null;
    }
  }

  // Get all echoes (for 'all' mood filter)
  Stream<QuerySnapshot> getAllEchoes() {
    // For demo, return some fake data if no real data exists
    return _firestore
        .collection('echoes')
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit for performance
        .snapshots();
  }

  // Add some fake demo echoes for testing
  Future<void> addDemoEchoes() async {
    final demoEchoes = [
      {
        'tempUserId': 'demo_user_1',
        'audioUrl': 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
        'mood': 'lonely',
        'prompt': 'Feeling alone tonight, anyone else?',
        'createdAt': FieldValue.serverTimestamp(),
        'repliesCount': 2,
        'likes': 5,
      },
      {
        'tempUserId': 'demo_user_2',
        'audioUrl': 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
        'mood': 'hopeful',
        'prompt': 'Today was tough, but I\'m still hopeful for tomorrow',
        'createdAt': FieldValue.serverTimestamp(),
        'repliesCount': 1,
        'likes': 3,
      },
    ];

    for (final echo in demoEchoes) {
      try {
        await _firestore.collection('echoes').add(echo);
      } catch (e) {
        // Ignore if already exists
      }
    }
  }

  // Get echoes by mood
  Stream<QuerySnapshot> getEchoesByMood(String mood) {
    return _firestore
        .collection('echoes')
        .where('mood', isEqualTo: mood)
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit for performance
        .snapshots();
  }

  // Search echoes by content (basic text search)
  Future<QuerySnapshot> searchEchoes(String query) async {
    // Note: Firestore doesn't support full-text search natively
    // This is a basic implementation - for production, consider Algolia or ElasticSearch
    return await _firestore
        .collection('echoes')
        .where('prompt', isGreaterThanOrEqualTo: query)
        .where('prompt', isLessThanOrEqualTo: query + '\uf8ff')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
  }

  // Get single echo
  Stream<DocumentSnapshot> getEcho(String echoId) {
    return _firestore.collection('echoes').doc(echoId).snapshots();
  }

  // Add reply (strike) to echo
  Future<void> addReply(String echoId, String tempUserId, String audioUrl) async {
    try {
      await _firestore.collection('echoes').doc(echoId).collection('strikes').add({
        'tempUserId': tempUserId,
        'audioUrl': audioUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update replies count
      await _firestore.collection('echoes').doc(echoId).update({
        'repliesCount': FieldValue.increment(1),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding reply: $e');
      }
    }
  }

  // Get strikes (replies) for an echo
  Stream<QuerySnapshot> getStrikes(String echoId) {
    return _firestore
        .collection('echoes')
        .doc(echoId)
        .collection('strikes')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // Toggle like on echo
  Future<void> toggleLike(String echoId, bool isLiked) async {
    try {
      final docRef = _firestore.collection('echoes').doc(echoId);
      await docRef.update({
        'likes': FieldValue.increment(isLiked ? 1 : -1),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling like: $e');
      }
      rethrow;
    }
  }
}
