





class MarkerState {
  final List<Map<String, dynamic>> markers;
  final List<Map<String, dynamic>> favorites;
  final int unreadMessages; // Added field for unread messages

  MarkerState({
    required this.markers,
    required this.favorites,
    required this.unreadMessages, // Initialize unreadMessages
  });

  // Updated copyWith method to include unreadMessages
  MarkerState copyWith({
    List<Map<String, dynamic>>? markers,
    List<Map<String, dynamic>>? favorites,
    int? unreadMessages, // Added unreadMessages
  }) {
    return MarkerState(
      markers: markers ?? this.markers,
      favorites: favorites ?? this.favorites,
      unreadMessages: unreadMessages ?? this.unreadMessages, // Updated field
    );
  }

  // Updated initialState method to initialize unreadMessages
  static MarkerState initialState() {
    return MarkerState(
      markers: [],
      favorites: [],
      unreadMessages: 0, // Initialize to 0
    );
  }
}