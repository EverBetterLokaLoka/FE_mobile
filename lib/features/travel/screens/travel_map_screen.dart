import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TravelMapScreen extends StatefulWidget {
  @override
  _TravelMapScreenState createState() => _TravelMapScreenState();
}

class _TravelMapScreenState extends State<TravelMapScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(16.047079, 108.206230); // Đà Nẵng

  List<LatLng> polylineCoordinates = [];
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  void _loadRoute() {
    // Danh sách điểm trên tuyến đường (có thể lấy từ API)
    List<LatLng> routePoints = [
      LatLng(16.0678, 108.2208), // Điểm bắt đầu
      LatLng(16.0655, 108.2141),
      LatLng(16.0600, 108.2102),
      LatLng(16.0595, 108.2033), // Cầu Rồng
      LatLng(16.0545, 108.2011), // Công viên APEC
      LatLng(16.0480, 108.2000), // Điểm kết thúc
    ];

    setState(() {
      polylineCoordinates = routePoints;

      // Thêm markers cho các điểm đến
      for (int i = 0; i < routePoints.length; i++) {
        markers.add(
          Marker(
            markerId: MarkerId("point_$i"),
            position: routePoints[i],
            infoWindow: InfoWindow(title: "Điểm $i"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }

      // Vẽ đường đi trên bản đồ
      polylines.add(
        Polyline(
          polylineId: PolylineId("route"),
          color: Colors.blue,
          width: 5,
          points: polylineCoordinates,
        ),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // Hiển thị chỉ dẫn tuyến đường
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📍 321R+V6G, Sơn Trà, Đà Nẵng",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.directions_walk, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text("200m → rẽ trái"),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.directions, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text("900m → rẽ phải"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "🏁 Cầu Rồng → Công viên APEC → Cầu Trần Thị Lý",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Nút Stop Travel
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Hủy chuyến đi
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("Stop Travel"),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Hiển thị các bước di chuyển
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Steps"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
