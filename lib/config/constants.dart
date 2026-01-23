/// Vernacure Configuration Constants
library;

class AppConstants {
  static const String appName = 'Vernacure';
  static const String appTagline = 'Insurance in Your Language';
  
  // API Endpoints
  static const String n8nBaseUrl = 'https://primary-production-7dbb.up.railway.app';
  
  // Unified endpoint (recommended)
  static const String unifiedWebhook = '$n8nBaseUrl/webhook/vernacure-ai';
  
  // Legacy endpoints (for backward compatibility)
  static const String voiceWebhook = '$n8nBaseUrl/webhook/voice-process';
  static const String comparisonWebhook = '$n8nBaseUrl/webhook/policy-compare';
  static const String ragChatbotWebhook = '$n8nBaseUrl/webhook/rag-chat';
  static const String agentAssistWebhook = '$n8nBaseUrl/webhook/agent-assist';
  
  // Groq API (for direct calls if needed)
  // Get your API key from https://console.groq.com
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: 'YOUR_GROQ_API_KEY');
  
  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
  ];
}
