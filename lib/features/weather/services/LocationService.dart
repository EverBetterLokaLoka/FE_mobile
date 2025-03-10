import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    return permission != LocationPermission.deniedForever;
  }

  static Future<Position?> getCurrentLocation() async {
    if (await checkPermission()) {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    }
    return null;
  }

  static Future<String?> getCityFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String? province = place.administrativeArea;

        print("Tỉnh/Thành phố lấy được: $province");
        return province;
      } else {
        print("Không tìm thấy tỉnh/thành phố.");
      }
    } catch (e) {
      print("Lỗi lấy địa điểm: $e");
    }
    return null;
  }

  static Future<String?> getCurrentCity() async {
    Position? position = await getCurrentLocation();
    if (position != null) {
      return await getCityFromCoordinates(
          position.latitude, position.longitude);
    }
    return null;
  }

  static Future<List<LatLng>> getCoordinatesForLocations(
      List<String> addresses) async {
    List<LatLng> locations = [];

    for (String address in addresses) {
      try {
        List<Location> locationResults = await locationFromAddress(address);
        if (locationResults.isNotEmpty) {
          Location location = locationResults.first;
          locations.add(LatLng(location.latitude, location.longitude));
        } else {
          print("Không tìm thấy tọa độ cho địa điểm: $address");
        }
      } catch (e) {
        print("Lỗi lấy tọa độ cho $address: $e");
      }
    }

    return locations;
  }
}