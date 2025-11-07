import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class ThreadsScreen extends StatefulWidget {
  const ThreadsScreen({super.key});

  @override
  State<ThreadsScreen> createState() => _ThreadsScreenState();
}

class _ThreadsScreenState extends State<ThreadsScreen> {
  String selectedMood = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      'Echo Threads',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/record'),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Mood Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildMoodChip('All', selectedMood == 'all'),
                    _buildMoodChip('Lonely', selectedMood == 'lonely'),
                    _buildMoodChip('Calm', selectedMood == 'calm'),
                    _buildMoodChip('Hopeful', selectedMood == 'hopeful'),
                    _buildMoodChip('Anxious', selectedMood == 'anxious'),
                    _buildMoodChip('Grateful', selectedMood == 'grateful'),
                    _buildMoodChip('Confused', selectedMood == 'confused'),
                  ],
                ),
              ),

            // Threads List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Provider.of<FirebaseService>(context).getAllEchoes(),
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
                              'Failed to load threads',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final threads = snapshot.data?.docs ?? [];

                    if (threads.isEmpty) {
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
                              'No threads yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: threads.length,
                      itemBuilder: (context, index) {
                        final threadDoc = threads[index];
                        final threadData = threadDoc.data() as Map<String, dynamic>;
                        return _buildThreadCard(context, threadDoc.id, threadData);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChip(String mood, bool isSelected) {
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
            selectedMood = mood.toLowerCase();
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
  }

  Widget _buildThreadCard(BuildContext context, String threadId, Map<String, dynamic> threadData) {
    final mood = threadData['mood'] ?? 'unknown';
    final prompt = threadData['prompt'] ?? 'Shared an emotional moment';
    final createdAt = threadData['createdAt'] as Timestamp?;
    final likes = threadData['likes'] ?? 0;
    final repliesCount = threadData['repliesCount'] ?? 0;

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
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      Navigator.pushNamed(context, '/thread', arguments: threadId);
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
                      await firebaseService.toggleLike(threadId, true);
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
                    Navigator.pushNamed(context, '/thread', arguments: threadId);
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
