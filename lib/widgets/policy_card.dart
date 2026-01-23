/// Policy Card Widget
library;

import 'package:flutter/material.dart';
import 'package:vernacure/config/theme.dart';
import 'package:vernacure/models/policy.dart';

class PolicyCard extends StatelessWidget {
  final InsurancePolicy policy;
  final bool isSelectedForComparison;
  final VoidCallback onCompareToggle;
  final VoidCallback onTap;

  const PolicyCard({
    super.key,
    required this.policy,
    required this.isSelectedForComparison,
    required this.onCompareToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelectedForComparison ? Border.all(color: AppTheme.accentGold, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:  0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(policy.insurer.substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(policy.insurer, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  Text(policy.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ])),
                GestureDetector(
                  onTap: onCompareToggle,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelectedForComparison ? AppTheme.accentGold : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSelectedForComparison ? Icons.check : Icons.compare_arrows,
                      size: 20,
                      color: isSelectedForComparison ? Colors.white : AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(children: [
              _buildMetric('₹${policy.premiumYearly.toInt()}', '/year'),
              _buildMetric('₹${(policy.coverageAmount / 100000).toInt()}L', 'cover'),
              _buildMetric('${policy.claimSettlementRatio}%', 'claim'),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _buildTag(policy.type, AppTheme.primaryBlue),
              const SizedBox(width: 8),
              _buildTag(policy.category, AppTheme.successGreen),
            ]),
            const SizedBox(height: 12),
            Text('✓ ${policy.suitableFor}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Expanded(child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
    ]));
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha:  0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}


