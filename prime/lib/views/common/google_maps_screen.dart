import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/snackbar.dart';
import '../../widgets/address_form.dart';
import '../../models/address.dart';
import '../../widgets/address_search_bar.dart';

enum AddressPurpose {
  user,
  car,
}

enum AddressAction {
  create,
  update,
}

class GoogleMapsScreen extends StatefulWidget {
  final LatLng initialLocation;
  final String? addressId;
  final String linkedObjectId;
  final AddressPurpose addressPurpose;
  final AddressAction addressAction;

  const GoogleMapsScreen({
    super.key,
    this.initialLocation = const LatLng(40.730610, -73.935242),
    this.addressId,
    required this.linkedObjectId,
    required this.addressPurpose,
    required this.addressAction,
  });

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? _googleMapController;
  Address? _selectedAddress;
  Marker? _marker;

  @override
  void initState() {
    _marker = Marker(
      markerId: MarkerId(DateTime.now().toString()),
      position: widget.initialLocation,
    );
    super.initState();
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      _googleMapController = controller;
    });
    selectLocationOnTap(widget.initialLocation);
  }

  void _updateMapMarker(LatLng latLng) {
    setState(() {
      _marker = Marker(
        markerId: MarkerId(DateTime.now().toString()),
        position: latLng,
      );
      _googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: 16.0,
          ),
        ),
      );
    });
  }

  Future<void> selectLocationOnTap(LatLng latLng) async {
    _updateMapMarker(latLng);

    final geocodingPlatformInstance = GeocodingPlatform.instance;

    if (geocodingPlatformInstance != null) {
      final address = Address();

      final addresses =
          await geocodingPlatformInstance.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (addresses.isNotEmpty) {
        address.street = addresses[0].street;
        address.city = addresses[0].locality;
        address.state = addresses[0].administrativeArea;
        address.postalCode = addresses[0].postalCode;
        address.country = addresses[0].country;
        address.latitude = latLng.latitude;
        address.longitude = latLng.longitude;
        setState(() {
          _selectedAddress = address;
        });
      }
    }
  }

  void selectAddressFromSearch(Address address) {
    if (_googleMapController == null) {
      return;
    }
    if (address.latitude == null || address.longitude == null) {
      return;
    }
    setState(() {
      _selectedAddress = address;
    });
    final selectedCoordinates = LatLng(address.latitude!, address.longitude!);
    _updateMapMarker(selectedCoordinates);
  }

  void _showAddressSelectionBottomSheet() {
    _selectedAddress!.linkedObjectId = widget.linkedObjectId;
    if (_selectedAddress!.linkedObjectId == null) {
      buildFailureSnackbar(
        context: context,
        message: 'Something went wrong. Please try again later.',
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: true,
      barrierLabel: 'Address Details',
      isScrollControlled: true,
      builder: (BuildContext context) {
        if (widget.addressAction == AddressAction.update) {
          _selectedAddress!.id = widget.addressId;
        }
        return Container(
          padding: EdgeInsets.fromLTRB(
            20.0,
            0.0,
            20.0,
            MediaQuery.of(context).viewInsets.bottom + 20.0,
          ),
          child: AddressForm(
            selectedAddress: _selectedAddress!,
            addressPurpose: widget.addressPurpose,
            addressAction: widget.addressAction,
          ),
        );
      },
    );
  }

  _selectAddressWarning() {
    buildAlertSnackbar(
      context: context,
      message: 'Please select a valid address first.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            key: const ValueKey('google-map'),
            onMapCreated: onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation,
              zoom: 16.0,
            ),
            onTap: selectLocationOnTap,
            markers: {
              if (_marker != null) _marker!,
            },
          ),
          Positioned(
            top: 45.0,
            right: 10.0,
            left: 10.0,
            child: AddressSearchBar(selectAddress: selectAddressFromSearch),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedAddress != null
            ? _showAddressSelectionBottomSheet
            : _selectAddressWarning,
        label: const Text('Select Address'),
        icon: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
