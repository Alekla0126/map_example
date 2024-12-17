class MarkerState {
  final List<Map<String, dynamic>> markers;

  MarkerState({required this.markers});

  MarkerState copyWith({List<Map<String, dynamic>>? markers}) {
    return MarkerState(
      markers: markers ?? this.markers,
    );
  }
}

MarkerState initialState = MarkerState(markers: []);
