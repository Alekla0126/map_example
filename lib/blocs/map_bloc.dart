import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/map_repository.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

// Events
abstract class MapEvent {}

class FetchCurrentLocation extends MapEvent {}

class ToggleDarkMode extends MapEvent {}

class GenerateRandomEvents extends MapEvent {
  final LatLng center;
  final int count;
  final double radius;

  GenerateRandomEvents(this.center, this.count, this.radius);
}

class SearchLocation extends MapEvent {
  final String query;

  SearchLocation(this.query);
}

// State
class MapState {
  final bool isDarkMode;
  final LatLng? currentLocation;
  final LatLng? mapCenter;
  final double zoomLevel;
  final List<Map<String, dynamic>> markers;
  final List<Map<String, dynamic>> favorites;
  final List<Map<String, dynamic>> suggestions;
  final bool isSearching;

  MapState({
    this.isDarkMode = false,
    this.currentLocation,
    this.mapCenter,
    this.zoomLevel = 14.0, // Default zoom level
    this.markers = const [],
    this.favorites = const [],
    this.suggestions = const [],
    this.isSearching = false,
  });

  MapState copyWith({
    bool? isDarkMode,
    LatLng? currentLocation,
    LatLng? mapCenter,
    double? zoomLevel,
    List<Map<String, dynamic>>? markers,
    List<Map<String, dynamic>>? favorites,
    List<Map<String, dynamic>>? suggestions,
    bool? isSearching,
  }) {
    return MapState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentLocation: currentLocation ?? this.currentLocation,
      mapCenter: mapCenter ?? this.mapCenter,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      markers: markers ?? this.markers,
      favorites: favorites ?? this.favorites,
      suggestions: suggestions ?? this.suggestions,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

// Bloc
class MapBloc extends Bloc<MapEvent, MapState> {
  final MapRepository repository;

  MapBloc({required this.repository}) : super(MapState()) {
    on<FetchCurrentLocation>(_onFetchCurrentLocation);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<GenerateRandomEvents>(_onGenerateRandomEvents);
    on<SearchLocation>(_onSearchLocation);
  }

  Future<void> _onFetchCurrentLocation(
      FetchCurrentLocation event, Emitter<MapState> emit) async {
    final location = await repository.fetchCurrentLocation();
    emit(state.copyWith(currentLocation: location));
  }

  void _onToggleDarkMode(ToggleDarkMode event, Emitter<MapState> emit) {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  Future<void> _onGenerateRandomEvents(
      GenerateRandomEvents event, Emitter<MapState> emit) async {
    final events = repository.generateRandomEvents(
        event.center, event.count, event.radius);
    emit(state.copyWith(markers: [...state.markers, ...events]));
  }

  void _onSearchLocation(SearchLocation event, Emitter<MapState> emit) {
    final suggestions = repository.searchSuggestions(event.query);
    emit(state.copyWith(suggestions: suggestions, isSearching: true));
  }
}