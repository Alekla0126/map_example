import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

void updateMarkers(
  List<Marker> markers,
  List<Map<String, dynamic>> events,
  Set<String> favoriteIds,
) {
  markers.clear();
  markers.addAll(
    events.map((event) {
      final id = event['id'] ?? 'unknown-id';
      final isFavorite = favoriteIds.contains(id);

      return Marker(
        point: event['point'] as LatLng,
        width: 50.0,
        height: 50.0,
        child: GestureDetector(
          onTap: () {
            // Logic for marker popup or interaction
          },
          child: Icon(
            Icons.location_on,
            color: isFavorite ? Colors.red : Colors.green,
            size: 50.0,
          ),
        ),
      );
    }).toList(),
  );
}