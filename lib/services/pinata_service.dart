/// Pinata IPFS Service - Store transaction data permanently on IPFS
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:vernacure/config/constants.dart';

/// Service for pinning JSON data to IPFS via Pinata
class PinataService {
  static const String _pinJsonUrl = 'https://api.pinata.cloud/pinning/pinJSONToIPFS';
  static const String _pinListUrl = 'https://api.pinata.cloud/data/pinList';

  /// Pin transaction data to IPFS
  /// Returns the IPFS hash (CID) if successful, null otherwise
  static Future<String?> pinTransactionData({
    required String policyName,
    required String policyId,
    required String insurer,
    required double premiumAmount,
    required String currency,
    required String walletAddress,
    required String transactionHash,
    required String networkName,
    String? userId,
  }) async {
    try {
      debugPrint('📌 [Pinata] Pinning transaction data to IPFS...');
      debugPrint('📌 [Pinata] JWT token length: ${AppConstants.pinataJwt.length}');
      
      final transactionData = {
        'type': 'insurance_purchase',
        'version': '1.0',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'policy': {
          'id': policyId,
          'name': policyName,
          'insurer': insurer,
        },
        'payment': {
          'amount': premiumAmount,
          'currency': currency,
          'network': networkName,
        },
        'transaction': {
          'hash': transactionHash,
          'walletAddress': walletAddress,
          'confirmedAt': DateTime.now().toUtc().toIso8601String(),
        },
        'user': {
          'id': userId ?? 'anonymous',
        },
        'metadata': {
          'app': 'Vernacure',
          'platform': defaultTargetPlatform.toString(),
        },
      };

      final requestBody = jsonEncode({
        'pinataContent': transactionData,
        'pinataMetadata': {
          'name': 'Vernacure_TX_${transactionHash.substring(0, 10)}',
          'keyvalues': {
            'type': 'insurance_transaction',
            'policyId': policyId,
            'walletAddress': walletAddress,
          },
        },
        'pinataOptions': {
          'cidVersion': 1,
        },
      });

      debugPrint('📌 [Pinata] Sending request to: $_pinJsonUrl');
      
      final response = await http.post(
        Uri.parse(_pinJsonUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.pinataJwt}',
        },
        body: requestBody,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('📌 [Pinata] ⏰ Request timed out after 30 seconds');
          throw Exception('Network timeout - check your internet connection');
        },
      );

      debugPrint('📌 [Pinata] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final ipfsHash = result['IpfsHash'] as String;
        debugPrint('📌 [Pinata] ✅ Pinned successfully! CID: $ipfsHash');
        debugPrint('📌 [Pinata] View at: ${AppConstants.pinataGateway}/$ipfsHash');
        return ipfsHash;
      } else {
        debugPrint('📌 [Pinata] ❌ Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('📌 [Pinata] ❌ Exception: $e');
      debugPrint('📌 [Pinata] Stack: $stackTrace');
      return null;
    }
  }

  /// Pin policy purchase receipt to IPFS
  static Future<String?> pinPurchaseReceipt({
    required Map<String, dynamic> policyDetails,
    required Map<String, dynamic> paymentDetails,
    required Map<String, dynamic> userDetails,
  }) async {
    try {
      debugPrint('📌 [Pinata] Pinning purchase receipt to IPFS...');
      
      final receiptData = {
        'type': 'insurance_purchase_receipt',
        'version': '1.0',
        'generatedAt': DateTime.now().toUtc().toIso8601String(),
        'policy': policyDetails,
        'payment': paymentDetails,
        'purchaser': userDetails,
        'verification': {
          'app': 'Vernacure',
          'verified': true,
        },
      };

      final response = await http.post(
        Uri.parse(_pinJsonUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.pinataJwt}',
        },
        body: jsonEncode({
          'pinataContent': receiptData,
          'pinataMetadata': {
            'name': 'Vernacure_Receipt_${DateTime.now().millisecondsSinceEpoch}',
            'keyvalues': {
              'type': 'purchase_receipt',
              'policyId': policyDetails['id'] ?? '',
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final ipfsHash = result['IpfsHash'] as String;
        debugPrint('📌 [Pinata] ✅ Receipt pinned! CID: $ipfsHash');
        return ipfsHash;
      } else {
        debugPrint('📌 [Pinata] ❌ Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('📌 [Pinata] ❌ Exception: $e');
      return null;
    }
  }

  /// Get the full IPFS gateway URL for a given CID
  static String getIpfsUrl(String cid) {
    return '${AppConstants.pinataGateway}/$cid';
  }

  /// Fetch pinned data from IPFS
  static Future<Map<String, dynamic>?> fetchFromIpfs(String cid) async {
    try {
      final url = getIpfsUrl(cid);
      debugPrint('📌 [Pinata] Fetching from: $url');
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('📌 [Pinata] ❌ Fetch error: $e');
      return null;
    }
  }

  /// List all pinned transactions for this app
  static Future<List<Map<String, dynamic>>> listPinnedTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$_pinListUrl?metadata[keyvalues][type]={"value":"insurance_transaction","op":"eq"}'),
        headers: {
          'Authorization': 'Bearer ${AppConstants.pinataJwt}',
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final rows = result['rows'] as List;
        return rows.map((r) => r as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      debugPrint('📌 [Pinata] ❌ List error: $e');
      return [];
    }
  }
}
