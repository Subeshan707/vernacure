/// Policy List Screen - Browse & Compare Insurance Policies
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vernacure/config/theme.dart';
import 'package:vernacure/models/policy.dart';
import 'package:vernacure/screens/policy_comparison_screen.dart';
import 'package:vernacure/widgets/policy_card.dart';

class PolicyListScreen extends StatefulWidget {
  final String language;

  const PolicyListScreen({super.key, required this.language});

  @override
  State<PolicyListScreen> createState() => _PolicyListScreenState();
}

class _PolicyListScreenState extends State<PolicyListScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Individual', 'Family', 'Senior Citizen', 'Budget'];
  final List<InsurancePolicy> _policies = SamplePolicies.policies
      .map((json) => InsurancePolicy.fromJson(json))
      .toList();
  
  final Set<String> _selectedForComparison = {};

  @override
  Widget build(BuildContext context) {
    debugPrint('📄 [PolicyListScreen] build() called - Language: ${widget.language}');
    final filteredPolicies = _selectedCategory == 'All'
        ? _policies
        : _policies.where((p) => p.category == _selectedCategory).toList();
    debugPrint('📄 [PolicyListScreen] Showing ${filteredPolicies.length} policies in category: $_selectedCategory');

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilter(),
            Expanded(
              child: _buildPolicyList(filteredPolicies),
            ),
            if (_selectedForComparison.isNotEmpty)
              _buildCompareBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Your',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Text(
                    'Perfect Insurance',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha:  0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.tune_rounded, color: AppTheme.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha:  0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search policies...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0);
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                          ? AppTheme.primaryBlue.withValues(alpha:  0.3)
                          : Colors.grey.withValues(alpha:  0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildPolicyList(List<InsurancePolicy> policies) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: policies.length,
      itemBuilder: (context, index) {
        final policy = policies[index];
        final isSelected = _selectedForComparison.contains(policy.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PolicyCard(
            policy: policy,
            isSelectedForComparison: isSelected,
            onCompareToggle: () {
              setState(() {
                if (isSelected) {
                  _selectedForComparison.remove(policy.id);
                } else if (_selectedForComparison.length < 3) {
                  _selectedForComparison.add(policy.id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You can compare up to 3 policies'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              });
            },
            onTap: () {
              // Navigate to policy detail
            },
          )
              .animate()
              .fadeIn(delay: (100 * index).ms, duration: 400.ms)
              .slideX(begin: 0.1, end: 0),
        );
      },
    );
  }

  Widget _buildCompareBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              '${_selectedForComparison.length} policies selected',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final selectedPolicies = _policies
                    .where((p) => _selectedForComparison.contains(p.id))
                    .toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PolicyComparisonScreen(
                      policies: selectedPolicies,
                      language: widget.language,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.white,
              ),
              child: const Text('Compare Now'),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.5, end: 0);
  }
}


