import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../helpers/map_helpers.dart';

class MapView extends StatelessWidget {
  final MapController mapController;
  final LatLng currentLocation;
  final List<Marker> allMarkers;
  final bool isDarkMode;

  const MapView({
    required this.mapController,
    required this.currentLocation,
    required this.allMarkers,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: generateMapboxUrl(isDarkMode),
        ),
        MarkerLayer(
          markers: allMarkers.map((marker) {
            return Marker(
              point: marker.point,
              width: marker.width,
              height: marker.height,
              child: AnimatedMarker(child: marker.child),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class AnimatedMarker extends StatefulWidget {
  final Widget child;

  const AnimatedMarker({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedMarker> createState() => _AnimatedMarkerState();
}

class _AnimatedMarkerState extends State<AnimatedMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward(); // Start animation when marker is added
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
