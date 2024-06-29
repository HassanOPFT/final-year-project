import 'package:flutter/foundation.dart';
import 'package:prime/models/car_rental.dart';

import '../models/car.dart';
import '../models/user.dart';

class SearchRentalsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _rentalsList = [];
  List<Map<String, dynamic>> _filteredRentals = [];
  bool _isSearchFilterActive = false;

  List<Map<String, dynamic>> get rentalsList => _rentalsList;
  List<Map<String, dynamic>> get filteredRentals => _filteredRentals;
  bool get isSearchFilterActive => _isSearchFilterActive;

  void setRentalsList(List<Map<String, dynamic>> rentals) {
    _rentalsList = rentals;
    notifyListeners();
  }

  void filterRentals(String query) {
    if (query.isEmpty) {
      _isSearchFilterActive = false;
      _filteredRentals = [];
    } else {
      _isSearchFilterActive = true;
      _filteredRentals = _rentalsList.where((rental) {
        final Car car = rental['car'];
        final CarRental rentalData = rental['rental'];
        final lowerQuery = query.toLowerCase();

        // Car attributes
        final bool matchManufacturer =
            car.manufacturer?.toLowerCase().contains(lowerQuery) ?? false;
        final bool matchModel =
            car.model?.toLowerCase().contains(lowerQuery) ?? false;
        final bool matchManufactureYear =
            car.manufactureYear?.toString().contains(lowerQuery) ?? false;
        final bool matchColor =
            car.color?.toLowerCase().contains(lowerQuery) ?? false;
        final bool matchEngineType = car.engineType?.engineTypeString
                .toLowerCase()
                .contains(lowerQuery) ??
            false;
        final bool matchTransmissionType = car
                .transmissionType?.transmissionTypeString
                .toLowerCase()
                .contains(lowerQuery) ??
            false;
        final bool matchSeats =
            car.seats?.toString().contains(lowerQuery) ?? false;
        final bool matchCarType = car.carType
                ?.getCarTypeString()
                .toLowerCase()
                .contains(lowerQuery) ??
            false;
        final bool matchHourPrice =
            car.hourPrice?.toString().contains(lowerQuery) ?? false;
        final bool matchDayPrice =
            car.dayPrice?.toString().contains(lowerQuery) ?? false;
        final bool matchReferenceNumber =
            car.referenceNumber?.toLowerCase().contains(lowerQuery) ?? false;

        // CarRental attributes
        final bool matchStartDate = rentalData.startDate
                ?.toString()
                .toLowerCase()
                .contains(lowerQuery) ??
            false;
        final bool matchEndDate =
            rentalData.endDate?.toString().toLowerCase().contains(lowerQuery) ??
                false;
        final bool matchRentalStatus = rentalData.status
                ?.getStatusString(UserRole.primaryAdmin)
                .toLowerCase()
                .contains(lowerQuery) ??
            false;
        final bool matchRentalReferenceNumber =
            rentalData.referenceNumber?.toLowerCase().contains(lowerQuery) ??
                false;

        return matchManufacturer ||
            matchModel ||
            matchManufactureYear ||
            matchColor ||
            matchEngineType ||
            matchTransmissionType ||
            matchSeats ||
            matchCarType ||
            matchHourPrice ||
            matchDayPrice ||
            matchReferenceNumber ||
            matchStartDate ||
            matchEndDate ||
            matchRentalStatus ||
            matchRentalReferenceNumber;
      }).toList();
    }
    notifyListeners();
  }

  void clearFilters() {
    _isSearchFilterActive = false;
    _filteredRentals = [];
    notifyListeners();
  }

  bool rentalsListEquals(List<Map<String, dynamic>> otherList) {
    if (_rentalsList.length != otherList.length) return false;
    for (int i = 0; i < _rentalsList.length; i++) {
      if (_rentalsList[i]['car'].id != otherList[i]['car'].id ||
          _rentalsList[i]['rental'].id != otherList[i]['rental'].id) {
        return false;
      }
    }
    return true;
  }
}
