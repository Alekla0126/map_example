import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:convert';

Future<void> loadFavorites(
  List<Map<String, dynamic>> favorites,
  Set<String> favoriteIds,
  List<Marker> markers,
  Function updateMarkers,
) async {
  final prefs = await SharedPreferences.getInstance();
  final savedFavorites = prefs.getString('favorites');
  if (savedFavorites != null) {
    final List<Map<String, dynamic>> loadedFavorites =
        List<Map<String, dynamic>>.from(json.decode(savedFavorites));
    favorites.addAll(loadedFavorites);
    favoriteIds.addAll(loadedFavorites.map((fav) => fav['id']));
    updateMarkers();
  }
}

Future<void> saveFavorites(List<Map<String, dynamic>> favorites) async {
  final prefs = await SharedPreferences.getInstance();
  final favoritesJson = json.encode(favorites);
  await prefs.setString('favorites', favoritesJson);
}