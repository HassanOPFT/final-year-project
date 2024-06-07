import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:prime/models/address.dart';

import '../models/auto_complete_results.dart';

class GoogleMapsService {
  final _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  Future<String?> _fetchUrl(Uri uri, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<List<AutoCompleteResult>?> addressAutoComplete(String address) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      'maps/api/place/autocomplete/json',
      {
        'input': address,
        'key': _apiKey,
      },
    );
    String? response = await _fetchUrl(uri);

    if (response == null) {
      return null;
    }
    final parsedResponse = json.decode(response).cast<String, dynamic>();

    if (parsedResponse['status'] != 'OK' ||
        parsedResponse['predictions'] == null) {
      return null;
    }
    List<dynamic> predictions = parsedResponse['predictions'];
    List<AutoCompleteResult> autoCompleteResults = [];

    for (var prediction in predictions) {
      autoCompleteResults.add(AutoCompleteResult.fromJson(prediction));
    }

    return autoCompleteResults;
  }

  Address _addressFromJson(Map<String, dynamic> json) {
    final addressComponents = json['address_components'] as List<dynamic>?;
    final geometry = json['geometry'] as Map<String, dynamic>?;

    String getShortName(List<dynamic>? components, List<String> types) {
      final component = components?.firstWhere(
        (c) =>
            c['types'] != null &&
            List<String>.from(c['types']).any((t) => types.contains(t)),
        orElse: () => {},
      );
      return component != null ? component['long_name'] ?? '' : '';
    }

    return Address(
      street: getShortName(addressComponents, ['route']),
      city: getShortName(addressComponents, ['locality']),
      state: getShortName(addressComponents, ['administrative_area_level_1']),
      postalCode: getShortName(addressComponents, ['postal_code']),
      country: getShortName(addressComponents, ['country']),
      longitude: geometry?['location']?['lng']?.toDouble(),
      latitude: geometry?['location']?['lat']?.toDouble(),
    );
  }

  Future<Address?> getPlaceDetails(String placeId) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      'maps/api/place/details/json',
      {
        'place_id': placeId,
        'key': _apiKey,
      },
    );

    var response = await _fetchUrl(uri);

    if (response == null) {
      return null;
    }

    var jsonResponse = json.decode(response);

    final addressResult = jsonResponse['result'] as Map<String, dynamic>;
    return _addressFromJson(addressResult);
  }

  String generateLocationPreviewImage({
    required double latitude,
    required double longitude,
  }) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=16&size=420x200&maptype=roadmap&markers=color:red%7Clabel:A%7C$latitude,$longitude&key=$_apiKey&scale=2';
  }
}
