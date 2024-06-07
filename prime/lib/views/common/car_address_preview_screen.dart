import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CarAddressPreviewScreen extends StatelessWidget {
  final double? longitude;
  final double? latitude;

  const CarAddressPreviewScreen({
    super.key,
    required this.longitude,
    required this.latitude,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng initialLocation = LatLng(latitude!, longitude!);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Address'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialLocation,
          zoom: 16.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('car-location-marker'),
            position: initialLocation,
          ),
        },
      ),
    );
  }
}
