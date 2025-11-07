import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _anonymousName;
  Map<String, dynamic>? _userProfile;

  User? get user => _user;
  String? get anonymousId => _user?.uid;
  String? get anonymousName => _anonymousName;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isSignedIn => _user != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserProfile();
    } else {
      _anonymousName = null;
      _userProfile = null;
    }
    notifyListeners();
  }

  Future<void> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      _user = userCredential.user;
      await _ensureUserProfile();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Anonymous sign in failed: $e');
      }
      rethrow;
    }
  }

  Future<void> _ensureUserProfile() async {
    if (_user == null) return;

    final userDoc = await _firestore.collection('users').doc(_user!.uid).get();

    if (!userDoc.exists) {
      // Create new anonymous user profile
      _anonymousName = _generateAnonymousName();
      _userProfile = {
        'anonymousName': _anonymousName,
        'createdAt': FieldValue.serverTimestamp(),
        'moodStats': {
          'lonely': 0,
          'calm': 0,
          'hopeful': 0,
          'anxious': 0,
          'grateful': 0,
          'confused': 0,
        },
        'totalEchoes': 0,
        'totalStrikes': 0,
        'daysActive': 1,
        'lastActive': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(_user!.uid).set(_userProfile!);
    } else {
      // Load existing profile
      _userProfile = userDoc.data();
      _anonymousName = _userProfile?['anonymousName'];
    }
  }

  String _generateAnonymousName() {
    final random = Random();
    final adjectives = ["Calm", "Gentle", "Silent", "Brave", "Kind", "Dreaming", "Quiet", "Wise", "Free", "Light"];
    final nouns = ["Echo", "Wave", "Soul", "Light", "Shadow", "Star", "Wind", "Dream", "Heart", "Spirit"];

    final adjective = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];
    final number = random.nextInt(999) + 1;

    return "${adjective}${noun}_$number";
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        _userProfile = userDoc.data();
        _anonymousName = _userProfile?['anonymousName'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load user profile: $e');
      }
    }
  }

  Future<void> updateMoodStats(String mood) async {
    if (_user == null || _userProfile == null) return;

    try {
      final currentStats = Map<String, dynamic>.from(_userProfile!['moodStats'] ?? {});
      currentStats[mood] = (currentStats[mood] ?? 0) + 1;

      await _firestore.collection('users').doc(_user!.uid).update({
        'moodStats': currentStats,
        'lastActive': FieldValue.serverTimestamp(),
      });

      _userProfile!['moodStats'] = currentStats;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update mood stats: $e');
      }
    }
  }

  Future<void> incrementEchoCount() async {
    if (_user == null) return;

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'totalEchoes': FieldValue.increment(1),
        'lastActive': FieldValue.serverTimestamp(),
      });

      if (_userProfile != null) {
        _userProfile!['totalEchoes'] = (_userProfile!['totalEchoes'] ?? 0) + 1;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to increment echo count: $e');
      }
    }
  }

  Future<void> incrementStrikeCount() async {
    if (_user == null) return;

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'totalStrikes': FieldValue.increment(1),
        'lastActive': FieldValue.serverTimestamp(),
      });

      if (_userProfile != null) {
        _userProfile!['totalStrikes'] = (_userProfile!['totalStrikes'] ?? 0) + 1;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to increment strike count: $e');
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _anonymousName = null;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out failed: $e');
      }
      rethrow;
    }
  }

  // Get most used mood for AI personalization
  String getMostUsedMood() {
    if (_userProfile == null) return 'lonely';

    final moodStats = _userProfile!['moodStats'] as Map<String, dynamic>? ?? {};
    String mostUsed = 'lonely';
    int maxCount = 0;

    moodStats.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsed = mood;
      }
    });

    return mostUsed;
  }
}
