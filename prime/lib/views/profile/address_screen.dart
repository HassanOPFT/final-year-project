import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/no_data_found.dart';
import '../../providers/customer_provider.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../widgets/floating_action_button/add_address_floating_action_button.dart';
import '../../widgets/custom_progress_indicator.dart';
import '../../widgets/tiles/address_details_tile.dart';
import '../../providers/user_provider.dart';
import '../common/google_maps_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  String? userId;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      userId = userProvider.user!.userId;
    }
    final addressProvider = Provider.of<AddressProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder(
          future: Future.wait([
            addressProvider.getAddresses(userId ?? ''),
            customerProvider.getDefaultAddress(userId ?? ''),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomProgressIndicator();
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching addresses'));
            } else {
              final List<dynamic> data = snapshot.data as List<dynamic>;
              final List<Address> addresses = data[0] as List<Address>;
              final String defaultAddressId = data[1] as String;

              if (addresses.isNotEmpty && defaultAddressId.isNotEmpty) {
                int defaultAddressIndex = addresses
                    .indexWhere((address) => address.id == defaultAddressId);

                // Rearrange the list if the default address is found
                if (defaultAddressIndex != -1) {
                  Address defaultAddress = addresses[defaultAddressIndex];
                  addresses.removeAt(defaultAddressIndex);
                  addresses.insert(0, defaultAddress);
                }
              }

              // check if the list is empty display No Data Found
              if (addresses.isEmpty) {
                return const NoDataFound(
                  title: 'No Addresses Found',
                  subTitle:
                      'It looks like you haven\'t added any addresses yet.',
                );
              }

              return ListView.builder(
                itemCount: addresses.length,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 80.0,
                ),
                itemBuilder: (context, index) {
                  final address = addresses[index];

                  final bool isDefaultAddress = address.id == defaultAddressId;

                  return AddressDetailsTile(
                    address: address,
                    isDefault: isDefaultAddress,
                    addressPurpose: AddressPurpose.user,
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: AddAddressFloatingActionButton(userId: userId),
    );
  }
}
