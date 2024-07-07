import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../models/stripe_payment_method.dart';

class StripePaymentMethodService {
  static const String _baseUrl = 'https://api.stripe.com/v1';
  String _apiKey() => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
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
    } catch (_) {
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
    } catch (_) {
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
      rethrow;
    }
  }

  Future<StripePaymentMethod> retrievePaymentMethod(
    String paymentMethodId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payment_methods/$paymentMethodId'),
        headers: {
          'Authorization': 'Bearer ${_apiKey()}',
        },
      );
      final Map<String, dynamic> responseData = await _handleResponse(response);
      return StripePaymentMethod.fromMap(responseData);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StripePaymentMethod>> listCustomerPaymentMethods(
    String customerId, {
    int? limit,
    String? endingBefore,
    String? startingAfter,
  }) async {
    try {
      final Uri uri =
          Uri.parse('$_baseUrl/customers/$customerId/payment_methods');
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
      final Map<String, dynamic> responseData = await _handleResponse(response);
      final List<dynamic> data = responseData['data'];
      return data.map((item) => StripePaymentMethod.fromMap(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Future<Map<String, dynamic>> retrievePaymentMethod(
  //   String paymentMethodId,
  // ) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/payment_methods/$paymentMethodId'),
  //       headers: {
  //         'Authorization': 'Bearer ${_apiKey()}',
  //       },
  //     );
  //     return _handleResponse(response);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<Map<String, dynamic>> listCustomerPaymentMethods(
  //   String customerId, {
  //   int? limit,
  //   String? endingBefore,
  //   String? startingAfter,
  // }) async {
  //   try {
  //     final Uri uri = Uri.parse(
  //       '$_baseUrl/customers/$customerId/payment_methods',
  //     );
  //     final Map<String, dynamic> queryParams = {};
  //     if (limit != null) queryParams['limit'] = limit.toString();
  //     if (endingBefore != null) queryParams['ending_before'] = endingBefore;
  //     if (startingAfter != null) queryParams['starting_after'] = startingAfter;

  //     final response = await http.get(
  //       uri.replace(queryParameters: queryParams),
  //       headers: {
  //         'Authorization': 'Bearer ${_apiKey()}',
  //       },
  //     );
  //     return _handleResponse(response);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

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
      rethrow;
    }
  }
}
