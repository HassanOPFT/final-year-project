import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../utils/navigate_with_animation.dart';
import '../utils/snackbar.dart';
import '../views/common/google_maps_screen.dart';
import 'custom_progress_indicator.dart';

class AddAddressFloatingButton extends StatefulWidget {
  final String? userId;

  const AddAddressFloatingButton({
    super.key,
    this.userId,
  });

  @override
  State<AddAddressFloatingButton> createState() =>
      _AddAddressFloatingButtonState();
}

class _AddAddressFloatingButtonState extends State<AddAddressFloatingButton> {
  bool _addAddressLoading = false;

  Future<void> _addAddressOnMap() async {
    setState(() {
      _addAddressLoading = true;
    });
    final location = Location();
    final permissionStatus = await location.hasPermission();
    if (permissionStatus != PermissionStatus.granted &&
        permissionStatus != PermissionStatus.grantedLimited) {
      final response = await location.requestPermission();
      if (response != PermissionStatus.granted &&
          response != PermissionStatus.grantedLimited) {
        setState(() {
          _addAddressLoading = false;
        });
        if (mounted) {
          if (widget.userId != null) {
            animatedPushNavigation(
              context: context,
              screen: GoogleMapsScreen(
                linkedObjectId: widget.userId!,
                addressPurpose: AddressPurpose.user,
                addressAction: AddressAction.create,
              ),
            );
          } else {
            buildFailureSnackbar(
              context: context,
              message: 'Error occurred. Please try again later.',
            );
          }
        }
      }
    }
    final currentLocation = await location.getLocation();
    final initialLocation = LatLng(
      currentLocation.latitude ?? 40.730610,
      currentLocation.longitude ?? -73.935242,
    );

    setState(() {
      _addAddressLoading = false;
    });
    if (mounted) {
      if (widget.userId != null) {
        animatedPushNavigation(
          context: context,
          screen: GoogleMapsScreen(
            initialLocation: initialLocation,
            linkedObjectId: widget.userId!,
            addressPurpose: AddressPurpose.user,
            addressAction: AddressAction.create,
          ),
        );
      } else {
        buildFailureSnackbar(
          context: context,
          message: 'Error occurred. Please try again later.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _addAddressOnMap,
      label: _addAddressLoading
          ? const CustomProgressIndicator()
          : const Text('Add Address'),
      icon: _addAddressLoading
          ? null
          : const Icon(Icons.add_location_alt_rounded),
    );
  }
}
