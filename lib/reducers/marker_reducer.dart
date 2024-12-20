import '../states/marker_state.dart';

enum MarkerActions { AddMarker, AddToFavorites, RemoveFromFavorites, MessageReceived, MessagesRead }

MarkerState markerReducer(MarkerState state, dynamic action) {
  if (action['type'] == MarkerActions.AddMarker) {
    return state.copyWith(
      markers: [...state.markers, action['marker']],
    );
  } else if (action['type'] == MarkerActions.AddToFavorites) {
    return state.copyWith(
      favorites: [...state.favorites, action['marker']],
    );
  } else if (action['type'] == MarkerActions.RemoveFromFavorites) {
    return state.copyWith(
      favorites: state.favorites
          .where((marker) => marker != action['marker'])
          .toList(),
    );
  } else if (action['type'] == MarkerActions.MessageReceived) {
    return state.copyWith(
      unreadMessages: state.unreadMessages + 1, // Increment unread messages
    );
  } else if (action['type'] == MarkerActions.MessagesRead) {
    return state.copyWith(
      unreadMessages: 0, // Reset unread messages to 0
    );
  }
  return state;
}