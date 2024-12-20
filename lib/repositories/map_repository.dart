import 'package:latlong2/latlong.dart';
import '../helpers/event_helpers.dart';

class MapRepository {
  Future<LatLng> fetchCurrentLocation() async {
    return await fetchCurrentLocation();
  }

  List<Map<String, dynamic>> generateRandomEvents(
      LatLng center, int count, double radius) {
    return generateRandomEventsWithNames(
        center: center, count: count, radiusInMeters: radius);
  }

  List<Map<String, dynamic>> searchSuggestions(String query) {
    // Add search logic here
    return [];
  }
}