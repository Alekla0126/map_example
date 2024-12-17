class MapState {
  final List<Map<String, dynamic>> markers;
  final bool isLoading;
  final String? errorMessage;

  MapState({required this.markers, this.isLoading = false, this.errorMessage});

  MapState copyWith({
    List<Map<String, dynamic>>? markers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MapState(
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
