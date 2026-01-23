/// Policy Comparison Screen
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vernacure/config/theme.dart';
import 'package:vernacure/models/policy.dart';
import 'package:vernacure/screens/purchase_screen.dart';
import 'package:vernacure/services/n8n_service.dart';

class PolicyComparisonScreen extends StatefulWidget {
  final List<InsurancePolicy> policies;
  final String language;

  const PolicyComparisonScreen({
    super.key,
    required this.policies,
    required this.language,
  });

  @override
  State<PolicyComparisonScreen> createState() => _PolicyComparisonScreenState();
}

class _PolicyComparisonScreenState extends State<PolicyComparisonScreen> {
  int? _recommendedIndex;
  String _aiExplanation = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('📊 [PolicyComparisonScreen] initState - Language: ${widget.language}');
    debugPrint('📊 [PolicyComparisonScreen] Comparing ${widget.policies.length} policies');
    _getAIRecommendation();
  }

  Future<void> _getAIRecommendation() async {
    debugPrint('📊 [PolicyComparisonScreen] _getAIRecommendation called');
    try {
      // Prepare policy data for n8n
      final policiesData = widget.policies.map((p) => {
        'name': p.name,
        'insurer': p.insurer,
        'premium': p.premiumYearly,
        'coverage': p.coverageAmount,
        'claimRatio': p.claimSettlementRatio,
      }).toList();
      debugPrint('📊 [PolicyComparisonScreen] Calling N8nService.comparePolicies...');
      debugPrint('📊 [PolicyComparisonScreen] Policies data: $policiesData');

      // Call n8n comparison webhook
      final result = await N8nService.comparePolicies(
        policies: policiesData,
        language: widget.language,
      );
      debugPrint('📊 [PolicyComparisonScreen] Got result: $result');

      if (mounted) {
        setState(() {
          _recommendedIndex = result['recommendedIndex'] as int? ?? 0;
          _aiExplanation = result['explanation'] as String? ?? 'AI recommendation generated';
          _isLoading = false;
        });
        debugPrint('📊 [PolicyComparisonScreen] Recommended index: $_recommendedIndex');
      }
    } catch (e) {
      debugPrint('📊 [PolicyComparisonScreen] Error: $e');
      // Fallback to basic recommendation if API fails
      if (mounted) {
        setState(() {
          _recommendedIndex = 1;
          _aiExplanation = 'Could not load AI recommendation. Showing default comparison based on claim settlement ratio.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: const Text('Compare Policies')),
      body: Column(
        children: [
          _buildAIBanner(),
          Expanded(child: _buildComparisonList()),
        ],
      ),
    );
  }

  Widget _buildAIBanner() {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Text('AI analyzing...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.lightbulb, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('AI Recommendation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          Text(_aiExplanation, style: TextStyle(color: Colors.white.withValues(alpha:  0.9), fontSize: 14)),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildComparisonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.policies.length,
      itemBuilder: (context, index) {
        final policy = widget.policies[index];
        final isRecommended = index == _recommendedIndex;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isRecommended ? Border.all(color: AppTheme.accentGold, width: 2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: AppTheme.accentGold, borderRadius: BorderRadius.circular(8)),
                  child: const Text('⭐ RECOMMENDED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              Text(policy.insurer, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(policy.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              const SizedBox(height: 12),
              Row(children: [
                _buildMetric('Premium', '₹${policy.premiumYearly.toInt()}/yr'),
                _buildMetric('Coverage', '₹${(policy.coverageAmount / 100000).toInt()}L'),
                _buildMetric('Claim %', '${policy.claimSettlementRatio}%'),
              ]),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PurchaseScreen(policy: policy, language: widget.language))),
                style: ElevatedButton.styleFrom(backgroundColor: isRecommended ? AppTheme.accentGold : AppTheme.primaryBlue),
                child: const Text('Buy with AVAX'),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (100 * index).ms);
      },
    );
  }

  Widget _buildMetric(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}


