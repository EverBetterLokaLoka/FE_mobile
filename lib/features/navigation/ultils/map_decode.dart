import 'package:google_maps_flutter/google_maps_flutter.dart';

List<LatLng> decodePolyline(String encoded) {
  List<LatLng> points = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int shift = 0, result = 0;
    int byte;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
    int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += deltaLat;

    shift = 0;
    result = 0;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
    int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += deltaLng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return points;
}