import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class MpesaService {
  static Future<Map<String, dynamic>> mintChamaCoin({
    required String chamaId,
    required double amount,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('mintChamaCoin');
      final result = await callable.call({
        'chama_id': chamaId,
        'amount': amount,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      debugPrint('Mint error: $e');
      rethrow;
    }
  }
}

class AIService {
  static Future<String> generateTip(String prompt) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('generateAITip');
      final result = await callable.call({'prompt': prompt});
      return result.data['tip'] as String? ?? 'Stay consistent with contributions.';
    } catch (e) {
      return 'AI tip temporarily unavailable.';
    }
  }
}

class ValuationService {
  static Future<Map<String, dynamic>> valueAssetWithMedia({
    required String chamaId,
    required String assetType,
    required String description,
    required List<String> mediaUrls,
    double? annualRent,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('valueAssetWithMedia');
    final result = await callable.call({
      'chama_id': chamaId,
      'asset_type': assetType,
      'description': description,
      'media_urls': mediaUrls,
      'annual_rent': annualRent,
    });
    return Map<String, dynamic>.from(result.data);
  }
}