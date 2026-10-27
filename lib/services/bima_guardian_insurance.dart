import 'dart:convert';
import 'package:http/http.dart' as http;

/// Partner-facing client. The URL must point to a trusted HTTPS gateway
/// which authenticates the user and holds the Bima Guardian API key server-side.
class BimaGuardianInsuranceClient {
  final Uri gatewayBaseUrl;
  final Future<String> Function() accessToken;
  final http.Client _http;

  BimaGuardianInsuranceClient({
    required this.gatewayBaseUrl,
    required this.accessToken,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  Future<Map<String, dynamic>> requestQuote({
    required String product,
    required String subtype,
    required num sumInsured,
    required String applicantId,
    required String consentReference,
    Map<String, dynamic> additionalFields = const {},
  }) async {
    if (consentReference.trim().isEmpty) {
      throw ArgumentError('Insurance data-sharing consent is required');
    }
    if (sumInsured <= 0) throw ArgumentError('sumInsured must be positive');
    if (gatewayBaseUrl.scheme != 'https') {
      throw StateError('Use a secure HTTPS Bima Guardian partner gateway');
    }
    final response = await _http.post(
      gatewayBaseUrl.resolve('/v1/quotes'),
      headers: {
        'Authorization': 'Bearer ${await accessToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'product': product,
        'subtype': subtype,
        'sumInsured': sumInsured,
        'applicantId': applicantId,
        'consentReference': consentReference,
        ...additionalFields,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Quote request failed (${response.statusCode})');
    }
    final parsed = jsonDecode(response.body);
    if (parsed is! Map<String, dynamic>) {
      throw FormatException('Invalid insurance quote response');
    }
    return parsed;
  }

  void close() => _http.close();
}

/// Request insurance as an eligible registered entity, not as an assumed
/// corporation. The backend must check legal registration and signing mandate.
class ChamaInsuranceService {
  final BimaGuardianInsuranceClient client;
  ChamaInsuranceService(this.client);

  Future<Map<String, dynamic>> quoteRegisteredGroup({
    required String chamaId,
    required String registrationNumber,
    required String authorizationReference,
    required String consentReference,
    required String product,
    required String subtype,
    required num sumInsured,
    int? members,
  }) {
    if (registrationNumber.trim().isEmpty || authorizationReference.trim().isEmpty) {
      throw ArgumentError('Registration and authorized representative required');
    }
    return client.requestQuote(
      product: product,
      subtype: subtype,
      sumInsured: sumInsured,
      applicantId: chamaId,
      consentReference: consentReference,
      additionalFields: {
        'registrationNumber': registrationNumber,
        'authorizationReference': authorizationReference,
        'audience': 'sacco',
        if (members != null) 'members': members,
      },
    );
  }
}
