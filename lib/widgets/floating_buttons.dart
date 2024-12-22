import 'package:flutter/material.dart';

class FloatingButtons extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onDarkModeToggle;
  final VoidCallback onAddMarker;
  final VoidCallback onViewFavorites;
  final VoidCallback onLogout;

  const FloatingButtons({
    Key? key,
    required this.isDarkMode,
    required this.onDarkModeToggle,
    required this.onAddMarker,
    required this.onViewFavorites,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onDarkModeToggle,
          tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: onLogout, // Logout action
          tooltip: 'Logout',
          backgroundColor: Colors.red, // Red background for logout
          child: const Icon(Icons.logout),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: onViewFavorites,
          tooltip: 'View Favorites',
          child: const Icon(Icons.favorite),
        ),
      ],
    );
  }
}
