import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class AIService {
  late GenerativeModel _model;

  AIService() {
    // Gemini 1.5 Flash API Key from config
    const apiKey = ApiConfig.geminiApiKey;

    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Changed back to flash for availability
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }

  /// Generate an empathetic AI reply (strike) to an echo
  Future<String> generateEmpatheticReply({
    required String userEcho,
    required String userMood,
    required String prompt,
  }) async {
    try {
      final promptText = '''
You are an empathetic AI companion helping people process their emotions through voice messages.

The user shared: "$userEcho"
They are feeling: $userMood
The original prompt was: "$prompt"

Generate a short, empathetic response (2-3 sentences) that:
- Acknowledges their feelings
- Shows understanding and compassion
- Offers gentle support or perspective
- Keep it conversational and natural, like a caring friend

Response should be suitable for voice-to-voice conversation.
''';

      final response = await _model.generateContent([Content.text(promptText)]);
      return response.text?.trim() ?? 'I hear you, and I\'m here to listen.';
    } catch (e) {
      if (kDebugMode) {
        print('AI Reply generation failed: $e');
      }
      return 'I hear you, and I\'m here to listen.';
    }
  }

  /// Generate daily AI prompts for emotional expression
  Future<String> generateDailyPrompt(String mood) async {
    try {
      final promptText = '''
Generate a thoughtful, open-ended question that encourages emotional expression for someone feeling $mood.

The question should:
- Be gentle and non-judgmental
- Encourage reflection and sharing
- Be suitable for voice recording
- Help process emotions constructively

Examples:
- For lonely: "What's been weighing on your heart lately?"
- For anxious: "What brings you peace in chaotic times?"
- For grateful: "What small joy made you smile today?"

Generate one question for the mood: $mood
''';

      final response = await _model.generateContent([Content.text(promptText)]);
      return response.text?.trim() ?? 'How are you feeling right now?';
    } catch (e) {
      if (kDebugMode) {
        print('Daily prompt generation failed: $e');
      }
      return 'How are you feeling right now?';
    }
  }

  /// Generate weekly mood summary insights
  Future<String> generateMoodSummary(List<Map<String, dynamic>> weeklyEchoes) async {
    try {
      final moods = weeklyEchoes.map((e) => e['mood']).toList();
      final moodCount = <String, int>{};

      for (var mood in moods) {
        moodCount[mood] = (moodCount[mood] ?? 0) + 1;
      }

      final summaryText = '''
Based on this week's echoes, here are the dominant emotions:
${moodCount.entries.map((e) => '${e.key}: ${e.value} times').join(', ')}

Generate a compassionate, insightful summary (3-4 sentences) that:
- Acknowledges the emotional journey
- Highlights patterns or growth
- Offers gentle encouragement
- Focuses on emotional awareness and self-compassion

Keep it supportive and non-clinical.
''';

      final response = await _model.generateContent([Content.text(summaryText)]);
      return response.text?.trim() ?? 'This week shows your emotional awareness and courage in sharing your feelings.';
    } catch (e) {
      if (kDebugMode) {
        print('Mood summary generation failed: $e');
      }
      return 'This week shows your emotional awareness and courage in sharing your feelings.';
    }
  }

  /// Generate personalized mood tips
  Future<String> generateMoodTip(String currentMood) async {
    try {
      final promptText = '''
Someone is feeling $currentMood. Generate a short, practical tip (1-2 sentences) that:

- Is actionable and realistic
- Promotes emotional well-being
- Is compassionate and supportive
- Can be implemented immediately

Example for anxious: "Try taking three slow, deep breaths, focusing on the sensation of air filling your lungs."

Generate one tip for feeling $currentMood:
''';

      final response = await _model.generateContent([Content.text(promptText)]);
      return response.text?.trim() ?? 'Take a moment to breathe deeply and acknowledge your feelings.';
    } catch (e) {
      if (kDebugMode) {
        print('Mood tip generation failed: $e');
      }
      return 'Take a moment to breathe deeply and acknowledge your feelings.';
    }
  }
}
