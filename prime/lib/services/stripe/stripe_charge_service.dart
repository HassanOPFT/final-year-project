import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:prime/models/stripe_charge.dart';

class StripeChargeService {
  String _getStripeAPIKey() => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to perform the operation: ${response.body}');
    }
  }

  Future<StripeCharge> getChargeDetails({
    required String chargeId,
  }) async {
    try {
      if (chargeId.isEmpty) {
        throw Exception('Charge ID cannot be empty');
      }
      String apiKey = _getStripeAPIKey();
      String baseUrl = 'https://api.stripe.com/v1/charges';

      http.Response response = await http.get(
        Uri.parse('$baseUrl/$chargeId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      StripeCharge stripeCharge =
          StripeCharge.fromJson(await _handleResponse(response));
      return stripeCharge;
    } catch (e) {
      rethrow;
    }
  }
}
