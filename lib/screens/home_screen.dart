import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/audio_service.dart';
import '../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String selectedMood = 'all';
  late AnimationController _glowController;
  String _dailyPrompt = "Loading...";

  final List<String> moods = ['all', 'lonely', 'calm', 'hopeful', 'anxious', 'grateful', 'confused'];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Load daily prompt
    _loadDailyPrompt();
  }

  void _loadDailyPrompt() async {
    try {
      final prompt = await _getDailyPrompt();
      if (mounted) {
        setState(() {
          _dailyPrompt = prompt;
        });
      }
    } catch (e) {
      // Keep default prompt if loading fails
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<String> _getDailyPrompt() async {
    try {
      final aiService = Provider.of<AIService>(context, listen: false);
      // Generate a random mood for variety
      final moods = ['lonely', 'calm', 'hopeful', 'anxious', 'grateful', 'confused'];
      final randomMood = moods[DateTime.now().day % moods.length];
      return await aiService.generateDailyPrompt(randomMood);
    } catch (e) {
      // Fallback to static prompts if AI fails
      final prompts = [
        "What's been weighing on your heart lately?",
        "What brings you peace in chaotic times?",
        "What gives you hope for tomorrow?",
        "What are you thankful for today?",
        "How do you cope with uncertainty?",
        "Share a moment when you felt truly alone.",
        "Describe your ideal moment of tranquility.",
        "Share something you're looking forward to.",
        "How do you find strength in difficult times?",
        "What small joy made you smile today?"
      ];
      return prompts[DateTime.now().day % prompts.length];
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
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'EchoStrik',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/search'),
                    icon: const Icon(Icons.search, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    icon: const Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Daily AI Prompt Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F3460).withOpacity(
                            0.3 + (_glowController.value * 0.2),
                          ),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F3460),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F3460).withOpacity(
                                      0.5 + (_glowController.value * 0.5),
                                    ),
                                    spreadRadius: 3,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Daily AI Prompt',
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
                          _dailyPrompt,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.mic,
                              color: Colors.white.withOpacity(0.6),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/record'),
                              child: Text(
                                'Tap to record your echo',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Mood Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: moods.map((mood) {
                  final isSelected = selectedMood == mood;
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
                          selectedMood = mood;
                        });
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      selectedColor: const Color(0xFF0F3460),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF0F3460) : Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Today's Echo Threads
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Today's Echoes",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Echo Feed
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedMood == 'all'
                    ? Provider.of<FirebaseService>(context).getAllEchoes()
                    : Provider.of<FirebaseService>(context).getEchoesByMood(selectedMood),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0F3460),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white.withOpacity(0.5),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load echoes',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {});
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final echoes = snapshot.data?.docs ?? [];

                  if (echoes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic_none,
                            color: Colors.white.withOpacity(0.3),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedMood == 'all'
                                ? 'No echoes yet. Be the first to share!'
                                : 'No ${selectedMood} echoes yet.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/record'),
                            icon: const Icon(Icons.mic, color: Colors.white),
                            label: const Text(
                              'Record Your Echo',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F3460),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: echoes.length,
                    itemBuilder: (context, index) {
                      final echoDoc = echoes[index];
                      final echoData = echoDoc.data() as Map<String, dynamic>;
                      return _buildEchoCard(context, echoDoc.id, echoData);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEchoCard(BuildContext context, String echoId, Map<String, dynamic> echoData) {
    final mood = echoData['mood'] ?? 'unknown';
    final prompt = echoData['prompt'] ?? 'Shared an emotional moment';
    final createdAt = echoData['createdAt'] as Timestamp?;
    final likes = echoData['likes'] ?? 0;
    final repliesCount = echoData['repliesCount'] ?? 0;

    // Calculate time ago
    String timeAgo = 'Just now';
    if (createdAt != null) {
      final now = DateTime.now();
      final difference = now.difference(createdAt.toDate());
      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
                      'Anonymous User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getMoodColor(mood).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mood.toUpperCase(),
                  style: TextStyle(
                    color: _getMoodColor(mood),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Prompt text
          if (prompt.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                prompt,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Audio Player
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/thread', arguments: echoId);
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                Text(
                  '0:45', // TODO: Calculate actual duration
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  try {
                    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
                    await firebaseService.toggleLike(echoId, true); // Assuming user liked it
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Liked!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to like')),
                    );
                  }
                },
                icon: Icon(
                  Icons.favorite_border,
                  color: Colors.white.withOpacity(0.6),
                  size: 20,
                ),
              ),
              Text(
                '$likes',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/thread', arguments: echoId);
                },
                icon: Icon(
                  Icons.reply,
                  color: Colors.white.withOpacity(0.6),
                  size: 20,
                ),
              ),
              Text(
                '$repliesCount',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
                  );
                },
                icon: Icon(
                  Icons.share,
                  color: Colors.white.withOpacity(0.6),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'lonely':
        return Colors.blue;
      case 'calm':
        return Colors.green;
      case 'hopeful':
        return Colors.yellow;
      case 'anxious':
        return Colors.orange;
      case 'grateful':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
