import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lokaloka/core/styles/colors.dart';
import 'package:lokaloka/features/itinerary/screens/detail_itinerary_screen.dart';
import '../../../core/utils/apis.dart';
import '../../../widgets/app_bar_widget.dart';
import '../models/Itinerary.dart';

class MyTrip extends StatefulWidget {
  const MyTrip({Key? key}) : super(key: key);

  @override
  _MyTripState createState() => _MyTripState();
}

class _MyTripState extends State<MyTrip> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> locations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItineraries();
  }

  Future<void> _fetchItineraries() async {
    try {
      final http.Response response = await _apiService.request(
        path: '/itineraries',
        method: 'GET',
        typeUrl: 'baseUrl',
        currentPath: '',
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);

        if (responseBody is Map<String, dynamic> &&
            responseBody.containsKey('data')) {
          final dynamic data = responseBody['data'];
          if (data is List) {
            setState(() {
              locations = List<Map<String, dynamic>>.from(data);
              isLoading = false;
            });
          } else {
            print("Unexpected 'data' format: $data");
            setState(() => isLoading = false);
          }
        } else {
          print("Unexpected response format: $responseBody");
          setState(() => isLoading = false);
        }
      } else {
        print("Failed to fetch data: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching itineraries: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppBarCustom(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-itinerary');
        },
        backgroundColor: AppColors.orangeColor,
        heroTag: "Itinerary",
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 28, color: Colors.white),
            Text("Itinerary",
                style: TextStyle(fontSize: 10, color: Colors.white)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: const Text('Travel Itinerary'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị loading
          : locations.isEmpty
              ? const Center(child: Text("No itineraries found"))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTabItem('Itineraries', true),
                          _buildTabItem('Going', false),
                          _buildTabItem('History', false),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final trip = locations[index];
                          return _buildTripCard(trip);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTabItem(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.orangeColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/hoiAn.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trip['title']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 6),
                        Text('2 days 1 night',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 16, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(trip['price'].toString(),
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.place, size: 16, color: Colors.grey),
                        SizedBox(width: 6),
                        Text('${trip['locations'].length} Destinations',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        try {
                          Itinerary itinerary = Itinerary.fromJson(trip);
                          itinerary = Itinerary(
                            title: itinerary.title,
                            description: itinerary.description,
                            price: itinerary.price?.toString() ?? "0.0", // Chuyển thành String
                            locations: itinerary.locations,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailItineraryScreen(itineraryItems: itinerary),
                            ),
                          );
                        } catch (e) {
                          print("Error parsing itinerary: $e");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(50, 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('...', style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(35, 23),
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('GO', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
