import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapEvent {}

class SearchLocation extends MapEvent {
  final String query;
  SearchLocation(this.query);
}

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

class MapBloc extends Bloc<MapEvent, MapState> {
  static const MAPBOX_ACCESS_TOKEN = "pk.eyJ1IjoiYWxla2xhMDEyNiIsImEiOiJjbGp0NTNvd2UwM2RnM2VtbDlieHkwNTBiIn0.oEhomSTKaUBKdzIw2cyeSw";

  MapBloc() : super(MapState(markers: []));

  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is SearchLocation) {
      yield state.copyWith(isLoading: true);
      try {
        final url =
            "https://api.mapbox.com/geocoding/v5/mapbox.places/${event.query}.json?access_token=$MAPBOX_ACCESS_TOKEN";
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['features'].isNotEmpty) {
            final coordinates = data['features'][0]['geometry']['coordinates'];
            final lat = coordinates[1];
            final lng = coordinates[0];
            yield state.copyWith(
              isLoading: false,
              markers: [...state.markers, {'latitude': lat, 'longitude': lng}],
            );
          }
        }
      } catch (e) {
        yield state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }
}
