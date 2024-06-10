import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StripeCharge {
  String _getStripeAPIKey() => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to perform the operation: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getChargeDetails({
    required String chargeId,
  }) async {
    try {
      String apiKey = _getStripeAPIKey();
      String baseUrl = 'https://api.stripe.com/v1/charges';

      http.Response response = await http.get(
        Uri.parse('$baseUrl/$chargeId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
