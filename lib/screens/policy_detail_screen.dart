/// Policy Detail Screen - View full policy details
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vernacure/config/theme.dart';
import 'package:vernacure/models/policy.dart';
import 'package:vernacure/screens/purchase_screen.dart';

class PolicyDetailScreen extends StatelessWidget {
  final InsurancePolicy policy;
  final String language;

  const PolicyDetailScreen({
    super.key,
    required this.policy,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 20),
                  _buildPremiumSection(),
                  const SizedBox(height: 20),
                  _buildBenefitsSection(),
                  const SizedBox(height: 20),
                  _buildExclusionsSection(),
                  const SizedBox(height: 20),
                  _buildRidersSection(),
                  const SizedBox(height: 20),
                  _buildSuitabilitySection(),
                  const SizedBox(height: 20),
                  _buildScoresSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppTheme.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          policy.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryBlue,
                AppTheme.primaryBlue.withValues(alpha: 0.8),
                AppTheme.accentGold.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              _getTypeIcon(),
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (policy.type.toLowerCase()) {
      case 'health insurance':
        return Icons.favorite;
      case 'term insurance':
        return Icons.shield;
      case 'life insurance':
        return Icons.family_restroom;
      case 'ulip':
        return Icons.trending_up;
      case 'child plan':
        return Icons.child_care;
      case 'critical illness':
        return Icons.medical_services;
      case 'personal accident':
        return Icons.warning_rounded;
      case 'cancer insurance':
        return Icons.healing;
      case 'super top-up':
        return Icons.add_circle;
      default:
        return Icons.policy;
    }
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  policy.insurer,
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  policy.category,
                  style: TextStyle(
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            policy.type,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.green, size: 20),
              const SizedBox(width: 6),
              Text(
                'Claim Settlement: ${policy.claimSettlementRatio}%',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPremiumSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPremiumItem('Monthly', '₹${policy.premiumMonthly.toInt()}'),
              Container(width: 1, height: 50, color: Colors.white24),
              _buildPremiumItem('Yearly', '₹${policy.premiumYearly.toInt()}'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Coverage: ₹${_formatAmount(policy.coverageAmount)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPremiumItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)} L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildBenefitsSection() {
    return _buildSection(
      'Benefits',
      Icons.check_circle,
      Colors.green,
      policy.benefits,
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildExclusionsSection() {
    return _buildSection(
      'Exclusions',
      Icons.cancel,
      Colors.red,
      policy.exclusions,
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRidersSection() {
    if (policy.riders.isEmpty) return const SizedBox.shrink();
    return _buildSection(
      'Available Riders',
      Icons.add_circle_outline,
      AppTheme.primaryBlue,
      policy.riders,
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSection(String title, IconData icon, Color color, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.arrow_right, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSuitabilitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Who Is This For?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSuitabilityItem(
            '✅ Best For',
            policy.suitableFor,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildSuitabilityItem(
            '⚠️ Not Ideal For',
            policy.notIdealFor,
            Colors.orange,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSuitabilityItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Policy Scores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildScoreItem(
                  'Readability',
                  policy.readabilityScore,
                  Colors.blue,
                  Icons.menu_book,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildScoreItem(
                  'Risk Level',
                  policy.riskScore,
                  policy.riskScore <= 3 ? Colors.green : 
                  policy.riskScore <= 6 ? Colors.orange : Colors.red,
                  Icons.warning_amber,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildScoreItem(String label, int score, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            '$score/10',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PurchaseScreen(
                  policy: policy,
                  language: language,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart),
              SizedBox(width: 8),
              Text(
                'Get This Policy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
