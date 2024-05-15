import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prime/utils/assets_paths.dart';
import 'package:provider/provider.dart';

import '../models/address.dart';
import '../providers/address_provider.dart';
import '../providers/customer_provider.dart';
import '../utils/navigate_with_animation.dart';
import '../views/common/google_maps_screen.dart';
import 'edit_address_bottom_sheet.dart';

class AddressDetailsTile extends StatelessWidget {
  final Address address;
  final bool isDefault;
  const AddressDetailsTile({
    super.key,
    required this.address,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );

    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    void setDefaultAddress() async {
      if (address.id == null ||
          address.id!.isEmpty ||
          address.linkedObjectId == null ||
          address.linkedObjectId!.isEmpty) {
        return;
      }
      await customerProvider.setDefaultAddress(
        userId: address.linkedObjectId!,
        addressId: address.id!,
      );
    }

    void updateAddress() {
      if (address.id == null ||
          address.id!.isEmpty ||
          address.linkedObjectId == null ||
          address.linkedObjectId!.isEmpty) {
        return;
      }
      animatedPushNavigation(
        context: context,
        screen: GoogleMapsScreen(
          initialLocation: LatLng(
            address.latitude as double,
            address.longitude as double,
          ),
          addressId: address.id,
          linkedObjectId: address.linkedObjectId!,
          addressPurpose: AddressPurpose.user,
          addressAction: AddressAction.update,
        ),
      );
    }

    Future<bool> confirmDeleteAddress() async {
      bool isConfirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AssetsPaths.binImage,
                  height: 200.0,
                ),
                const Text(
                  'Are you sure you want to delete this address? this action cannot be undone.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      return isConfirmed;
    }

    Future<void> deleteAddress() async {
      if (address.id == null || address.id!.isEmpty) {
        return;
      }
      bool confirmDeletion = await confirmDeleteAddress();
      if (!confirmDeletion) {
        return;
      }
      await addressProvider.deleteAddress(address.id!);

      if (isDefault && address.linkedObjectId != null) {
        await customerProvider.deleteDefaultAddress(address.linkedObjectId!);
      }
    }

    void showEditAddressBottomSheet() {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (BuildContext context) {
          return EditAddressBottomSheet(
            setAddressAsDefault: setDefaultAddress,
            updateAddress: updateAddress,
            deleteAddress: deleteAddress,
            isDefault: isDefault,
          );
        },
      );
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            Text(
              address.label ?? 'Label',
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
        subtitle: Text(
          address.toString(),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: showEditAddressBottomSheet,
        ),
      ),
    );
  }
}
