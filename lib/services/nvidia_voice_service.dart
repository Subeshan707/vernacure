/// NVIDIA Voice Service - STT (Parakeet) & TTS (Magpie)
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NvidiaVoiceService {
  // Get your API key from: https://build.nvidia.com/
  static const String apiKey = String.fromEnvironment('NVIDIA_API_KEY', 
      defaultValue: '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');
  
  static const String sttBaseUrl = 'https://ai.api.nvidia.com/v1/audio/transcriptions';
  static const String ttsBaseUrl = 'https://ai.api.nvidia.com/v1/audio/speech';
  
  /// Language code mapping for NVIDIA APIs
  static const Map<String, String> _languageCodes = {
    'en': 'en-US',
    'ta': 'ta-IN',
    'hi': 'hi-IN',
    'te': 'te-IN',
    'kn': 'kn-IN',
    'ml': 'ml-IN',
  };

  /// Convert speech to text using NVIDIA Parakeet ASR
  /// [audioBytes] - Audio file bytes (WAV, MP3, FLAC)
  /// [language] - Language code (en, ta, hi, etc.)
  static Future<Map<String, dynamic>> speechToText({
    required Uint8List audioBytes,
    required String language,
  }) async {
    try {
      debugPrint('🎤 NVIDIA STT: Processing audio (${audioBytes.length} bytes)');
      debugPrint('🎤 Language: $language');
      
      final languageCode = _languageCodes[language] ?? 'en-US';
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(sttBaseUrl),
      );
      
      request.headers['Authorization'] = 'Bearer $apiKey';
      request.fields['language'] = languageCode;
      request.fields['model'] = 'parakeet-ctc-1.1b-asr';
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        audioBytes,
        filename: 'audio.wav',
      ));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      debugPrint('🎤 NVIDIA STT Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final transcription = data['text'] ?? '';
        debugPrint('✅ Transcribed: $transcription');
        
        return {
          'success': true,
          'text': transcription,
          'language': language,
        };
      } else {
        debugPrint('❌ NVIDIA STT Error: $responseBody');
        throw Exception('STT failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ NVIDIA STT Exception: $e');
      rethrow;
    }
  }

  /// Convert text to speech using NVIDIA Magpie TTS
  /// [text] - Text to synthesize
  /// [language] - Language code (en, ta, hi, etc.)
  /// Returns audio bytes (MP3)
  static Future<Uint8List> textToSpeech({
    required String text,
    required String language,
  }) async {
    try {
      debugPrint('🔊 NVIDIA TTS: Synthesizing text');
      debugPrint('🔊 Text: $text');
      debugPrint('🔊 Language: $language');
      
      final languageCode = _languageCodes[language] ?? 'en-US';
      
      final response = await http.post(
        Uri.parse(ttsBaseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'fastpitch-hifigan',
          'text': text,
          'language': languageCode,
          'voice': 'English-US.Female-1', // Default, can be customized
        }),
      );
      
      debugPrint('🔊 NVIDIA TTS Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('✅ Audio synthesized: ${response.bodyBytes.length} bytes');
        return response.bodyBytes;
      } else {
        debugPrint('❌ NVIDIA TTS Error: ${response.body}');
        throw Exception('TTS failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ NVIDIA TTS Exception: $e');
      rethrow;
    }
  }

  /// Voice-to-voice conversation
  /// Records audio → STT → Groq → TTS → Play audio
  static Future<Map<String, dynamic>> processVoiceInput({
    required Uint8List audioBytes,
    required String language,
  }) async {
    try {
      // Step 1: Speech to Text
      final sttResult = await speechToText(
        audioBytes: audioBytes,
        language: language,
      );
      
      final transcription = sttResult['text'] as String;
      
      if (transcription.isEmpty) {
        throw Exception('No speech detected');
      }
      
      return {
        'transcription': transcription,
        'language': sttResult['language'],
      };
    } catch (e) {
      debugPrint('❌ Voice processing error: $e');
      rethrow;
    }
  }
}
