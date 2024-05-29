// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:prime/widgets/address_details_tile.dart';
import 'package:provider/provider.dart';

import '../models/address.dart';
import '../providers/address_provider.dart';
import '../../views/common/google_maps_screen.dart';
import '../../utils/navigate_with_animation.dart';
import '../../utils/snackbar.dart';

class HostCarAddress extends StatefulWidget {
  final String carDefaultAddressId;
  final String carId;

  const HostCarAddress({
    super.key,
    required this.carDefaultAddressId,
    required this.carId,
  });

  @override
  State<HostCarAddress> createState() => _HostCarAddressState();
}

class _HostCarAddressState extends State<HostCarAddress> {
  bool isAddAddressOnMapLoading = false;

  void _setAddAddressOnMapLoading(bool loading) {
    setState(() {
      isAddAddressOnMapLoading = loading;
    });
  }

  Future<void> _addAddressOnMap(BuildContext context) async {
    _setAddAddressOnMapLoading(true);
    final location = Location();
    final permissionStatus = await location.hasPermission();
    if (permissionStatus != PermissionStatus.granted &&
        permissionStatus != PermissionStatus.grantedLimited) {
      final response = await location.requestPermission();
      if (response != PermissionStatus.granted &&
          response != PermissionStatus.grantedLimited) {
        _setAddAddressOnMapLoading(false);
        buildFailureSnackbar(
          context: context,
          message: 'Error occurred. Please try again later.',
        );
        return;
      }
    }
    final currentLocation = await location.getLocation();
    final initialLocation = LatLng(
      currentLocation.latitude ?? 40.730610,
      currentLocation.longitude ?? -73.935242,
    );

    _setAddAddressOnMapLoading(false);
    animatedPushNavigation(
      context: context,
      screen: GoogleMapsScreen(
        initialLocation: initialLocation,
        linkedObjectId: widget.carId,
        addressPurpose: AddressPurpose.car,
        addressAction: AddressAction.create,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.carDefaultAddressId.isNotEmpty
        ? FutureBuilder<Address>(
            future: Provider.of<AddressProvider>(
              context,
              listen: false,
            ).getAddressById(widget.carDefaultAddressId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading address.'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                    child: Text('Address details not available.'));
              } else {
                final address = snapshot.data!;
                return AddressDetailsTile(
                  address: address,
                  isDefault: true,
                  addressPurpose: AddressPurpose.car,
                );
              }
            },
          )
        : Center(
            child: isAddAddressOnMapLoading
                ? const CircularProgressIndicator()
                : FilledButton.icon(
                    onPressed: () => _addAddressOnMap(context),
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: const Text('Add Car Address'),
                  ),
          );
  }
}
