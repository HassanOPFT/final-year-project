import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:prime/services/google_maps_service.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../views/common/car_address_preview_screen.dart';

class CarAddressImagePreview extends StatelessWidget {
  final String? addressId;

  const CarAddressImagePreview({
    super.key,
    required this.addressId,
  });

  @override
  Widget build(BuildContext context) {
    if (addressId == null || addressId!.isEmpty) {
      return const Center(child: Text('address not available'));
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
          return GestureDetector(
            onTap: () {
              if (address.latitude == null || address.longitude == null) {
                return;
              }
              animatedPushNavigation(
                context: context,
                screen: CarAddressPreviewScreen(
                  latitude: address.latitude,
                  longitude: address.longitude,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address.latitude != null && address.longitude != null)
                  Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: CachedNetworkImage(
                        imageUrl:
                            GoogleMapsService().generateLocationPreviewImage(
                          latitude: address.latitude!,
                          longitude: address.longitude!,
                        ),
                        placeholder: (context, url) => Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const CustomProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}
