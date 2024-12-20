import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

void showAddMarkerDialog(
  BuildContext context,
  List<Map<String, dynamic>> events,
  List<Marker> markers,
  Set<String> favoriteIds, // Added favoriteIds for managing favorites
) {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add a Marker'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
              TextField(controller: latitudeController, decoration: InputDecoration(labelText: 'Latitude')),
              TextField(controller: longitudeController, decoration: InputDecoration(labelText: 'Longitude')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = nameController.text;
              final description = descriptionController.text;
              final lat = double.tryParse(latitudeController.text) ?? 0.0;
              final lng = double.tryParse(longitudeController.text) ?? 0.0;

              if (name.isNotEmpty && description.isNotEmpty) {
                final newId = '${lat}_$lng'; // Unique ID for the marker

                markers.add(
                  Marker(
                    point: LatLng(lat, lng),
                    width: 30.0,
                    height: 30.0,
                    child: GestureDetector(
                      onTap: () {
                        if (favoriteIds.contains(newId)) {
                          favoriteIds.remove(newId);
                        } else {
                          favoriteIds.add(newId);
                        }
                      },
                      child: Icon(
                        Icons.location_on,
                        color: favoriteIds.contains(newId) ? Colors.green : Colors.red,
                        size: 30.0,
                      ),
                    ),
                  ),
                );

                events.add({
                  'id': newId,
                  'name': name,
                  'lat': lat,
                  'lng': lng,
                  'description': description,
                });

                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}