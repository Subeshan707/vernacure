/// Welcome Screen - Language Selection & Entry Point
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vernacure/config/constants.dart';
import 'package:vernacure/config/theme.dart';
import 'package:vernacure/screens/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    debugPrint('👋 [WelcomeScreen] initState called');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('👋 [WelcomeScreen] build() called');
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // Logo & Branding
                _buildBranding()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),
                
                const SizedBox(height: 48),
                
                // Language Selection
                _buildLanguageSelector()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0),
                
                const Spacer(),
                
                // Action Buttons
                _buildActionButtons()
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 32),
                
                // Powered by Blockchain
                _buildBlockchainBadge()
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 600.ms),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        // App Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:  0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            size: 64,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 24),
        
        // App Name
        const Text(
          'Vernacure',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        
        // Tagline
        Text(
          AppConstants.appTagline,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withValues(alpha:  0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Language',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppConstants.supportedLanguages.map((lang) {
            final isSelected = _selectedLanguage == lang['code'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLanguage = lang['code']!;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha:  0.15),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppTheme.accentGold : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  lang['native']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryBlue : Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Voice Chat Button (Primary)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToHome(startWithVoice: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.mic_rounded, size: 28),
            label: const Text(
              'Start Voice Chat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Browse Policies Button (Secondary)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _navigateToHome(startWithVoice: false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.policy_rounded, size: 24),
            label: const Text(
              'Browse Policies',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockchainBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:  0.1),
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
          const SizedBox(width: 8),
          const Text(
            'Secured by Avalanche Blockchain',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Image.network(
            'https://cryptologos.cc/logos/avalanche-avax-logo.png',
            width: 16,
            height: 16,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.link,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHome({required bool startWithVoice}) {
    debugPrint('🚀 [WelcomeScreen] Navigating to HomeScreen');
    debugPrint('🚀 [WelcomeScreen] Language: $_selectedLanguage, startWithVoice: $startWithVoice');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          selectedLanguage: _selectedLanguage,
          startWithVoice: startWithVoice,
        ),
      ),
    );
  }
}


