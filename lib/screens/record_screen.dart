import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'package:flutter/services.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> with TickerProviderStateMixin {
  bool _isRecording = false;
  String _selectedMood = 'lonely';
  String? _prompt;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  final List<String> _moods = ['lonely', 'calm', 'hopeful', 'anxious', 'grateful', 'confused'];

  @override
  void initState() {
    super.initState();
    _generatePrompt();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _generatePrompt() {
    final prompts = {
      'lonely': 'Share a moment when you felt truly alone.',
      'calm': 'Describe your ideal moment of tranquility.',
      'hopeful': 'What gives you hope for tomorrow?',
      'anxious': 'How do you cope with uncertainty?',
      'grateful': 'What are you thankful for today?',
      'confused': 'What small joy made you smile today?'
    };
    setState(() {
      _prompt = prompts[_selectedMood];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0F23),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Record Your Echo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/threads'),
                    icon: const Icon(Icons.list, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Mood selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _moods.map((mood) {
                        final isSelected = _selectedMood == mood;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              mood.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedMood = mood;
                                _generatePrompt();
                              });
                              HapticFeedback.lightImpact();
                            },
                            backgroundColor: Colors.white.withOpacity(0.1),
                            selectedColor: _getMoodColor(mood),
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? _getMoodColor(mood) : Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Prompt display
            if (_prompt != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Colors.white.withOpacity(0.6),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Prompt',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _prompt!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Recording UI
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Recording Animation
                      AnimatedBuilder(
                        animation: Listenable.merge([_pulseController, _waveController]),
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer wave rings
                              if (_isRecording) ...[
                                for (int i = 0; i < 3; i++)
                                  Container(
                                    width: 120 + (i * 40) + (_waveController.value * 20),
                                    height: 120 + (i * 40) + (_waveController.value * 20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _getMoodColor(_selectedMood).withOpacity(
                                          (1 - _waveController.value) * 0.3,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                              ],

                              // Main recording button
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    width: 120 + (_pulseController.value * 20),
                                    height: 120 + (_pulseController.value * 20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          _getMoodColor(_selectedMood).withOpacity(0.8),
                                          _getMoodColor(_selectedMood).withOpacity(0.4),
                                        ],
                                      ),
                                      boxShadow: _isRecording ? [
                                        BoxShadow(
                                          color: _getMoodColor(_selectedMood).withOpacity(0.6),
                                          spreadRadius: 10 + (_pulseController.value * 5),
                                          blurRadius: 20 + (_pulseController.value * 10),
                                        ),
                                      ] : null,
                                    ),
                                    child: IconButton(
                                      onPressed: _toggleRecording,
                                      icon: Icon(
                                        _isRecording ? Icons.stop : Icons.mic,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      Text(
                        _isRecording ? 'Recording your echo...' : 'Tap the mic to start recording',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (_isRecording) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Keep sharing your thoughts...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Bottom actions
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleRecording,
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text(
                          'Send Echo',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getMoodColor(_selectedMood),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleRecording() async {
    final audioService = Provider.of<AudioService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    if (_isRecording) {
      // Stop recording
      final path = await audioService.stopRecording();
      if (path != null) {
        // Upload to Firebase Storage
        final firebaseService = Provider.of<FirebaseService>(context, listen: false);
        final audioUrl = await firebaseService.uploadAudio(path, authService.anonymousId ?? 'anonymous', 'echo');
        if (audioUrl != null) {
          // Save echo to Firestore
          final echoId = await firebaseService.saveEcho(authService.anonymousId ?? 'anonymous', audioUrl, _selectedMood, _prompt);
          if (echoId != null) {
            // Update user stats
            await authService.updateMoodStats(_selectedMood);
            await authService.incrementEchoCount();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Echo uploaded successfully!'),
                backgroundColor: _getMoodColor(_selectedMood),
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save echo'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload audio'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Start recording
      await audioService.startRecording();
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _isRecording = !_isRecording;
    });
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'lonely':
        return Colors.blue;
      case 'calm':
        return Colors.green;
      case 'hopeful':
        return Colors.yellow.shade600;
      case 'anxious':
        return Colors.orange;
      case 'grateful':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
