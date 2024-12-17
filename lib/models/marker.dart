import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class CustomMarker {
  final LatLng position;
  final double width;
  final double height;
  final Widget child;

  CustomMarker({
    required this.position,
    this.width = 80.0,
    this.height = 80.0,
    required this.child,
  });
}

