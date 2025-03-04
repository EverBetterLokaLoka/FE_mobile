import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TravelMapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> locations;

  const TravelMapScreen({super.key, required this.locations});

  @override
  _TravelMapScreenState createState() => _TravelMapScreenState();
}

class _TravelMapScreenState extends State<TravelMapScreen> {
  late GoogleMapController mapController;
  LatLng? _currentLocation;
  List<Marker> _markers = [];
  List<LatLng> _polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMarkers();
  }

  // Lấy vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  // Load marker từ danh sách locations
  void _loadMarkers() {
    List<Marker> markers = [];
    for (var location in widget.locations) {
      markers.add(
        Marker(
          markerId: MarkerId(location["name"]),
          position: LatLng(location["lat"], location["lng"]),
          infoWindow: InfoWindow(title: location["name"], snippet: location["description"]),
        ),
      );
    }
    setState(() {
      _markers = markers;
    });
  }

  // Lấy tuyến đường từ Google Directions API
  Future<void> _getRoute(LatLng start, LatLng end) async {
    final String apiKey = "YOUR_GOOGLE_MAPS_API_KEY";
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data["status"] == "OK") {
      List<LatLng> routePoints = [];
      List<dynamic> steps = data["routes"][0]["legs"][0]["steps"];
      for (var step in steps) {
        routePoints.add(LatLng(step["start_location"]["lat"], step["start_location"]["lng"]));
        routePoints.add(LatLng(step["end_location"]["lat"], step["end_location"]["lng"]));
      }

      setState(() {
        _polylineCoordinates = routePoints;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Travel Map")),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (controller) => mapController = controller,
        initialCameraPosition: CameraPosition(
          target: _currentLocation!,
          zoom: 14.0,
        ),
        markers: Set<Marker>.of(_markers),
        polylines: {
          Polyline(
            polylineId: PolylineId("route"),
            color: Colors.blue,
            points: _polylineCoordinates,
            width: 5,
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.locations.length > 1) {
            _getRoute(
              LatLng(widget.locations[0]["lat"], widget.locations[0]["lng"]),
              LatLng(widget.locations[1]["lat"], widget.locations[1]["lng"]),
            );
          }
        },
        child: Icon(Icons.directions),
      ),
    );
  }
}
