import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:math';

List<Map<String, dynamic>> generateRandomEventsWithNames({
  required LatLng center,
  required int count,
  required double radiusInMeters,
}) {
  final List<Map<String, String>> eventDetails = [
    {
      'name': 'Food Festival',
      'description': 'A culinary celebration with local dishes.'
    },
    {
      'name': 'Music Concert',
      'description': 'Live music performances by various artists.'
    },
    {
      'name': 'Art Exhibition',
      'description': 'An inspiring display of local artwork.'
    },
    {
      'name': 'Outdoor Yoga',
      'description': 'Relax with yoga sessions in nature.'
    },
    {'name': 'Marathon', 'description': 'Run and enjoy scenic views.'},
  ];

  final random = Random();
  return List.generate(count, (_) {
    final angle = random.nextDouble() * 2 * pi;
    final distance = random.nextDouble() * radiusInMeters;
    final offsetLat = (distance * cos(angle)) / 111320;
    final offsetLng = (distance * sin(angle)) / (111320 * cos(center.latitude * pi / 180));
    final randomEvent = eventDetails[random.nextInt(eventDetails.length)];

    return {
      'point': LatLng(center.latitude + offsetLat, center.longitude + offsetLng),
      'name': randomEvent['name'],
      'description': randomEvent['description'],
      'marker': Marker(
        point: LatLng(center.latitude + offsetLat, center.longitude + offsetLng),
        width: 30.0,
        height: 30.0,
        child: Icon(Icons.location_on, color: Colors.green, size: 30.0),
      ),
    };
  });
}

List<Map<String, dynamic>> addUniqueIdsToEvents(
  List<Map<String, dynamic>> events,
) {
  return events.asMap().entries.map((entry) {
    final index = entry.key;
    final event = entry.value;
    return {
      ...event,
      'id': event['id'] ?? 'event-$index',
    };
  }).toList();
}

void updateSuggestions(
  String query,
  List<Map<String, dynamic>> events,
  List<Map<String, dynamic>> filteredEvents,
  List<Marker> allMarkers,
) {
  if (query.isEmpty) {
    filteredEvents.clear();
    allMarkers.clear();
    allMarkers.addAll(events.map((event) => event['marker'] as Marker));
    return;
  }

  final filtered = events.where((event) {
    final name = event['name'] ?? '';
    return name.toLowerCase().contains(query.toLowerCase());
  }).toList();

  filteredEvents.clear();
  filteredEvents.addAll(filtered);
  allMarkers.clear();
  allMarkers.addAll(filtered.map((event) => event['marker'] as Marker));
}

Future<List<Map<String, dynamic>>> fetchEvents() async {
  const url = "https://run.mocky.io/v3/1f08971f-0f75-444f-ae7d-2a5d7c9a7b7b";
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((event) {
        return {
          'name': event['name'],
          'lat': event['latitude'],
          'lng': event['longitude'],
          'description': event['description'],
          'date': event['date'],
          'marker': Marker(
            point: LatLng(event['latitude'], event['longitude']),
            width: 80.0,
            height: 80.0,
            child: Icon(Icons.location_on, color: Colors.green, size: 30.0),
          ),
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch events');
    }
  } catch (e) {
    print('Error fetching events: $e');
    return [];
  }
}