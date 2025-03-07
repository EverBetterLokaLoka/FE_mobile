import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationApi {
  Future<Map<String, dynamic>> getRouteFromGraphHopper(List<LatLng> locations, String apiKey) async {
    if (locations.length < 2) return {"route": [], "instructions": []};

    String baseUrl = "https://graphhopper.com/api/1/route?";
    String points = locations.map((latLng) => "point=${latLng.latitude},${latLng.longitude}").join("&");

    String url = "$baseUrl$points&vehicle=car&locale=en&key=$apiKey&points_encoded=false&instructions=true";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> path = data["paths"][0]["points"]["coordinates"];
      List<LatLng> routePoints = path.map((p) => LatLng(p[1], p[0])).toList();

      List<String> instructions = [];
      for (var step in data["paths"][0]["instructions"]) {
        instructions.add(step["text"]);
      }

      return {"route": routePoints, "instructions": instructions};
    } else {
      print("GraphHopper API Error: ${response.body}");
      return {"route": [], "instructions": []};
    }
  }
}
