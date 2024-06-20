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
      String apiKey = _getStripeAPIKey();
      String baseUrl = 'https://api.stripe.com/v1/charges';

      http.Response response = await http.get(
        Uri.parse('$baseUrl/$chargeId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      StripeCharge stripeCharge = StripeCharge.fromJson(await _handleResponse(response));
      return stripeCharge;
    } catch (e) {
      rethrow;
    }
  }
}

// {
//   "id": "ch_3PQRdm06sxMdZTBd04GrEs3W",
//   "object": "charge",
//   "amount": 3000,
//   "amount_captured": 3000,
//   "amount_refunded": 0,
//   "application": null,
//   "application_fee": null,
//   "application_fee_amount": null,
//   "balance_transaction": "txn_3PQRdm06sxMdZTBd044rvg8G",
//   "billing_details": {
//     "address": {
//       "city": null,
//       "country": "US",
//       "line1": null,
//       "line2": null,
//       "postal_code": "44444",
//       "state": null
//     },
//     "email": null,
//     "name": null,  
//     "phone": null
//   },
//   "calculated_statement_descriptor": "Stripe",
//   "captured": true,
//   "created": 1718100579,
//   "currency": "myr",
//   "customer": "cus_QFswMdwO162OQu",
//   "description": null,
//   "destination": null,
//   "dispute": null,
//   "disputed": false,
//   "failure_balance_transaction": null,
//   "failure_code": null,
//   "failure_message": null,
//   "fraud_details": {},
//   "invoice": null,
//   "livemode": false,
//   "metadata": {},
//   "on_behalf_of": null,
//   "order": null,
//   "outcome": {
//     "network_status": "approved_by_network",
//     "reason": null,
//     "risk_level": "normal",
//     "risk_score": 43,
//     "seller_message": "Payment complete.",
//     "type": "authorized"
//   },
//   "paid": true,
//   "payment_intent": "pi_3PQRdm06sxMdZTBd0BuuKegO",
//   "payment_method": "pm_1PQRe206sxMdZTBdtZ5k41Ta",
//   "payment_method_details": {
//     "card": {
//       "amount_authorized": 3000,
//       "brand": "visa",
//       "checks": {
//         "address_line1_check": null,
//         "address_postal_code_check": "pass",
//         "cvc_check": "pass"
//       },
//       "country": "US",
//       "exp_month": 4,
//       "exp_year": 2044,
//       "extended_authorization": {
//         "status": "disabled"
//       },
//       "fingerprint": "iL0D143BOe1XN1c8",
//       "funding": "credit",
//       "incremental_authorization": {
//         "status": "unavailable"
//       },
//       "installments": null,
//       "last4": "4242",
//       "mandate": null,
//       "multicapture": {
//         "status": "unavailable"
//       },
//       "network": "visa",
//       "network_token": {
//         "used": false
//       },
//       "overcapture": {
//         "maximum_amount_capturable": 3000,
//         "status": "unavailable"
//       },
//       "three_d_secure": null,
//       "wallet": null
//     },
//     "type": "card"
//   },
//   "radar_options": {},
//   "receipt_email": "test@gmail.com",
//   "receipt_number": null,
//   "receipt_url": "https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xT3VpQVUwNnN4TWRaVEJkKNaexLMGMgZ9_ySAm7M6LBZESgwInnW-eTL7Ov8Idr_ETgPiQmkSrvNfbdguFyVLCZzJWTfS81wngBFz",
//   "refunded": false,
//   "review": null,
//   "shipping": null,
//   "source": null,
//   "source_transfer": null,
//   "statement_descriptor": null,
//   "statement_descriptor_suffix": null,
//   "status": "succeeded",
//   "transfer_data": null,
//   "transfer_group": null
// }
