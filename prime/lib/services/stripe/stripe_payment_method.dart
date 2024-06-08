import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StripePaymentMethod {
  static const String _baseUrl = 'https://api.stripe.com/v1';
  String _apiKey() => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('#' * 40);
      print('Failed to load data: ${response.body}');
      print('#' * 40);

      throw Exception('Failed to load data: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createPaymentMethod(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_methods'),
        headers: {
          'Authorization': 'Bearer ${_apiKey()}',
        },
        body: data,
      );
      return _handleResponse(response);
    } catch (e) {
      print('Failed to create payment method: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePaymentMethod(
    String paymentMethodId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_methods/$paymentMethodId'),
        headers: {
          'Authorization': 'Bearer ${_apiKey()}',
        },
        body: data,
      );
      return _handleResponse(response);
    } catch (e) {
      print('Failed to update payment method: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> retrieveCustomerPaymentMethod(
    String customerId,
    String paymentMethodId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/customers/$customerId/payment_methods/$paymentMethodId',
        ),
        headers: {
          'Authorization': 'Bearer ${_apiKey()}',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      print('Failed to retrieve customer payment method: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> retrievePaymentMethod(
    String paymentMethodId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payment_methods/$paymentMethodId'),
        headers: {
          'Authorization': 'Bearer ${_apiKey()}',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      print('Failed to retrieve payment method: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> listCustomerPaymentMethods(
    String customerId, {
    int? limit,
    String? endingBefore,
    String? startingAfter,
  }) async {
    try {
      final Uri uri = Uri.parse(
        '$_baseUrl/customers/$customerId/payment_methods',
      );
      final Map<String, dynamic> queryParams = {};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (endingBefore != null) queryParams['ending_before'] = endingBefore;
      if (startingAfter != null) queryParams['starting_after'] = startingAfter;

      final response = await http.get(
        uri.replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer ${_apiKey()}',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      print('Failed to list customer payment methods: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> attachPaymentMethodToCustomer(
    String paymentMethodId,
    String customerId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_methods/$paymentMethodId/attach'),
        headers: {
          'Authorization': 'Bearer ${_apiKey()}',
        },
        body: {
          'customer': customerId,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      print('Failed to attach payment method to customer: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> detachPaymentMethodFromCustomer(
    String paymentMethodId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_methods/$paymentMethodId/detach'),
        headers: {
          'Authorization': 'Bearer ${_apiKey()}',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      print('Failed to detach payment method from customer: $e');
      rethrow;
    }
  }
}
