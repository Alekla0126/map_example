import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

Future<LatLng> fetchCurrentLocation(LatLng fallbackLocation) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      debugPrint('Location services are disabled.');
      return fallbackLocation;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    debugPrint('Error fetching location: $e');
    return fallbackLocation;
  }
}