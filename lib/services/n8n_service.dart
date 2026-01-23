/// N8n Webhook Service
/// Handles all HTTP requests to n8n workflows deployed on Railway
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:vernacure/config/constants.dart';

class N8nService {
  static bool _initialized = false;
  
  /// Initialize the service and print connection info
  static void _ensureInitialized() {
    if (!_initialized) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🚀 N8N Service Initialized');
      debugPrint('📡 Base URL: ${AppConstants.n8nBaseUrl}');
      debugPrint('🔗 Voice Webhook: ${AppConstants.voiceWebhook}');
      debugPrint('🔗 Comparison Webhook: ${AppConstants.comparisonWebhook}');
      debugPrint('🔗 RAG Chatbot Webhook: ${AppConstants.ragChatbotWebhook}');
      debugPrint('🔗 Agent Assist Webhook: ${AppConstants.agentAssistWebhook}');
      debugPrint('═══════════════════════════════════════════════════════════');
      _initialized = true;
    }
  }
  
  /// Helper to strip markdown code blocks from AI responses
  /// Removes ```json ... ``` or ``` ... ``` wrappers
  static String _stripMarkdownCodeBlocks(String content) {
    String stripped = content.trim();
    
    // Remove ```json or ```JSON at the start
    if (stripped.startsWith('```json')) {
      stripped = stripped.substring(7);
    } else if (stripped.startsWith('```JSON')) {
      stripped = stripped.substring(7);
    } else if (stripped.startsWith('```')) {
      stripped = stripped.substring(3);
    }
    
    // Remove ``` at the end
    if (stripped.endsWith('```')) {
      stripped = stripped.substring(0, stripped.length - 3);
    }
    
    return stripped.trim();
  }
  
  /// Compare insurance policies using n8n AI workflow
  /// Returns recommended policy index and AI explanation
  static Future<Map<String, dynamic>> comparePolicies({
    required List<Map<String, dynamic>> policies,
    required String language,
  }) async {
    _ensureInitialized();
    try {
      final url = AppConstants.unifiedWebhook;
      debugPrint('🔵 N8N: Calling unified webhook (action: compare)');
      debugPrint('🔵 URL: $url');
      debugPrint('🔵 Policies count: ${policies.length}');
      debugPrint('🔵 Language: $language');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'compare',
          'policies': policies,
          'language': language,
        }),
      );

      debugPrint('🔵 Response status: ${response.statusCode}');
      debugPrint('🔵 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ N8N: Policy comparison successful');
        // Helper to extract content
        String content = '';
        if (data['recommendation'] != null) {
          content = data['recommendation'];
        } else if (data['choices'] != null && (data['choices'] as List).isNotEmpty) {
          content = data['choices'][0]['message']['content'];
        }

        // Strip markdown code blocks if present (```json ... ```)
        content = _stripMarkdownCodeBlocks(content);

        // Try to parse the content as JSON if it looks like JSON
        try {
          final contentJson = jsonDecode(content);
          return {
            'recommendedIndex': contentJson['recommended_index'] ?? 0,
            'explanation': contentJson['explanation'] ?? content,
            'scores': contentJson['scores'],
          };
        } catch (e) {
          debugPrint('⚠️ N8N: Could not parse JSON, returning raw content: $e');
          // If not JSON, return as plain text explanation
          return {
            'recommendedIndex': 0,
            'explanation': content.isEmpty ? 'AI analysis complete' : content,
          };
        }
      } else {
        debugPrint('❌ N8N: Server returned ${response.statusCode}');
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ N8N: Policy comparison error: $e');
      rethrow;
    }
  }

  /// Send message to RAG chatbot workflow
  /// Returns AI response and optional sources
  static Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    required String language,
  }) async {
    _ensureInitialized();
    try {
      final url = AppConstants.unifiedWebhook;
      debugPrint('🟢 N8N: Calling unified webhook (action: chat)');
      debugPrint('🟢 URL: $url');
      debugPrint('🟢 Message: $message');
      debugPrint('🟢 Language: $language');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'chat',
          'query': message,
          'language': language,
        }),
      );

      debugPrint('🟢 Response status: ${response.statusCode}');
      debugPrint('🟢 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ N8N: Chat message successful');
        // Try to parse different response formats
        String responseText;
        if (data['response'] != null) {
          responseText = data['response'];
        } else if (data['answer'] != null) {
          responseText = data['answer'];
        } else if (data['choices'] != null && (data['choices'] as List).isNotEmpty) {
          // Handle raw Groq/OpenAI format
          responseText = data['choices'][0]['message']['content'] ?? 'No content in response';
        } else {
          responseText = 'I received your message but could not parse the response.';
        }

        debugPrint('✅ N8N: Chat message successful');
        return {
          'response': responseText,
          'sources': data['sources'], // Sources might be null in raw mode
        };
      } else {
        debugPrint('❌ N8N: Server returned ${response.statusCode}');
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ N8N: Chat message error: $e');
      rethrow;
    }
  }
  /// Process voice input using n8n workflow
  /// Returns transcription and AI response
  static Future<Map<String, dynamic>> processVoice({
    required String audioData,
    required String language,
  }) async {
    _ensureInitialized();
    try {
      final url = AppConstants.unifiedWebhook;
      debugPrint('🟡 N8N: Calling unified webhook (action: voice)');
      debugPrint('🟡 URL: $url');
      debugPrint('🟡 Audio data length: ${audioData.length}');
      debugPrint('🟡 Language: $language');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'voice',
          'query': audioData,
          'language': language,
        }),
      );

      debugPrint('🟡 Response status: ${response.statusCode}');
      debugPrint('🟡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ N8N: Voice processing successful');
        String responseText = '';
        if (data['response'] != null) {
          responseText = data['response'];
        } else if (data['recommendation'] != null) {
          // Parse recommendation for voice response
          String content = data['recommendation'];
          content = _stripMarkdownCodeBlocks(content);
          try {
            final contentJson = jsonDecode(content);
            responseText = contentJson['explanation'] ?? content;
          } catch (e) {
            responseText = content;
          }
        } else if (data['choices'] != null && (data['choices'] as List).isNotEmpty) {
          responseText = data['choices'][0]['message']['content'];
        }
        
        // Ensure we don't return empty response
        if (responseText.isEmpty) {
          responseText = 'I processed your request but received no text response.';
        }

        return {
          'transcription': data['transcription'] ?? '', 
          'response': responseText,
          'detected_language': data['detected_language'] ?? language,
          'intent': data['intent'] ?? 'general',
        };
      } else {
        debugPrint('❌ N8N: Server returned ${response.statusCode}');
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ N8N: Voice processing error: $e');
      rethrow;
    }
  }
  
  /// Generic agent assist for any query
  static Future<Map<String, dynamic>> agentAssist({
    required String query,
    required String language,
    Map<String, dynamic>? context,
  }) async {
    _ensureInitialized();
    try {
      debugPrint('🟣 N8N: Calling agent assist webhook');
      final response = await http.post(
        Uri.parse(AppConstants.agentAssistWebhook),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'language': language,
          'context': context,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Agent assist error: $e');
      rethrow;
    }
  }
}
