import 'package:flutter/material.dart';

import '../controllers/address_controller.dart';
import '../models/address.dart';

class AddressProvider extends ChangeNotifier {
  final _addressController = AddressController();

  Future<String> createAddress(Address address) async {
    try {
      final newAddressId = await _addressController.createAddress(address);
      notifyListeners();
      return newAddressId;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Address>> getAddresses(String linkedObjectId) async {
    try {
      final addresses = await _addressController.getAddresses(linkedObjectId);
      return addresses;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
      await _addressController.updateAddress(address);
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _addressController.deleteAddress(addressId);
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }
}
