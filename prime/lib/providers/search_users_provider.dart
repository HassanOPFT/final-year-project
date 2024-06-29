import 'package:flutter/foundation.dart';
import '../models/user.dart';

class SearchUsersProvider with ChangeNotifier {
  List<User> _customersList = [];
  List<User> _filteredCustomers = [];
  bool _isSearchFilterActive = false;

  List<User> get customersList => _customersList;
  List<User> get filteredCustomers => _filteredCustomers;
  bool get isSearchFilterActive => _isSearchFilterActive;

  void setCustomersList(List<User> customers) {
    _customersList = customers;
    notifyListeners();
  }

  void filterCustomers(String query) {
    if (query.isEmpty) {
      _isSearchFilterActive = false;
      _filteredCustomers = [];
    } else {
      _isSearchFilterActive = true;
      final lowerQuery = query.toLowerCase();

      _filteredCustomers = _customersList.where((customer) {
        final matchFirstName =
            customer.userFirstName?.toLowerCase().contains(lowerQuery) ?? false;
        final matchLastName =
            customer.userLastName?.toLowerCase().contains(lowerQuery) ?? false;
        final matchEmail =
            customer.userEmail?.toLowerCase().contains(lowerQuery) ?? false;
        final matchReferenceNumber = customer.userReferenceNumber
                ?.toLowerCase()
                .contains(lowerQuery) ??
            false;
        final matchPhoneNumber = customer.userPhoneNumber
                ?.toLowerCase()
                .contains(lowerQuery) ??
            false;
        final matchUserRole = customer.userRole
                ?.toReadableString()
                .toLowerCase()
                .contains(lowerQuery) ??
            false;

        return matchFirstName ||
            matchLastName ||
            matchEmail ||
            matchReferenceNumber ||
            matchPhoneNumber ||
            matchUserRole;
      }).toList();
    }
    notifyListeners();
  }

  void clearFilters() {
    _isSearchFilterActive = false;
    _filteredCustomers = [];
    notifyListeners();
  }

  bool customersListEquals(List<User> otherList) {
    if (_customersList.length != otherList.length) return false;
    for (int i = 0; i < _customersList.length; i++) {
      if (_customersList[i].userId != otherList[i].userId) {
        return false;
      }
    }
    return true;
  }
}
