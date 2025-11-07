import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/live_audio_service.dart';

class HeartCirclesScreen extends StatefulWidget {
  const HeartCirclesScreen({super.key});

  @override
  State<HeartCirclesScreen> createState() => _HeartCirclesScreenState();
}

class _HeartCirclesScreenState extends State<HeartCirclesScreen> {
  final TextEditingController _circleNameController = TextEditingController();
  String _selectedMood = 'lonely';

  final List<String> _moods = [
    'lonely', 'anxious', 'grateful', 'hopeful', 'confused', 'calm'
  ];

  @override
  void dispose() {
    _circleNameController.dispose();
    super.dispose();
  }

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
                      'Heart Circles',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Create Circle Section
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Circle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Circle Name
                      TextField(
                        controller: _circleNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Circle name (e.g., "Late Night Feelings")',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Mood Selection
                      Text(
                        'Focus Mood',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _moods.map((mood) {
                          final isSelected = _selectedMood == mood;
                          return FilterChip(
                            label: Text(
                              mood.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedMood = mood;
                              });
                            },
                            backgroundColor: Colors.white.withOpacity(0.1),
                            selectedColor: _getMoodColor(mood),
                            checkmarkColor: Colors.white,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Create Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _createCircle,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Create Circle',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F3460),
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
              ),

              const SizedBox(height: 24),

              // Active Circles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Active Circles',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 3, // Demo circles
                        itemBuilder: (context, index) {
                          return _buildCircleCard(context, index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleCard(BuildContext context, int index) {
    final circles = [
      {'name': 'Midnight Thoughts', 'mood': 'lonely', 'participants': 3, 'active': true},
      {'name': 'Anxiety Support', 'mood': 'anxious', 'participants': 5, 'active': true},
      {'name': 'Gratitude Circle', 'mood': 'grateful', 'participants': 2, 'active': false},
    ];

    final circle = circles[index];
    final mood = circle['mood'] as String;
    final participants = circle['participants'] as int;
    final active = circle['active'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? _getMoodColor(mood) : Colors.white.withOpacity(0.1),
          width: active ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        circle['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.white.withOpacity(0.6),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$participants listening',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getMoodColor(mood).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
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
                    ],
                  ),
                ),
                if (active)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: active ? () => _joinCircle(circle['name'] as String) : null,
                icon: Icon(
                  active ? Icons.mic : Icons.lock_clock,
                  color: Colors.white,
                  size: 16,
                ),
                label: Text(
                  active ? 'Join Circle' : 'Starts Soon',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: active ? const Color(0xFF0F3460) : Colors.grey.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createCircle() {
    if (_circleNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a circle name')),
      );
      return;
    }

    // TODO: Implement circle creation with LiveAudioService
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Circle "${_circleNameController.text}" created!')),
    );

    _circleNameController.clear();
  }

  void _joinCircle(String circleName) {
    // TODO: Implement joining circle with LiveAudioService
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joining "$circleName"...')),
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
