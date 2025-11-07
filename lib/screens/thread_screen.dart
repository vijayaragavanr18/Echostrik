import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../services/firebase_service.dart';
import '../services/ai_service.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ThreadScreen extends StatefulWidget {
  final String? echoId;

  const ThreadScreen({super.key, this.echoId});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> with TickerProviderStateMixin {
  String? echoId;
  Map<String, dynamic>? echoData;
  bool _isRecordingReply = false;
  bool _isPlayingMain = false;
  bool _isLiked = false;
  int _likeCount = 0;
  late AnimationController _playController;

  @override
  void initState() {
    super.initState();
    _playController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _playController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    echoId = ModalRoute.of(context)?.settings.arguments as String?;
    if (echoId != null && echoData == null) {
      _loadEcho();
    }
  }

  void _loadEcho() async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final doc = await firebaseService.getEcho(echoId!).first;
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          echoData = data;
          _likeCount = data['likes'] ?? 0;
          // Check if current user liked this (would need user auth)
          _isLiked = false; // Placeholder - implement with user auth
        });
      } else {
        // Echo doesn't exist, show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This echo no longer exists'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load echo'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _shareEcho() async {
    if (echoData == null) return;

    final mood = echoData!['mood'] ?? 'unknown';
    final prompt = echoData!['prompt'] ?? 'Shared an emotional moment';

    final shareText = '''
🎵 EchoStrik - Emotional Support Through Sound

Someone is feeling $mood and shared: "$prompt"

Join the conversation and offer your support through audio strikes!

Download EchoStrik: [App Link]
#EchoStrik #MentalHealth #Support
    ''';

    try {
      await Share.shareUri(Uri.parse(shareText));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing failed')),
      );
    }
  }

  void _toggleLike() async {
    if (echoData == null || echoId == null) return;

    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      await firebaseService.toggleLike(echoId!, _isLiked);
    } catch (e) {
      // Revert on error
      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update like')),
      );
    }
  }

  void _toggleMainPlayback() async {
    final audioService = Provider.of<AudioService>(context, listen: false);
    if (_isPlayingMain) {
      await audioService.stopPlayback();
      _playController.reverse();
    } else {
      if (echoData?['audioUrl'] != null) {
        await audioService.playRecording(echoData!['audioUrl']);
        _playController.forward();
        HapticFeedback.lightImpact();
      }
    }
    setState(() {
      _isPlayingMain = !_isPlayingMain;
    });
  }

  void _startReplyRecording() async {
    final audioService = Provider.of<AudioService>(context, listen: false);
    await audioService.startRecording();
    setState(() {
      _isRecordingReply = true;
    });
    HapticFeedback.mediumImpact();
  }

  void _stopReplyRecording() async {
    final audioService = Provider.of<AudioService>(context, listen: false);
    final path = await audioService.stopRecording();

    if (path != null && echoId != null) {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);

      final downloadUrl = await firebaseService.uploadAudio(
        path,
        'anonymous',
        'reply',
      );

      if (downloadUrl != null) {
        await firebaseService.addReply(echoId!, 'anonymous', downloadUrl);
        _loadEcho(); // Refresh the thread
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Strike sent successfully!'),
            backgroundColor: Color(0xFF0F3460),
          ),
        );
      }
    }

    setState(() {
      _isRecordingReply = false;
    });
  }

  void _generateAIStrike() async {
    if (echoData == null || echoId == null) return;

    try {
      final aiService = Provider.of<AIService>(context, listen: false);
      final aiReply = await aiService.generateEmpatheticReply(
        userEcho: echoData!['prompt'] ?? 'Shared an emotional moment',
        userMood: echoData!['mood'] ?? 'unknown',
        prompt: echoData!['prompt'] ?? 'Expressing feelings',
      );

      // For now, just show the AI reply as a snackbar
      // TODO: Convert text to speech and save as audio reply
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI Strike: $aiReply'),
          backgroundColor: Colors.purple,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Strike failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getMoodColor(String? mood) {
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text(
            'Echo Thread',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _shareEcho,
              icon: const Icon(Icons.share, color: Colors.white),
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/threads'),
              icon: const Icon(Icons.list, color: Colors.white),
            ),
          ],
        ),
        body: echoData == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0F3460),
                ),
              )
            : Column(
                children: [
                  // Main Echo Card
                  Padding(
                    padding: const EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Anonymous User',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Feeling ${echoData!['mood'] ?? 'unknown'}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getMoodColor(echoData!['mood']).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  (echoData!['mood'] ?? 'UNKNOWN').toUpperCase(),
                                  style: TextStyle(
                                    color: _getMoodColor(echoData!['mood']),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Prompt
                          if (echoData!['prompt'] != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    color: Colors.white.withOpacity(0.6),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      echoData!['prompt'],
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Audio Player & Actions
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    AnimatedBuilder(
                                      animation: _playController,
                                      builder: (context, child) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                _getMoodColor(echoData!['mood']).withOpacity(0.8),
                                                _getMoodColor(echoData!['mood']).withOpacity(0.4),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _getMoodColor(echoData!['mood']).withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            onPressed: _toggleMainPlayback,
                                            icon: AnimatedIcon(
                                              icon: AnimatedIcons.play_pause,
                                              progress: _playController,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Echo Audio',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            _isPlayingMain ? 'Playing...' : 'Tap to play',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.6),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '0:45',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Action Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: _toggleLike,
                                      icon: Icon(
                                        _isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: _isLiked ? Colors.red : Colors.white.withOpacity(0.6),
                                        size: 24,
                                      ),
                                    ),
                                    Text(
                                      '$_likeCount',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      onPressed: _startReplyRecording,
                                      icon: Icon(
                                        Icons.reply,
                                        color: Colors.white.withOpacity(0.6),
                                        size: 24,
                                      ),
                                    ),
                                    Text(
                                      '${echoData!['repliesCount'] ?? 0}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      onPressed: _shareEcho,
                                      icon: Icon(
                                        Icons.share,
                                        color: Colors.white.withOpacity(0.6),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      onPressed: () {
                                        // TODO: Implement more options (report, save, etc.)
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('More options coming soon!')),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.white.withOpacity(0.6),
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Strikes Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Strikes (${echoData!['repliesCount'] ?? 0})',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Strikes List
                  Expanded(
                    child: StreamBuilder(
                      stream: Provider.of<FirebaseService>(context).getStrikes(echoId!),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0F3460),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mic_none,
                                  color: Colors.white.withOpacity(0.3),
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No strikes yet',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to strike back!',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            final strike = snapshot.data.docs[index];
                            final strikeData = strike.data() as Map<String, dynamic>;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.05),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white.withOpacity(0.6),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Anonymous Strike',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${index + 1} hour${index == 0 ? '' : 's'} ago',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      final audioService = Provider.of<AudioService>(context, listen: false);
                                      audioService.playRecording(strikeData['audioUrl']);
                                      HapticFeedback.lightImpact();
                                    },
                                    icon: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Recording UI
                  if (_isRecordingReply)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        border: const Border(
                          top: BorderSide(
                            color: Color(0xFF0F3460),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recording your strike...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Keep sharing your thoughts',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _stopReplyRecording,
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF0F3460),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Strike Back Button
                  if (!_isRecordingReply)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _startReplyRecording,
                            icon: const Icon(Icons.mic, color: Colors.white),
                            label: const Text(
                              'Strike Back',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F3460),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _generateAIStrike,
                            icon: const Icon(Icons.smart_toy, color: Colors.white),
                            label: const Text(
                              'AI Strike',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.withOpacity(0.8),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
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
}
