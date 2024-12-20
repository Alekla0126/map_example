import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // Import LatLng from latlong2

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favorites;
  final bool isDarkMode;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Favorites",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Text(
                "No favorites yet!",
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                final point = favorite['point'] ?? {};
                final latitude = point['latitude'];
                final longitude = point['longitude'];
                final description =
                    favorite['description'] ?? 'No description available';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: isDarkMode ? Colors.white : Colors.blue,
                    ),
                    title: Text(
                      favorite['name'] ?? 'Unknown Event',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lat: $latitude, Lng: $longitude',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white54 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Pass the selected point back to the map screen
                      Navigator.pop(
                        context,
                        LatLng(latitude, longitude), // Return LatLng
                      );
                    },
                  ),
                );
              },
            ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
    );
  }
}
