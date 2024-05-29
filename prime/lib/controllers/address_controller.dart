import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/address.dart';

class AddressController {
  static const String _addressCollectionName = 'Address';
  static const String _linkedObjectIdFieldName = 'linkedObjectId';
  static const String _streetFieldName = 'street';
  static const String _cityFieldName = 'city';
  static const String _stateFieldName = 'state';
  static const String _postalCodeFieldName = 'postalCode';
  static const String _countryFieldName = 'country';
  static const String _longitudeFieldName = 'longitude';
  static const String _latitudeFieldName = 'latitude';
  static const String _labelFieldName = 'label';

  final _addressCollection =
      FirebaseFirestore.instance.collection(_addressCollectionName);
  Future<String> createAddress(Address address) async {
    try {
      if (address.linkedObjectId == null) {
        throw Exception('linkedObjectId is required');
      }
      final newAddress = await _addressCollection.add({
        _linkedObjectIdFieldName: address.linkedObjectId ?? '',
        _streetFieldName: address.street ?? '',
        _cityFieldName: address.city ?? '',
        _stateFieldName: address.state ?? '',
        _postalCodeFieldName: address.postalCode ?? '',
        _countryFieldName: address.country ?? '',
        _longitudeFieldName: address.longitude ?? '',
        _latitudeFieldName: address.latitude ?? '',
        _labelFieldName: address.label ?? '',
      });

      return newAddress.id;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Address>> getAddresses(String linkedObjectId) async {
    try {
      final querySnapshot = await _addressCollection
          .where(_linkedObjectIdFieldName, isEqualTo: linkedObjectId)
          .get();

      final addresses = querySnapshot.docs
          .map(
            (doc) => _fromMap(doc.id, doc.data()),
          )
          .toList();

      return addresses;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Address _fromMap(String? addressId, Map<String, dynamic> data) {
    return Address(
      id: addressId ?? '',
      linkedObjectId: data[_linkedObjectIdFieldName] ?? '',
      street: data[_streetFieldName] ?? '',
      city: data[_cityFieldName] ?? '',
      state: data[_stateFieldName] ?? '',
      postalCode: data[_postalCodeFieldName] ?? '',
      country: data[_countryFieldName] ?? '',
      longitude: data[_longitudeFieldName] ?? 0.0,
      latitude: data[_latitudeFieldName] ?? 0.0,
      label: data[_labelFieldName] ?? '',
    );
  }

  Future<Address> getAddressById(String addressId) async {
    try {
      final doc = await _addressCollection.doc(addressId).get();
      if (!doc.exists) {
        throw Exception('Address not found');
      }

      return _fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
      if (address.id == null || address.id!.isEmpty) {
        throw Exception('Address ID is required for updating.');
      }

      final addressData = {
        _streetFieldName: address.street ?? '',
        _cityFieldName: address.city ?? '',
        _stateFieldName: address.state ?? '',
        _postalCodeFieldName: address.postalCode ?? '',
        _countryFieldName: address.country ?? '',
        _longitudeFieldName: address.longitude ?? '',
        _latitudeFieldName: address.latitude ?? '',
        _labelFieldName: address.label ?? '',
      };

      await _addressCollection.doc(address.id).update(addressData);
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _addressCollection.doc(addressId).delete();
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
