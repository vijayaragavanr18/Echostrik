/// API Configuration
/// 
/// IMPORTANT: This file contains API keys and should NOT be committed to version control.
/// Add this file to .gitignore before pushing to a repository.
/// 
/// For production, consider using:
/// - Environment variables
/// - Firebase Remote Config
/// - Secure key management services

class ApiConfig {
  // Gemini AI API Key
  // Get your key from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'AIzaSyDXp5ard77px_mFFkBW6A5gJGIzUP37VW4';
  
  // TODO: Move to environment variables or secure storage for production
  // Example: static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
}
