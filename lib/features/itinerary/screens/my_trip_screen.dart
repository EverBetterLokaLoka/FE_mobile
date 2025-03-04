import 'package:flutter/material.dart';
import 'package:lokaloka/core/styles/colors.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/notice_widget.dart';
import '../services/itinerary_api.dart';

class MyTrip extends StatefulWidget {
  const MyTrip({Key? key}) : super(key: key);

  @override
  _MyTripState createState() => _MyTripState();
}

class _MyTripState extends State<MyTrip> {
  final ItineraryApi _itineraryService = ItineraryApi();
  List<Map<String, dynamic>> allItineraries = [];
  List<Map<String, dynamic>> filteredItineraries = [];
  bool isLoading = true;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchItineraries();
  }

  Future<void> _fetchItineraries() async {
    setState(() => isLoading = true);

    final itineraries = await _itineraryService.fetchItineraries();

    setState(() {
      allItineraries = itineraries;
      _filterItineraries();
      isLoading = false;
    });
  }

  void _deleteItineraryApi(Map<String, dynamic> trip, String userName) async {
    bool? confirm;
    while (confirm == null) {
      confirm = await showCustomNotice(
          context,
          "Hi $userName! Please confirm that you want to delete this trip",
          "confirm");
    }

    if (confirm == true) {
      final result = await _itineraryService.deleteItinerary(trip['id'] as int);

      if (result == true) {
        await showCustomNotice(context, "Successfully deleted", "success");
        setState(() {
          allItineraries.removeWhere((item) => item['id'] == trip['id']);
          allItineraries.remove(trip);
          _filterItineraries();
        });
      } else {
        await showCustomNotice(context, "Fail to delete itinerary", "error");
      }
    }else{
      setState(() {
        allItineraries.removeWhere((item) => item['id'] == trip['id']);
        _filterItineraries();
      });
    }
  }

  void _filterItineraries() {
    setState(() {
      filteredItineraries = allItineraries
          .where((trip) => trip['status'] == selectedTab)
          .toList();
    });
  }

  void _shareItinerary(Map<String, dynamic> trip) {
    final String shareText = 'Check out this itinerary: ${trip['title']}!';
    print("Sharing: $shareText");
  }

  void _deleteItinerary(Map<String, dynamic> trip) {
    setState(() {
      _deleteItineraryApi(trip, "Phat"); //Sau khi co profile thi doi cho nay !!!
    });
    print("Deleted itinerary: ${trip['title']}");
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
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tabs
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabItem('Itineraries', 0),
                      _buildTabItem('Going', 1),
                      _buildTabItem('History', 2),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredItineraries.isEmpty
                      ? const Center(child: Text("No itineraries found"))
                      : ListView.builder(
                          itemCount: filteredItineraries.length,
                          itemBuilder: (context, index) {
                            final trip = filteredItineraries[index];
                            return _buildTripCard(trip);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Tab Buttons
  Widget _buildTabItem(String title, int tabIndex) {
    bool isActive = selectedTab == tabIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tabIndex;
          _filterItineraries();
        });
      },
      child: Container(
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
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'share') {
                          // Share
                          _shareItinerary(trip);
                        } else if (value == 'delete') {
                          _deleteItinerary(trip);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share, color: Colors.black),
                              SizedBox(width: 10),
                              Text('Share'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 10),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(35, 23),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Icon(Icons.more_vert, color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        //Chuyen sang navigation map
                      },
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
