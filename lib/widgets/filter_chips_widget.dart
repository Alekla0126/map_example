import 'package:flutter/material.dart';

class FilterChipsWidget extends StatelessWidget {
  final Function(String) onFilterSelected;

  const FilterChipsWidget({super.key, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    final filters = [
      'Cheaper Asc',
      'Cheaper Desc',
      'WiFi',
      'Coffee',
      'Place to Work',
    ];

    // Determine the current theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(filter),
              onSelected: (_) => onFilterSelected(filter),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Set corner radius to 30
              ),
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200], // Dynamic background
              selectedColor: isDarkMode ? Colors.tealAccent : Colors.blueAccent, // Dynamic selected color
              labelStyle: TextStyle(
                fontSize: 14, // Adjust font size
                color: isDarkMode ? Colors.white : Colors.black, // Dynamic label color
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
