import 'marker_state.dart';

enum MarkerActions { AddMarker }

MarkerState markerReducer(MarkerState state, dynamic action) {
  if (action['type'] == MarkerActions.AddMarker) {
    return state.copyWith(
      markers: [...state.markers, action['marker']],
    );
  }
  return state;
}
