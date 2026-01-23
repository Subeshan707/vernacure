/// Home Screen - Main Navigation Hub
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vernacure/config/theme.dart';
import 'package:vernacure/screens/policy_list_screen.dart';
import 'package:vernacure/screens/voice_chat_screen.dart';
import 'package:vernacure/screens/rag_chatbot_screen.dart';
import 'package:vernacure/screens/my_policies_screen.dart';

class HomeScreen extends StatefulWidget {
  final String selectedLanguage;
  final bool startWithVoice;

  const HomeScreen({
    super.key,
    required this.selectedLanguage,
    this.startWithVoice = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 [HomeScreen] initState - Language: ${widget.selectedLanguage}');
    _screens = [
      PolicyListScreen(language: widget.selectedLanguage),
      VoiceChatScreen(language: widget.selectedLanguage),
      RagChatbotScreen(language: widget.selectedLanguage),
      MyPoliciesScreen(language: widget.selectedLanguage),
    ];
    
    if (widget.startWithVoice) {
      _currentIndex = 1;
      debugPrint('🏠 [HomeScreen] Starting with Voice tab');
    }
    debugPrint('🏠 [HomeScreen] Screens initialized, starting at tab $_currentIndex');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha:  0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.policy_rounded, 'Policies'),
              _buildNavItem(1, Icons.mic_rounded, 'Voice'),
              _buildNavItem(2, Icons.chat_bubble_rounded, 'Ask AI'),
              _buildNavItem(3, Icons.folder_rounded, 'My Policies'),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        debugPrint('🔵 [HomeScreen] Navigating to tab $index: $label');
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha:  0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryBlue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


