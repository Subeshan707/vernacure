/// Vernacure Configuration Constants
library;

class AppConstants {
  static const String appName = 'Vernacure';
  static const String appTagline = 'Insurance in Your Language';
  
  // API Endpoints
  static const String n8nBaseUrl = 'https://primary-production-53f67.up.railway.app';
  
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
  
  // Pinata IPFS Configuration
  static const String pinataApiKey = '509bf47e8e6add808b32';
  static const String pinataApiSecret = '7a8d823d8c391256bd6ab30ac68d9b761f964bef24323d609de906ee3ce0b0b3';
  static const String pinataJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJjYjdhYzBjMy1lZDI1LTRlNGMtYTNjMy0yMWIzMTA3YTg1NjYiLCJlbWFpbCI6ImplcnJpY2thdXN0aW5tQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6IkZSQTEifSx7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6Ik5ZQzEifV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElWRSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiI1MDliZjQ3ZThlNmFkZDgwOGIzMiIsInNjb3BlZEtleVNlY3JldCI6IjdhOGQ4MjNkOGMzOTEyNTZiZDZhYjMwYWM2OGQ5Yjc2MWY5NjRiZWYyNDMyM2Q2MDlkZTkwNmVlM2NlMGIwYjMiLCJleHAiOjE4MDA3NTc3NTB9.ESLpnzQ5XChUVaAFVfsEB_R9cBTGgGgz4OeOPEHIocE';
  static const String pinataGateway = 'https://gateway.pinata.cloud/ipfs';
  
  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മலയാளം'},
  ];
}
