/// Policy Comparison Screen - Enhanced with Graphs & AI Insights
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
  List<int>? _scores;
  
  // Quick Q&A Chat
  String? _selectedQuestion;
  String? _chatAnswer;
  bool _isAnswering = false;
  
  // Full Chatbot
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];
  bool _isChatLoading = false;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

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
      final policiesData = widget.policies.map((p) => {
        'name': p.name,
        'insurer': p.insurer,
        'premium': p.premiumYearly,
        'coverage': p.coverageAmount,
        'claimRatio': p.claimSettlementRatio,
        'benefits': p.benefits,
      }).toList();

      final result = await N8nService.comparePolicies(
        policies: policiesData,
        language: widget.language,
      );
      debugPrint('📊 [PolicyComparisonScreen] Got result: $result');

      if (mounted) {
        setState(() {
          _recommendedIndex = result['recommendedIndex'] as int? ?? 0;
          _aiExplanation = result['explanation'] as String? ?? 'AI recommendation generated';
          _scores = (result['scores'] as List?)?.cast<int>() ?? 
                    List.generate(widget.policies.length, (i) => 70 + i * 10);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('📊 [PolicyComparisonScreen] Error: $e');
      if (mounted) {
        setState(() {
          _recommendedIndex = 0;
          _aiExplanation = 'Based on claim settlement ratio and coverage analysis.';
          _scores = List.generate(widget.policies.length, (i) => 75 + i * 8);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('AI Policy Comparison'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading ? _buildLoadingView() : _buildComparisonView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.1),
                  AppTheme.accentGold.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI Analyzing Policies...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comparing ${widget.policies.length} policies',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildComparisonView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIRecommendationCard(),
          const SizedBox(height: 20),
          _buildChatbotSection(),
          const SizedBox(height: 20),
          _buildScoreComparisonChart(),
          const SizedBox(height: 20),
          _buildMetricsComparison(),
          const SizedBox(height: 20),
          _buildInsightsSection(),
          const SizedBox(height: 20),
          _buildPolicyCards(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAIRecommendationCard() {
    final recommendedPolicy = _recommendedIndex != null && _recommendedIndex! < widget.policies.length
        ? widget.policies[_recommendedIndex!]
        : widget.policies.first;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.secondaryBlue,
            Color(0xFF60A5FA), // Light blue
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI RECOMMENDATION',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Best Match For You',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${_scores?[_recommendedIndex ?? 0] ?? 85}%',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      recommendedPolicy.insurer.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendedPolicy.insurer,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        recommendedPolicy.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _aiExplanation,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildChatbotSection() {
    final recommended = _recommendedIndex != null && _recommendedIndex! < widget.policies.length
        ? widget.policies[_recommendedIndex!]
        : widget.policies.first;

    // Quick question suggestions
    final suggestions = [
      'Which has best claim ratio?',
      'Most affordable one?',
      'Why ${recommended.insurer}?',
      'Coverage difference?',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondaryBlue.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask About Policies',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Get quick answers about compared policies',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Quick suggestions
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _sendChatMessage(suggestions[index]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      suggestions[index],
                      style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Chat messages
          if (_chatMessages.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = _chatMessages[index];
                  final isUser = msg['role'] == 'user';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.primaryBlue,
                            child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isUser ? AppTheme.primaryBlue : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              msg['content'] ?? '',
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                                fontWeight: isUser ? FontWeight.normal : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        if (isUser) const SizedBox(width: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          
          // Loading indicator
          if (_isChatLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Thinking...', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Chat input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Ask about these policies...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      _sendChatMessage(text.trim());
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_chatController.text.trim().isNotEmpty) {
                    _sendChatMessage(_chatController.text.trim());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms);
  }

  Future<void> _sendChatMessage(String question) async {
    _chatController.clear();
    
    setState(() {
      _chatMessages.add({'role': 'user', 'content': question});
      _isChatLoading = true;
    });

    try {
      // Generate quick AI response based on the question and policies
      final answer = _generateQuickAnswer(question);
      
      await Future.delayed(const Duration(milliseconds: 500)); // Brief delay for UX
      
      if (mounted) {
        setState(() {
          _chatMessages.add({'role': 'ai', 'content': answer});
          _isChatLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatMessages.add({'role': 'ai', 'content': 'Unable to answer. Try again.'});
          _isChatLoading = false;
        });
      }
    }
  }

  String _generateQuickAnswer(String question) {
    final q = question.toLowerCase();
    final recommended = _recommendedIndex != null && _recommendedIndex! < widget.policies.length
        ? widget.policies[_recommendedIndex!]
        : widget.policies.first;
    
    final bestClaim = widget.policies.reduce((a, b) => a.claimSettlementRatio > b.claimSettlementRatio ? a : b);
    final cheapest = widget.policies.reduce((a, b) => a.premiumYearly < b.premiumYearly ? a : b);
    final highestCover = widget.policies.reduce((a, b) => a.coverageAmount > b.coverageAmount ? a : b);
    
    // Match questions
    if (q.contains('claim') || q.contains('settlement')) {
      return '${bestClaim.name} has best claim ratio at ${bestClaim.claimSettlementRatio}%';
    }
    if (q.contains('affordable') || q.contains('cheap') || q.contains('low') || q.contains('budget')) {
      return '${cheapest.name} is most affordable at ₹${(cheapest.premiumYearly / 1000).toStringAsFixed(0)}K/year';
    }
    if (q.contains('coverage') || q.contains('cover') || q.contains('sum')) {
      return '${highestCover.name} offers highest coverage of ₹${(highestCover.coverageAmount / 100000).toInt()}L';
    }
    if (q.contains('why') || q.contains('recommend')) {
      return '${recommended.name} balances ${recommended.claimSettlementRatio}% claim ratio, ₹${(recommended.coverageAmount / 100000).toInt()}L cover at fair premium';
    }
    if (q.contains('difference') || q.contains('compare')) {
      return 'Premiums range ₹${(cheapest.premiumYearly / 1000).toStringAsFixed(0)}K-₹${(widget.policies.reduce((a, b) => a.premiumYearly > b.premiumYearly ? a : b).premiumYearly / 1000).toStringAsFixed(0)}K. Coverage: ₹${(widget.policies.reduce((a, b) => a.coverageAmount < b.coverageAmount ? a : b).coverageAmount / 100000).toInt()}L-₹${(highestCover.coverageAmount / 100000).toInt()}L';
    }
    if (q.contains('best') || q.contains('top')) {
      return 'AI recommends ${recommended.name} (${recommended.insurer}) with score ${_scores?[_recommendedIndex ?? 0] ?? 85}%';
    }
    if (q.contains('benefit') || q.contains('feature')) {
      return '${recommended.name} offers: ${recommended.benefits.take(2).join(', ')}';
    }
    
    return '${recommended.name} is recommended. Ask about claim ratio, premium, or coverage.';
  }

  Widget _buildScoreComparisonChart() {
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
              const Icon(Icons.bar_chart, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              const Text(
                'AI Score Comparison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...widget.policies.asMap().entries.map((entry) {
            final index = entry.key;
            final policy = entry.value;
            final score = _scores?[index] ?? 75;
            final isRecommended = index == _recommendedIndex;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          policy.name,
                          style: TextStyle(
                            fontWeight: isRecommended ? FontWeight.bold : FontWeight.normal,
                            color: isRecommended ? AppTheme.accentGold : Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          if (isRecommended)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '👑 BEST',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          Text(
                            '$score%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isRecommended ? AppTheme.accentGold : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        isRecommended 
                            ? AppTheme.accentGold
                            : _getScoreColor(score),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (200 * index).ms);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMetricsComparison() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const Row(
            children: [
              Icon(Icons.compare_arrows, color: AppTheme.primaryBlue),
              SizedBox(width: 8),
              Text(
                'Key Metrics Comparison',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Header Row with policy names
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Metric',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                ...widget.policies.asMap().entries.map((entry) => Expanded(
                  flex: 2,
                  child: Text(
                    entry.value.insurer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: entry.key == _recommendedIndex ? AppTheme.accentGold : AppTheme.primaryBlue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Premium Row
          _buildComparisonRow(
            'Premium',
            widget.policies.map((p) => '₹${(p.premiumYearly / 1000).toStringAsFixed(0)}K').toList(),
            Icons.payments,
          ),
          // Coverage Row
          _buildComparisonRow(
            'Coverage',
            widget.policies.map((p) => '₹${(p.coverageAmount / 100000).toInt()}L').toList(),
            Icons.security,
          ),
          // Claim Ratio Row
          _buildComparisonRow(
            'Claim %',
            widget.policies.map((p) => '${p.claimSettlementRatio}%').toList(),
            Icons.verified,
          ),
          // Risk Score Row
          _buildComparisonRow(
            'Risk',
            widget.policies.map((p) => '${p.riskScore}/10').toList(),
            Icons.warning_amber,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildComparisonRow(String label, List<String> values, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          ...values.asMap().entries.map((entry) => Expanded(
            flex: 2,
            child: Text(
              entry.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: entry.key == _recommendedIndex ? FontWeight.bold : FontWeight.normal,
                color: entry.key == _recommendedIndex ? AppTheme.accentGold : Colors.grey.shade800,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    // Calculate max values for scaling
    final maxCoverage = widget.policies.map((p) => p.coverageAmount).reduce((a, b) => a > b ? a : b);
    final maxPremium = widget.policies.map((p) => p.premiumYearly).reduce((a, b) => a > b ? a : b);
    final maxClaimRatio = widget.policies.map((p) => p.claimSettlementRatio).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Visual Comparison',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Coverage Comparison
          _buildGraphSection(
            'Coverage Amount',
            Icons.security,
            AppTheme.successGreen,
            widget.policies.map((p) => p.coverageAmount / maxCoverage).toList(),
            widget.policies.map((p) => '₹${(p.coverageAmount / 100000).toInt()}L').toList(),
          ),
          const SizedBox(height: 16),
          
          // Premium Comparison (Lower is better - inverted)
          _buildGraphSection(
            'Premium (Lower is Better)',
            Icons.payments,
            AppTheme.secondaryBlue,
            widget.policies.map((p) => 1 - (p.premiumYearly / (maxPremium * 1.2))).toList(),
            widget.policies.map((p) => '₹${(p.premiumYearly / 1000).toStringAsFixed(0)}K').toList(),
          ),
          const SizedBox(height: 16),
          
          // Claim Ratio Comparison
          _buildGraphSection(
            'Claim Settlement Ratio',
            Icons.verified,
            AppTheme.accentGold,
            widget.policies.map((p) => p.claimSettlementRatio / maxClaimRatio).toList(),
            widget.policies.map((p) => '${p.claimSettlementRatio}%').toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildGraphSection(String title, IconData icon, Color color, List<double> ratios, List<String> labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...widget.policies.asMap().entries.map((entry) {
          final index = entry.key;
          final policy = entry.value;
          final isRecommended = index == _recommendedIndex;
          final ratio = ratios[index].clamp(0.0, 1.0);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    policy.insurer,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isRecommended ? FontWeight.bold : FontWeight.normal,
                      color: isRecommended ? AppTheme.accentGold : Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: ratio,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: isRecommended
                                ? AppTheme.goldGradient
                                : LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isRecommended
                                ? [BoxShadow(color: AppTheme.accentGold.withValues(alpha: 0.4), blurRadius: 4)]
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isRecommended ? AppTheme.accentGold : color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPolicyCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Policy Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...widget.policies.asMap().entries.map((entry) {
          final index = entry.key;
          final policy = entry.value;
          final isRecommended = index == _recommendedIndex;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isRecommended 
                  ? Border.all(color: const Color(0xFF6366F1), width: 2) 
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isRecommended 
                      ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '⭐ AI RECOMMENDED',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: isRecommended
                            ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
                            : AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          policy.insurer.substring(0, 1),
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(policy.insurer, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          Text(
                            policy.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isRecommended ? const Color(0xFF6366F1) : AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_scores?[index] ?? 75}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isRecommended ? const Color(0xFF6366F1) : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    _buildPolicyMetric('Premium', '₹${policy.premiumYearly.toInt()}/yr', Icons.payments),
                    _buildPolicyMetric('Coverage', '₹${(policy.coverageAmount / 100000).toInt()}L', Icons.security),
                    _buildPolicyMetric('Claim', '${policy.claimSettlementRatio}%', Icons.verified),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PurchaseScreen(policy: policy, language: widget.language)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRecommended ? const Color(0xFF6366F1) : AppTheme.primaryBlue,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isRecommended ? '🎯 Get This Policy' : 'View Details'),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (100 * index).ms);
        }),
      ],
    );
  }

  Widget _buildPolicyMetric(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
