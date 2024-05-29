import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address.dart';
import '../providers/address_provider.dart';

class AdminCarAddress extends StatelessWidget {
  final String? addressId;

  const AdminCarAddress({
    super.key,
    required this.addressId,
  });

  @override
  Widget build(BuildContext context) {
    if (addressId == null || addressId!.isEmpty) {
      return const Center(child: Text('No address associated'));
    }

    return FutureBuilder<Address?>(
      future: Provider.of<AddressProvider>(
        context,
        listen: false,
      ).getAddressById(addressId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading address'));
        } else if (snapshot.data == null) {
          return const Center(child: Text('Address not found'));
        } else {
          final address = snapshot.data!;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
              subtitle: Text(address.toString()),
            ),
          );
        }
      },
    );
  }
}
