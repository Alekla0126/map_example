import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final bool isDarkMode;
  final bool isSearching;
  final List<Map<String, dynamic>> filteredEvents;
  final Function(String) onQueryChanged;
  final Function(Map<String, dynamic>) onEventSelected;

  const SearchBarWidget({
    required this.searchController,
    required this.isDarkMode,
    required this.isSearching,
    required this.filteredEvents,
    required this.onQueryChanged,
    required this.onEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Column(
        children: [
          Material(
            elevation: 2.0,
            borderRadius: BorderRadius.circular(30.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search for an event...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            onQueryChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(15.0),
                ),
              ),
            ),
          ),
          if (isSearching)
            Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[900]?.withOpacity(0.8)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredEvents.length > 5
                    ? 5
                    : filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return ListTile(
                    title: Text(
                      event['name'] ?? 'Unknown Event',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () => onEventSelected(event),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
