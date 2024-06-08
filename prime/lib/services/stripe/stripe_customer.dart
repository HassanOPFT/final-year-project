import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StripeCustomer {
  static const String _apiBaseUrl = 'https://api.stripe.com/v1';

  Future<Map<String, dynamic>> _callStripeAPI(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_apiBaseUrl/$endpoint');
    late http.Response response;
    final String apiKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';

    try {
      switch (method) {
        case 'POST':
          response = await http.post(
            url,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body,
          );
          break;
        case 'GET':
          response = await http.get(
            url,
            headers: {'Authorization': 'Bearer $apiKey'},
          );
          break;
        case 'DELETE':
          response = await http.delete(
            url,
            headers: {'Authorization': 'Bearer $apiKey'},
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final responseBody = response.body;
      final parsedResponse = json.decode(responseBody);
      if (parsedResponse['error'] != null) {
        throw Exception(parsedResponse['error']['message']);
      }
      print('#' * 30);
      print('Response from Stripe API: $parsedResponse');
      print('#' * 30);

      return parsedResponse;
    } catch (e) {
      throw Exception('Error calling Stripe API: $e');
    }
  }

  Future<Map<String, dynamic>> createCustomer(
    String name,
    String email,
    String addressLine1,
    String addressLine2,
    String city,
    String state,
    String postalCode,
    String country,
    String phone,
  ) async {
    try {
      return _callStripeAPI(
        'customers',
        'POST',
        body: {
          'name': name,
          'email': email,
          'address[line1]': addressLine1,
          'address[line2]': addressLine2,
          'address[city]': city,
          'address[state]': state,
          'address[postal_code]': postalCode,
          'address[country]': country,
          'phone': phone,
        },
      );
    } catch (e) {
      throw Exception('Error creating customer: $e');
    }
  }

  Future<Map<String, dynamic>> updateCustomer(
    String customerId,
    Map<String, dynamic> updates,
  ) async {
    try {
      return _callStripeAPI(
        'customers/$customerId',
        'POST',
        body: updates,
      );
    } catch (e) {
      throw Exception('Error updating customer: $e');
    }
  }

  Future<Map<String, dynamic>> getCustomer(String customerId) async {
    try {
      return _callStripeAPI(
        'customers/$customerId',
        'GET',
      );
    } catch (e) {
      throw Exception('Error getting customer: $e');
    }
  }

  Future<Map<String, dynamic>> setDefaultPaymentMethod(
    String customerId,
    String paymentMethodId,
  ) async {
    try {
      return _callStripeAPI(
        'customers/$customerId',
        'POST',
        body: {
          'invoice_settings[default_payment_method]': paymentMethodId,
        },
      );
    } catch (e) {
      throw Exception('Error setting default payment method: $e');
    }
  }

  Future<Map<String, dynamic>> deleteCustomer(String customerId) async {
    try {
      return _callStripeAPI(
        'customers/$customerId',
        'DELETE',
      );
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }
}
