/// RAG Chatbot Screen - AI-Powered Insurance Q&A
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vernacure/config/theme.dart';
import 'package:vernacure/services/n8n_service.dart';

class RagChatbotScreen extends StatefulWidget {
  final String language;

  const RagChatbotScreen({super.key, required this.language});

  @override
  State<RagChatbotScreen> createState() => _RagChatbotScreenState();
}

class _RagChatbotScreenState extends State<RagChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  final List<String> _suggestedQuestions = [
    'What is term insurance?',
    'How to file a claim?',
    'What does premium mean?',
    'Explain policy exclusions',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🧠 [RagChatbotScreen] build() called - Language: ${widget.language}');
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildChatArea()),
            _buildInputArea(),
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
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insurance AI Assistant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Text(
                  'Powered by RAG Technology',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha:  0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0);
  }

  Widget _buildChatArea() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        
        final message = _messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMessageBubble(message),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha:  0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Ask me anything about insurance!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'I can explain policies, coverage, claims, and more',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Suggested Questions
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Try asking:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_suggestedQuestions.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildSuggestedQuestion(_suggestedQuestions[index], index),
            );
          }),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms);
  }

  Widget _buildSuggestedQuestion(String question, int index) {
    return GestureDetector(
      onTap: () => _sendMessage(question),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha:  0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:  0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: AppTheme.accentGold,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (100 * index).ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
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
              color: Colors.black.withValues(alpha:  0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.psychology_rounded, size: 16, color: AppTheme.accentGold),
                  const SizedBox(width: 6),
                  const Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message['text'],
              style: TextStyle(
                fontSize: 15,
                color: isUser ? Colors.white : Colors.black87,
                height: 1.4,
              ),
            ),
            if (message['sources'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha:  0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.source_rounded, size: 14, color: AppTheme.primaryBlue.withValues(alpha:  0.7)),
                    const SizedBox(width: 6),
                    Text(
                      'Sources: ${message['sources']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryBlue.withValues(alpha:  0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha:  0.5),
          shape: BoxShape.circle,
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .fadeIn(delay: (200 * index).ms)
          .then()
          .fadeOut(delay: 400.ms),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your question...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    _sendMessage(text);
  }

  Future<void> _sendMessage(String text) async {
    debugPrint('🧠 [RagChatbotScreen] _sendMessage called with: $text');
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      debugPrint('🧠 [RagChatbotScreen] Calling N8nService.sendChatMessage...');
      // Call n8n RAG chatbot webhook
      final result = await N8nService.sendChatMessage(
        message: text,
        language: widget.language,
      );
      debugPrint('🧠 [RagChatbotScreen] Got result: $result');

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'role': 'assistant',
            'text': result['response'] as String? ?? 'I received your message.',
            'sources': result['sources'],
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('🧠 [RagChatbotScreen] Error: $e');
      // Fallback response if API fails
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'role': 'assistant',
            'text': 'Sorry, I encountered an error connecting to the AI service. Please try again.',
            'sources': null,
          });
        });
        _scrollToBottom();
      }
    }
  }



  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}


