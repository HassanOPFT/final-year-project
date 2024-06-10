import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StripePaymentIntents {
  static const String _baseUrl = 'https://api.stripe.com/v1/payment_intents';
  String _getStripeAPIKey() => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to perform the operation: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    // String paymentMethodId = '',
    String customerId = '',
  }) async {
    try {
      String apiKey = _getStripeAPIKey();
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        // 'payment_method': paymentMethodId,
        'customer': customerId,
        'setup_future_usage': 'off_session',
        // 'automatic_payment_methods[allow_redirects]': 'never',
        // 'automatic_payment_methods[enabled]': 'false',
        'payment_method_types[]': 'card',
      };
      http.Response response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      return await _handleResponse(response);
    } catch (e) {
      print('Error creating PaymentIntent: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePaymentIntent({
    required String paymentIntentId,
    required Map<String, dynamic> body,
  }) async {
    try {
      String apiKey = _getStripeAPIKey();

      http.Response response = await http.post(
        Uri.parse('$_baseUrl/$paymentIntentId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'metadata[0]': body,
        },
      );
      return await _handleResponse(response);
    } catch (e) {
      print('Error updating PaymentIntent: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPaymentIntent({
    required String paymentIntentId,
  }) async {
    try {
      String apiKey = _getStripeAPIKey();

      http.Response response = await http.get(
        Uri.parse('$_baseUrl/$paymentIntentId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      return await _handleResponse(response);
    } catch (e) {
      print('Error retrieving PaymentIntent: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmPaymentIntent({
    required String paymentIntentId,
    String paymentMethodId = '',
    String receiptEmail = '',
    String setupFutureUsage = 'off_session',
  }) async {
    try {
      String apiKey = _getStripeAPIKey();

      Map<String, dynamic> body = {
        // 'payment_method': 'pm_1OyJRE06sxMdZTBdDq7u6nO1',
        'payment_method': paymentMethodId,
        'receipt_email': receiptEmail,
        'setup_future_usage': setupFutureUsage,
      };
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/$paymentIntentId/confirm'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      return await _handleResponse(response);
    } catch (e) {
      print('Error confirming PaymentIntent: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelPaymentIntent({
    required String paymentIntentId,
    String cancellationReason = '',
  }) async {
    try {
      String apiKey = _getStripeAPIKey();

      Map<String, dynamic> body = {'cancellation_reason': cancellationReason};
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/$paymentIntentId/cancel'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      return await _handleResponse(response);
    } catch (e) {
      print('Error canceling PaymentIntent: $e');
      rethrow;
    }
  }
}
