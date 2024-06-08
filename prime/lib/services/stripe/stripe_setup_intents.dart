import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StripeSetupIntents {
  final String apiBaseUrl = 'https://api.stripe.com/v1/setup_intents';
  String _getStripAPIKey() => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  Future<Map<String, dynamic>> createSetupIntent(String customerId) async {
    try {
      String apiKey = _getStripAPIKey();
      final response = await http.post(
        Uri.parse(apiBaseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
          'usage': 'on_session',
          // 'automatic_payment_methods[allow_redirects]': 'never',
          // 'automatic_payment_methods[enabled]': 'false',
          'payment_method_types[0]': 'card',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error creating SetupIntent: $e');
      return {'error': 'Failed to create SetupIntent'};
    }
  }

  Future<Map<String, dynamic>> updateSetupIntent(
    String setupIntentId,
    Map<String, dynamic> updateParams,
  ) async {
    String apiKey = _getStripAPIKey();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/$setupIntentId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: updateParams,
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error updating SetupIntent: $e');
      return {'error': 'Failed to update SetupIntent'};
    }
  }

  Future<Map<String, dynamic>> getSetupIntents(String setupIntentId) async {
    String apiKey = _getStripAPIKey();
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/$setupIntentId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error getting SetupIntent: $e');
      return {'error': 'Failed to get SetupIntent'};
    }
  }

  Future<Map<String, dynamic>> cancelSetupIntent(String setupIntentId) async {
    String apiKey = _getStripAPIKey();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/$setupIntentId/cancel'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error canceling SetupIntent: $e');
      return {'error': 'Failed to cancel SetupIntent'};
    }
  }

  Future<Map<String, dynamic>> confirmSetupIntent(
    String setupIntentId,
  ) async {
    String apiKey = _getStripAPIKey();
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/$setupIntentId/confirm'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error confirming SetupIntent: $e');
      return {'error': 'Failed to confirm SetupIntent'};
    }
  }
}
