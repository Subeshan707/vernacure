/// Voice Chat Screen - Multilingual Voice Interaction with TTS/STT
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vernacure/config/theme.dart';
import 'package:vernacure/config/constants.dart';
import 'package:vernacure/services/n8n_service.dart';

class VoiceChatScreen extends StatefulWidget {
  final String language;

  const VoiceChatScreen({super.key, required this.language});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  String _transcribedText = '';
  String _currentLanguage = 'en';
  String _lastDetectedLanguage = 'en';
  bool _languageDetected = false; // Track if language was detected in session
  late AnimationController _pulseController;
  
  // Speech-to-Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  
  // Text-to-Speech
  final FlutterTts _tts = FlutterTts();
  
  final List<Map<String, dynamic>> _conversation = [];

  // Language code mapping for STT/TTS
  static const Map<String, String> _sttLocales = {
    'en': 'en_IN',
    'ta': 'ta_IN',
    'hi': 'hi_IN',
    'te': 'te_IN',
    'kn': 'kn_IN',
    'ml': 'ml_IN',
  };

  // TTS locale codes (may differ from STT)
  static const Map<String, String> _ttsLocales = {
    'en': 'en-IN',
    'ta': 'ta-IN',
    'hi': 'hi-IN',
    'te': 'te-IN',
    'kn': 'kn-IN',
    'ml': 'ml-IN',
  };

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    debugPrint('🎤 [VoiceChatScreen] initState - Language: $_currentLanguage');
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _initSpeech();
    _initTTS();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) => debugPrint('🎤 STT Status: $status'),
        onError: (error) => debugPrint('🎤 STT Error: $error'),
      );
      debugPrint('🎤 Speech available: $_speechAvailable');
      
      // List available locales for debugging
      if (_speechAvailable) {
        final locales = await _speech.locales();
        debugPrint('🎤 Available locales: ${locales.map((l) => l.localeId).join(', ')}');
      }
    } catch (e) {
      debugPrint('🎤 Speech init error: $e');
      _speechAvailable = false;
    }
  }

  Future<void> _initTTS() async {
    try {
      // Configure TTS for current language
      await _setTTSLanguage(_currentLanguage);
      
      // Increased speed for better user experience (0.5 -> 0.65)
      await _tts.setSpeechRate(0.65);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      
      _tts.setStartHandler(() {
        setState(() => _isSpeaking = true);
      });
      
      _tts.setCompletionHandler(() {
        setState(() => _isSpeaking = false);
      });
      
      _tts.setErrorHandler((msg) {
        debugPrint('🔊 TTS Error: $msg');
        setState(() => _isSpeaking = false);
      });
      
      // Log available languages for debugging
      final languages = await _tts.getLanguages;
      debugPrint('🔊 Available TTS languages: $languages');
      debugPrint('🔊 TTS initialized for language: $_currentLanguage');
    } catch (e) {
      debugPrint('🔊 TTS init error: $e');
    }
  }

  /// Set TTS language with fallback handling
  Future<void> _setTTSLanguage(String langCode) async {
    final ttsLocale = _ttsLocales[langCode] ?? 'en-IN';
    
    try {
      // Check available languages first
      final availableLanguages = await _tts.getLanguages as List<dynamic>?;
      final availableList = availableLanguages?.map((e) => e.toString().toLowerCase()).toList() ?? [];
      
      debugPrint('🔊 Checking for: $ttsLocale in available: ${availableList.take(10)}...');
      
      // Try the specific locale first
      if (availableList.any((l) => l.contains(ttsLocale.toLowerCase()) || l.contains(langCode))) {
        final result = await _tts.setLanguage(ttsLocale);
        if (result == 1) {
          debugPrint('🔊 TTS language set to: $ttsLocale');
          return;
        }
      }
      
      // For web: Check if we have Indian English at least
      final hasEnglish = availableList.any((l) => l.contains('en'));
      if (hasEnglish) {
        // Try en-IN first, then en-US
        var result = await _tts.setLanguage('en-IN');
        if (result != 1) {
          result = await _tts.setLanguage('en-US');
        }
        if (result == 1) {
          debugPrint('🔊 TTS using English voice (Indian lang not available on web)');
          return;
        }
      }
      
      // Last resort: use whatever is available
      if (availableList.isNotEmpty) {
        final firstAvailable = availableLanguages!.first.toString();
        await _tts.setLanguage(firstAvailable);
        debugPrint('🔊 TTS using first available: $firstAvailable');
        return;
      }
      
      debugPrint('🔊 No TTS voices available!');
    } catch (e) {
      debugPrint('🔊 TTS setLanguage error: $e');
      try {
        await _tts.setLanguage('en-US');
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  String get _languageName {
    final lang = AppConstants.supportedLanguages.firstWhere(
      (l) => l['code'] == _currentLanguage,
      orElse: () => {'name': 'English', 'native': 'English'},
    );
    return lang['native']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildConversation()),
            _buildVoiceControl(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voice Assistant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      _languageDetected ? Icons.check_circle : Icons.auto_awesome,
                      size: 14,
                      color: _languageDetected ? AppTheme.successGreen : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _languageDetected 
                          ? 'Speaking in $_languageName'
                          : 'Auto-detecting language...',
                      style: TextStyle(
                        fontSize: 13,
                        color: _languageDetected ? AppTheme.successGreen : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Speaking indicator
          if (_isSpeaking)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.volume_up_rounded, color: AppTheme.accentGold, size: 20),
            ).animate(onPlay: (c) => c.repeat()).fadeIn().then().fadeOut(),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0);
  }

  Widget _buildConversation() {
    if (_conversation.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _conversation.length,
      itemBuilder: (context, index) {
        final message = _conversation[index];
        final isUser = message['role'] == 'user';
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMessageBubble(
            text: message['text'],
            isUser: isUser,
            intent: message['intent'],
            language: message['detected_language'],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.record_voice_over_rounded,
              size: 64,
              color: AppTheme.primaryBlue.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _speechAvailable 
                ? 'Tap the microphone to start'
                : 'Voice not available on this device',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask about insurance in $_languageName',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 32),
          // Example prompts
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildExampleChip('Family insurance options'),
              _buildExampleChip('Compare term plans'),
              _buildExampleChip('Best for senior citizens'),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms);
  }

  Widget _buildExampleChip(String text) {
    return GestureDetector(
      onTap: () => _processQuery(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isUser,
    String? intent,
    String? language,
  }) {
    return GestureDetector(
      onTap: isUser ? null : () => _speakText(text),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isUser ? AppTheme.primaryGradient : null,
            color: isUser ? null : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
              if (!isUser) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (intent != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          intent.toUpperCase(),
                          style: TextStyle(fontSize: 10, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (language != null) ...[
                      Text(
                        '(${language.toUpperCase()})',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Spacer(),
                    Icon(Icons.volume_up_rounded, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to hear',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: isUser ? 0.1 : -0.1, end: 0);
  }

  Widget _buildVoiceControl() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isListening) ...[
            Text(
              'Listening...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (_transcribedText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _transcribedText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
          ],
          
          if (_isProcessing) ...[
            const Text(
              'Processing...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Mic Button
          GestureDetector(
            onTap: _isProcessing ? null : _toggleListening,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _isListening 
                        ? AppTheme.goldGradient 
                        : (_isProcessing ? null : AppTheme.primaryGradient),
                    color: _isProcessing ? Colors.grey : null,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? AppTheme.accentGold : AppTheme.primaryBlue)
                            .withValues(alpha: _isListening ? 0.3 + (_pulseController.value * 0.2) : 0.3),
                        blurRadius: _isListening ? 20 + (_pulseController.value * 10) : 20,
                        spreadRadius: _isListening ? _pulseController.value * 10 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isListening ? 'Tap to stop' : (_isProcessing ? 'Please wait...' : 'Tap to speak'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    }
    
    if (_isListening) {
      // Stop listening
      await _speech.stop();
      setState(() => _isListening = false);
      
      // Process the transcribed text if we have any meaningful content
      // Require at least 2 characters to avoid noise
      if (_transcribedText.trim().length >= 2) {
        await _processQuery(_transcribedText);
      } else {
        debugPrint('🎤 Ignored - transcription too short: "$_transcribedText"');
      }
      _transcribedText = '';
    } else {
      // Start listening
      if (!_speechAvailable) {
        debugPrint('🎤 Speech not available');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available on this device')),
        );
        return;
      }
      
      // Clear any previous state
      _transcribedText = '';
      
      setState(() {
        _isListening = true;
        _transcribedText = '';
      });
      
      final locale = _sttLocales[_currentLanguage] ?? 'en_IN';
      debugPrint('🎤 Starting listening with locale: $locale');
      
      try {
        await _speech.listen(
          localeId: locale,
          onResult: (result) {
            debugPrint('🎤 Recognized: "${result.recognizedWords}" (final: ${result.finalResult})');
            
            setState(() {
              _transcribedText = result.recognizedWords;
            });
            
            // Only auto-stop if we have a valid final result with actual content
            if (result.finalResult) {
              _speech.stop();
              setState(() => _isListening = false);
              
              // Require minimum length to avoid false recognitions
              if (_transcribedText.trim().length >= 2) {
                _processQuery(_transcribedText);
              } else {
                debugPrint('🎤 Ignored short final result: "$_transcribedText"');
              }
              _transcribedText = '';
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
        );
      } catch (e) {
        debugPrint('🎤 Listen error: $e');
        setState(() {
          _isListening = false;
          _transcribedText = '';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Voice recognition error: $e')),
          );
        }
      }
    }
  }

  Future<void> _processQuery(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    debugPrint('🎤 [VoiceChatScreen] _processQuery called with: $cleanQuery');
    setState(() {
      _conversation.add({
        'role': 'user',
        'text': cleanQuery,
      });
      _isProcessing = true;
    });

    try {
      debugPrint('🎤 [VoiceChatScreen] Calling N8nService.processVoice...');
      final result = await N8nService.processVoice(
        audioData: cleanQuery,
        language: _currentLanguage,
      );
      debugPrint('🎤 [VoiceChatScreen] Got result: $result');

      final responseText = result['response'] as String? ?? 
          'I received your message. How can I help with insurance?';
      final detectedLanguage = result['detected_language'] as String? ?? _currentLanguage;
      var intent = result['intent'] as String? ?? 'general';
      
      // Fix: UI-side fix - Override compare intent if response indicates no policies
      // Don't show compare UI unless there are actual policies
      if (intent.toLowerCase() == 'compare' && 
          responseText.toLowerCase().contains('no policies')) {
        intent = 'general';
        debugPrint('🎤 UI Fix: Overriding compare intent to general (no policies in response)');
      }
      
      debugPrint('🎤 Detected language: $detectedLanguage, Intent: $intent');

      if (mounted) {
        // Show language detection popup if this is first detection or language changed
        final bool isNewLanguage = detectedLanguage != _lastDetectedLanguage || !_languageDetected;
        
        if (isNewLanguage) {
          final langInfo = AppConstants.supportedLanguages.firstWhere(
            (l) => l['code'] == detectedLanguage,
            orElse: () => {'name': 'English', 'native': 'English', 'code': 'en'},
          );
          
          // Show popup notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.language, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '🌐 Language Detected: ${langInfo['native']} (${langInfo['name']})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: AppTheme.primaryBlue,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        
        // Update current language based on detection
        setState(() {
          _currentLanguage = detectedLanguage;
          _lastDetectedLanguage = detectedLanguage;
          _languageDetected = true;
          _conversation.add({
            'role': 'assistant',
            'text': responseText,
            'intent': intent,
            'detected_language': detectedLanguage,
          });
          _isProcessing = false;
        });
        
        // Speak the response in the detected language
        await _speakText(responseText, detectedLanguage);
      }
    } catch (e) {
      debugPrint('🎤 [VoiceChatScreen] Error: $e');
      if (mounted) {
        final errorMsg = 'Sorry, I encountered an error. Please try again.';
        setState(() {
          _conversation.add({
            'role': 'assistant',
            'text': errorMsg,
          });
          _isProcessing = false;
        });
        await _speakText(errorMsg);
      }
    }
  }

  Future<void> _speakText(String text, [String? language]) async {
    try {
      final targetLang = language ?? _currentLanguage;
      
      // Set proper TTS language before speaking
      await _setTTSLanguage(targetLang);
      
      // Language-specific speech rates - English is slower, Indian languages are faster
      final speechRate = (targetLang == 'en') ? 0.45 : 0.65;
      await _tts.setSpeechRate(speechRate);
      
      debugPrint('🔊 Speaking in $targetLang (rate: $speechRate): ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      await _tts.speak(text);
    } catch (e) {
      debugPrint('🔊 TTS speak error: $e');
      // Try speaking in English as fallback
      try {
        await _tts.setLanguage('en-IN');
        await _tts.setSpeechRate(0.45);
        await _tts.speak(text);
      } catch (_) {
        debugPrint('🔊 TTS fallback also failed');
      }
    }
  }
}
