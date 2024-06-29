import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/car.dart';
import '../models/address.dart';
import '../controllers/address_controller.dart';
import 'package:geolocator/geolocator.dart';

class SearchCarsProvider with ChangeNotifier {
  List<Car> _carsList = [];
  List<Car> _filteredCars = [];
  List<Car> _nearestCars = [];
  bool _isSearchFilterActive = false;
  bool _isNearestFilterActive = false;
  LatLng? _userLocation;

  List<Car> get carsList => _carsList;
  List<Car> get filteredCars => _filteredCars;
  List<Car> get nearestCars => _nearestCars;
  bool get isSearchFilterActive => _isSearchFilterActive;
  bool get isNearestFilterActive => _isNearestFilterActive;

  void setCarsList(List<Car> cars) {
    _carsList = cars;
    notifyListeners();
  }

  void filterCars(String query) {
    if (query.isEmpty) {
      clearFilters();
    } else {
      _isSearchFilterActive = true;
      _filteredCars = _carsList.where((car) {
        // car attributes
        final bool matchManufacturer =
            car.manufacturer?.toLowerCase().contains(query.toLowerCase()) ??
                false;
        final bool matchModel =
            car.model?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final bool matchColor =
            car.color?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final bool matchEngineType = car.engineType
                ?.toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ??
            false;
        final bool matchTransmissionType = car.transmissionType
                ?.toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ??
            false;
        final bool matchSeats =
            car.seats?.toString().toLowerCase().contains(query.toLowerCase()) ??
                false;
        final bool matchCarType = car.carType
                ?.toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ??
            false;
        final bool matchHourPrice = car.hourPrice
                ?.toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ??
            false;
        final bool matchDayPrice = car.dayPrice
                ?.toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ??
            false;
        final bool matchReferenceNumber =
            car.referenceNumber?.toLowerCase().contains(query.toLowerCase()) ??
                false;

        return matchManufacturer ||
            matchModel ||
            matchColor ||
            matchEngineType ||
            matchTransmissionType ||
            matchSeats ||
            matchCarType ||
            matchHourPrice ||
            matchDayPrice ||
            matchReferenceNumber;
      }).toList();
    }
    notifyListeners();
  }

  void clearFilters() {
    _isSearchFilterActive = false;
    _filteredCars = [];
    _userLocation = null;
    notifyListeners();
  }

  Future<void> sortCarsByLocation(LatLng userLocation) async {
    _userLocation = userLocation;
    await _sortCarsByDistance();
  }

  Future<void> _sortCarsByDistance() async {
    if (_userLocation == null) return;

    final addressController = AddressController();
    List<Map<String, dynamic>> carsWithDistance = [];

    for (var car in _carsList) {
      if (car.defaultAddressId != null) {
        Address? carAddress =
            await addressController.getAddressById(car.defaultAddressId!);
        if (carAddress.latitude != null && carAddress.longitude != null) {
          double distance = Geolocator.distanceBetween(
            _userLocation!.latitude,
            _userLocation!.longitude,
            carAddress.latitude!,
            carAddress.longitude!,
          );

          carsWithDistance.add({'car': car, 'distance': distance});
        }
      }
    }

    carsWithDistance.sort((a, b) {
      final double carADistance = a['distance'];
      final double carBDistance = b['distance'];

      return (carADistance).compareTo(carBDistance);
    });

    _nearestCars = carsWithDistance.map((e) => e['car'] as Car).toList();
    _isNearestFilterActive = true;
    notifyListeners();
  }
  
  
}
