import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../helpers/map_helpers.dart';

class MapView extends StatelessWidget {
  final MapController mapController;
  final LatLng currentLocation;
  final List<Marker> allMarkers;
  final bool isDarkMode;

  const MapView({
    required this.mapController,
    required this.currentLocation,
    required this.allMarkers,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: generateMapboxUrl(isDarkMode),
        ),
        MarkerLayer(
          markers: allMarkers,
        ),
      ],
    );
  }
}