import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Marker> _markers = [];
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _events = [];
  final List<Map<String, dynamic>> _suggestions = [];
  final String _mapboxAccessToken =
      "pk.eyJ1IjoiYWxla2xhMDEyNiIsImEiOiJjbGp0NTNvd2UwM2RnM2VtbDlieHkwNTBiIn0.oEhomSTKaUBKdzIw2cyeSw";

  bool _isDarkMode = false;
  Map<String, dynamic>? _selectedEvent;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadEventsFromUrl();
    _searchController.addListener(() {
      _updateSuggestions(_searchController.text);
    });
  }

  Future<void> _loadEventsFromUrl() async {
    final String url =
        "https://run.mocky.io/v3/1f08971f-0f75-444f-ae7d-2a5d7c9a7b7b";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        for (final event in jsonData) {
          final double lat = event['latitude'];
          final double lng = event['longitude'];
          final String eventName = event['name'];

          final marker = Marker(
            point: LatLng(lat, lng),
            width: 80.0,
            height: 80.0,
            child: GestureDetector(
              onTap: () {
                _showMarkerInfo(event);
              },
              child: Icon(
                Icons.location_on,
                color: Colors.green,
                size: 30.0,
              ),
            ),
          );

          _events.add({
            'name': eventName,
            'lat': lat,
            'lng': lng,
            'description': event['description'],
            'date': event['date'],
            'marker': marker,
          });

          _markers.add(marker);
        }

        setState(() {});
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
        _markers.clear();
        _markers.addAll(_events.map((event) => event['marker'] as Marker));
      });
      return;
    }

    final filteredSuggestions = _events.where((event) {
      final name = event['name'] as String;
      return name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _suggestions.clear();
      _suggestions.addAll(filteredSuggestions);
      _markers.clear();
      _markers.addAll(filteredSuggestions.map((event) => event['marker']));
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _suggestions.clear();
      _markers.clear();
      _markers.addAll(_events.map((event) => event['marker'] as Marker));
      _selectedEvent = null;
    });
  }

  void _showMarkerInfo(Map<String, dynamic> event) {
    setState(() {
      _selectedEvent = event;
    });
  }

  void _addMarker() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final descriptionController = TextEditingController();
        final latitudeController = TextEditingController();
        final longitudeController = TextEditingController();

        return AlertDialog(
          title: Text('Add a Marker'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: latitudeController,
                  decoration: InputDecoration(labelText: 'Latitude'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: longitudeController,
                  decoration: InputDecoration(labelText: 'Longitude'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final description = descriptionController.text;
                final lat = double.tryParse(latitudeController.text) ?? 0.0;
                final lng = double.tryParse(longitudeController.text) ?? 0.0;

                if (name.isNotEmpty && description.isNotEmpty) {
                  final newMarker = Marker(
                    point: LatLng(lat, lng),
                    width: 80.0,
                    height: 80.0,
                    child: GestureDetector(
                      onTap: () => _showMarkerInfo({
                        'name': name,
                        'description': description,
                        'lat': lat,
                        'lng': lng,
                        'date': 'N/A'
                      }),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30.0,
                      ),
                    ),
                  );

                  setState(() {
                    _events.add({
                      'name': name,
                      'lat': lat,
                      'lng': lng,
                      'description': description,
                      'date': 'N/A',
                      'marker': newMarker,
                    });
                    _markers.add(newMarker);
                  });

                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
              heroTag: "darkModeToggle",
              child: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: _addMarker,
              heroTag: "addMarker",
              child: Icon(Icons.add),
            ),
          ],
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(7.8804, 98.3923),
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=$_mapboxAccessToken",
                  additionalOptions: {
                    'accessToken': _mapboxAccessToken,
                    'id': _isDarkMode ? "mapbox/dark-v10" : "mapbox/light-v10",
                  },
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Material(
                    elevation: 2.0,
                    borderRadius: BorderRadius.circular(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search for an event...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10.0),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: _clearSearch,
                        ),
                      ),
                    ),
                  ),
                  if (_suggestions.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ListTile(
                            title: Text(suggestion['name']),
                            onTap: () {
                              _showMarkerInfo(suggestion);
                              _mapController.move(
                                LatLng(suggestion['lat'], suggestion['lng']),
                                14,
                              );
                              _searchController.text = suggestion['name'];
                              setState(() => _suggestions.clear());
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (_selectedEvent != null)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedEvent!['name'],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Date: ${_selectedEvent!['date']}",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _selectedEvent!['description'],
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
