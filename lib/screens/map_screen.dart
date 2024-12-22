import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/unread_messages_bloc.dart';
import '../widgets/floating_action_buttons_widget.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_map/flutter_map.dart';
import '../reducers/dark_mode_reducer.dart';
import '../widgets/search_bar_widget.dart';
import '../helpers/location_helpers.dart';
import '../widgets/map_view_widget.dart';
import '../helpers/event_helpers.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../helpers/ui_helper.dart';
import 'chat_screen_list.dart';
import 'favourites_screen.dart';
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Marker> _allMarkers = [];
  final List<Map<String, dynamic>> _events = [];
  final List<Map<String, dynamic>> _favorites = [];
  final Set<String> favoriteIds = {};

  late MapController _mapController;
  LatLng _currentLocation = LatLng(7.8804, 98.3923);

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _filteredEvents = [];

  // Open chat screen
  void _openChatList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<UnreadMessagesBloc>(),
          child: ChatListScreen(events: _events),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMap();
    _loadFavorites(); // Load favorites from SharedPreferences
    _searchController.addListener(() {
      _updateSuggestions(_searchController.text);
    });
  }

  Future<void> _initializeMap() async {
    _currentLocation = await fetchCurrentLocation(_currentLocation);
    setState(() {
      _mapController.move(_currentLocation, 14.0);
    });

    final List<Map<String, dynamic>> randomEvents =
        await generateRandomEventsWithNames(
      center: _currentLocation,
      count: 50,
      radiusInMeters: 2000,
    );

    // Add unique IDs to each event
    final eventsWithIds = randomEvents.asMap().entries.map((entry) {
      final index = entry.key;
      final event = entry.value;
      return {
        ...event,
        'id': event['id'] ?? 'event-$index', // Ensure a unique ID
      };
    }).toList();

    setState(() {
      _events.addAll(eventsWithIds);
      _updateMarkers();
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getString('favorites');
    if (savedFavorites != null) {
      final List<Map<String, dynamic>> favorites =
          List<Map<String, dynamic>>.from(json.decode(savedFavorites));
      setState(() {
        _favorites.addAll(favorites);
        favoriteIds.addAll(favorites.map((fav) => fav['id']));
        _updateMarkers();
      });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String favoritesJson = json.encode(_favorites);
    await prefs.setString('favorites', favoritesJson);
  }

  void _updateMarkers() {
    setState(() {
      _allMarkers.clear();
      _allMarkers.addAll(
        _events.map((event) {
          final id = event['id'] ?? 'unknown-id';
          return Marker(
            point: event['point'] as LatLng,
            width: 50.0,
            height: 50.0,
            child: GestureDetector(
              onTap: () => _showMarkerPopup(context, event),
              child: Hero(
                tag: 'marker-$id', // Prefix added to ensure uniqueness
                child: Icon(
                  Icons.location_on,
                  color: favoriteIds.contains(id) ? Colors.red : Colors.green,
                  size: 50.0,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredEvents = [];
        _updateMarkers();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredEvents = _events
          .where((event) => (event['name'] ?? '')
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();

      _allMarkers.clear();
      _allMarkers.addAll(
        _filteredEvents.map((event) {
          final id = event['id'] ?? 'unknown-id';
          return Marker(
            point: event['point'] as LatLng,
            width: 50.0,
            height: 50.0,
            child: GestureDetector(
              onTap: () => _showMarkerPopup(context, event),
              child: Hero(
                tag: 'suggestion-$id', // Prefix added to ensure uniqueness
                child: Icon(
                  Icons.location_on,
                  color: favoriteIds.contains(id) ? Colors.red : Colors.green,
                  size: 50.0,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  void _toggleFavorite(Map<String, dynamic> event) {
    final String eventId = event['id'];
    setState(() {
      if (favoriteIds.contains(eventId)) {
        favoriteIds.remove(eventId);
        _favorites.removeWhere((fav) => fav['id'] == eventId);
      } else {
        favoriteIds.add(eventId);
        _favorites.add({
          'id': eventId,
          'name': event['name'] ?? 'Unknown Event',
          'description': event['description'] ?? 'No description available',
          'point': {
            'latitude': event['point'].latitude,
            'longitude': event['point'].longitude,
          },
        });
      }
      _saveFavorites();
      _updateMarkers();
    });
  }

  void _showMarkerPopup(BuildContext context, Map<String, dynamic> event) {
    final String eventId = event['id'];
    final String eventName = event['name'] ?? 'Unknown Event';
    final String eventDescription =
        event['description'] ?? 'No description available';

    final isFavorite = favoriteIds.contains(eventId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return StoreConnector<bool, bool>(
          converter: (store) => store.state,
          builder: (context, isDarkMode) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white54 : Colors.black26,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Text(
                    eventName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    eventDescription,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _toggleFavorite(event);
                      Navigator.pop(context); // Close the popup
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFavorite
                          ? (isDarkMode ? Colors.red[700] : Colors.red)
                          : (isDarkMode ? Colors.green[700] : Colors.green),
                    ),
                    child: Text(
                      isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Reset markers to show all points when the bottom sheet is closed
      _updateMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<bool, bool>(
      converter: (store) => store.state,
      builder: (context, isDarkMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: Scaffold(
            floatingActionButton: FloatingActionButtons(
              isDarkMode: isDarkMode,
              onDarkModeToggle: () {
                StoreProvider.of<bool>(context)
                    .dispatch(DarkModeActions.ToggleDarkMode);
              },
              onAddMarker: () {
                showAddMarkerDialog(context, _events, _allMarkers, favoriteIds);
              },
              onViewFavorites: () async {
                final LatLng? selectedLocation = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(
                      favorites: _favorites,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                );

                if (selectedLocation != null) {
                  final selectedEvent = _favorites.firstWhere(
                    (fav) =>
                        fav['point']['latitude'] == selectedLocation.latitude &&
                        fav['point']['longitude'] == selectedLocation.longitude,
                    orElse: () => {},
                  );

                  // Move and center the map on the selected point
                  _mapController.move(selectedLocation, 16.0);

                  // Show the marker popup and update markers
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showMarkerPopup(context, selectedEvent);
                  });

                  // Temporarily show only the selected marker
                  setState(() {
                    _allMarkers.clear();
                    _allMarkers.add(
                      Marker(
                        point: selectedLocation,
                        width: 50.0,
                        height: 50.0,
                        child: GestureDetector(
                          onTap: () => _showMarkerPopup(context, selectedEvent),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 50.0,
                          ),
                        ),
                      ),
                    );
                  });
                }
              },
              openChat: _openChatList, // Pass `_openChatList` here
            ),
            body: Stack(
              children: [
                MapView(
                  mapController: _mapController,
                  currentLocation: _currentLocation,
                  allMarkers: _allMarkers,
                  isDarkMode: isDarkMode,
                ),
                SearchBarWidget(
                  searchController: _searchController,
                  isDarkMode: isDarkMode,
                  isSearching: _isSearching,
                  filteredEvents: _filteredEvents,
                  onQueryChanged: _updateSuggestions,
                  onEventSelected: (event) {
                    _searchController.clear();
                    _updateSuggestions('');

                    final LatLng point = event['point'] as LatLng;

                    // Move and zoom the map
                    _mapController.move(
                        point, 16.0); // Zoom level adjusted to 16

                    // Update markers to highlight the selected event
                    setState(() {
                      _allMarkers.clear();
                      _allMarkers.add(
                        Marker(
                          point: point,
                          width: 50.0,
                          height: 50.0,
                          child: GestureDetector(
                            onTap: () => _showMarkerPopup(context, event),
                            child: Icon(
                              Icons.location_on,
                              color: Colors
                                  .blue, // Highlighted color for selected marker
                              size: 50.0,
                            ),
                          ),
                        ),
                      );
                    });
                    _showMarkerPopup(context, event); // Show event details
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
