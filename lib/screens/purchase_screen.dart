/// Purchase Screen - AVAX Blockchain Payment
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vernacure/config/theme.dart';
import 'package:vernacure/config/avax_config.dart';
import 'package:vernacure/models/policy.dart';

class PurchaseScreen extends StatefulWidget {
  final InsurancePolicy policy;
  final String language;

  const PurchaseScreen({super.key, required this.policy, required this.language});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool _isConnected = false;
  bool _isProcessing = false;
  bool _isSuccess = false;
  String _walletAddress = '';
  String _txHash = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: const Text('Purchase Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPolicySummary(),
            const SizedBox(height: 20),
            _buildBlockchainInfo(),
            const SizedBox(height: 20),
            if (!_isConnected) _buildConnectWallet(),
            if (_isConnected && !_isSuccess) _buildPaymentSection(),
            if (_isSuccess) _buildSuccessSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:  0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.verified_user, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.policy.insurer, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(widget.policy.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            ])),
          ]),
          const Divider(height: 32),
          _buildDetailRow('Coverage', '₹${(widget.policy.coverageAmount / 100000).toInt()} Lakhs'),
          _buildDetailRow('Premium', '₹${widget.policy.premiumYearly.toInt()}/year'),
          _buildDetailRow('Type', widget.policy.type),
          _buildDetailRow('Claim Ratio', '${widget.policy.claimSettlementRatio}%'),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildBlockchainInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha:  0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha:  0.2)),
      ),
      child: Row(children: [
        Image.network('https://cryptologos.cc/logos/avalanche-avax-logo.png', width: 32, height: 32,
          errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin, color: AppTheme.primaryBlue)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Avalanche Fuji Testnet', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          Text('Chain ID: ${AvaxConfig.chainId}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.successGreen, borderRadius: BorderRadius.circular(8)),
          child: const Text('TESTNET', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _buildConnectWallet() {
    return Column(children: [
      ElevatedButton.icon(
        onPressed: _connectWallet,
        icon: const Icon(Icons.account_balance_wallet),
        label: const Text('Connect MetaMask'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      const SizedBox(height: 12),
      Text('Connect your wallet to purchase', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
    ]);
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.check_circle, color: AppTheme.successGreen),
          const SizedBox(width: 8),
          Expanded(child: Text('Wallet: ${_walletAddress.substring(0, 6)}...${_walletAddress.substring(_walletAddress.length - 4)}',
            style: const TextStyle(fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Amount:', style: TextStyle(fontSize: 16)),
            const Text('0.05 AVAX', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          ]),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _confirmPurchase,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isProcessing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Confirm Purchase', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    ).animate().fadeIn();
  }

  Widget _buildSuccessSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.successGreen.withValues(alpha:  0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 64),
        ),
        const SizedBox(height: 20),
        const Text('Policy Purchased!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
        const SizedBox(height: 8),
        const Text('Your insurance is now active on blockchain', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            Text('Insurance ID: VRN-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            const SizedBox(height: 8),
            Text('Tx: ${_txHash.substring(0, 20)}...', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ]),
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.open_in_new),
          label: const Text('View on Snowtrace'),
        ),
      ]),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  void _connectWallet() {
    // TODO: Integrate WalletConnect
    setState(() {
      _isConnected = true;
      _walletAddress = '0x742d35Cc6634C0532925a3b844Bc9e7595f3a5f1';
    });
  }

  void _confirmPurchase() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
          _txHash = '0xabc123def456789ghijklmnop123456789xyz';
        });
      }
    });
  }
}


