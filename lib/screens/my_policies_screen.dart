/// My Policies Screen - User's Blockchain Policies
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vernacure/config/theme.dart';

class MyPoliciesScreen extends StatelessWidget {
  final String language;

  const MyPoliciesScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    debugPrint('💼 [MyPoliciesScreen] build() called - Language: $language');
    // Demo data
    final policies = [
      {'id': 'VRN-2026-00142', 'name': 'HDFC Click2Protect', 'status': 'Active', 'coverage': '50L', 'txHash': '0xabc...def'},
      {'id': 'VRN-2026-00089', 'name': 'Star Health Optima', 'status': 'Active', 'coverage': '10L', 'txHash': '0x123...456'},
    ];
    debugPrint('💼 [MyPoliciesScreen] Showing ${policies.length} policies');

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: policies.isEmpty ? _buildEmptyState() : _buildPolicyList(policies),
            ),
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
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.folder_special, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('My Policies', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            Text('Secured on Avalanche Blockchain', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ])),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.folder_open, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text('No policies yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Text('Purchase a policy to see it here', style: TextStyle(color: Colors.grey.shade400)),
      ]),
    );
  }

  Widget _buildPolicyList(List<Map<String, String>> policies) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: policies.length,
      itemBuilder: (context, index) {
        final policy = policies[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:  0.05), blurRadius: 10)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha:  0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.verified, color: AppTheme.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(policy['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(policy['id']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.successGreen.withValues(alpha:  0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(policy['status']!, style: const TextStyle(color: AppTheme.successGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              _buildInfoChip(Icons.shield, 'Coverage: ${policy['coverage']}'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.link, 'Tx: ${policy['txHash']}'),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('View Details'),
              )),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Blockchain'),
              )),
            ]),
          ]),
        ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppTheme.primaryBlue),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ]),
    );
  }
}


