import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/apis.dart';
import '../../../core/utils/transfer_money.dart';
import '../widgets/itinerary-app_bar.dart';
import '../../../core/styles/colors.dart';
import 'detail_itinerary_screen.dart';
import '../models/Itinerary.dart';

class CreateByAi extends StatefulWidget {
  final String location;
  final String totalDay;
  final String startDate;
  final String endDate;

  CreateByAi({
    required this.location,
    required this.totalDay,
    required this.startDate,
    required this.endDate,
  });

  @override
  _CreateByAiState createState() => _CreateByAiState();
}

class _CreateByAiState extends State<CreateByAi> {
  final TextEditingController _budgetController = TextEditingController();
  Map<String, bool> _interests = {
    'Cultural experiences': false,
    'Museums': false,
    'Shopping': false,
    'Outdoor activities': false,
    'Relaxation': false,
    'Beach': false,
  };

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  final ApiService _apiService = ApiService();

  Future<void> _sendDataToBackend() async {
    final String dateInfo =
        (widget.startDate.isNotEmpty && widget.endDate.isNotEmpty)
            ? "from ${widget.startDate} to ${widget.endDate} "
            : "";

    final String prompt =
        "I want to travel ${dateInfo}in ${widget.location} for ${widget.totalDay} Days. "
        "My budget is ${CurrencyFormatter.format(_budgetController.text)}."
        "I am interested in activities such as: ${_interests.entries.where((entry) => entry.value).map((entry) => entry.key).join(', ')}.";

    final Map<String, dynamic> requestData = {
      'prompt': prompt,
    };

    print(requestData);
    String jsonData = '''
  {
  "title": "Da Nang Nature & Foodie Escape (2D1N)",
  "description": "A whirlwind tour of Da Nang's natural beauty, delicious cuisine, and Instagram-worthy spots, all within a budget of 5,000,000 VND.",
  "price": 5000000.0,
  "locations": [
  {
  "name": "Marble Mountains",
  "day": 1,
  "description": "Explore the five marble and limestone hills, each representing an element. Discover caves, pagodas, and stunning views.",
  "flag": false,
  "time_start": "2025-02-13T08:00:00Z",
  "time_finish": "2025-02-13T11:00:00Z",
  "time_reminder": "30 minutes before",
  "culture": "Vietnamese, Buddhist",
  "recommended_time": "Morning",
  "price": "40000.0",
  "activities": [
  {
  "name": "Explore Caves & Pagodas",
  "description": "Discover Huyen Khong Cave, Tam Thai Pagoda, and enjoy panoramic views.",
  "activities_possible": "Hiking, Photography, Sightseeing",
  "price": 0.0,
  "rule": "Wear comfortable shoes; respect religious sites.",
  "recommend": "Highly recommended for its natural beauty and cultural significance."
  }]
  },
  {
  "name": "My Khe Beach",
  "day": 1,
  "description": "Relax on one of Forbes' top beaches. Enjoy the soft sand, clear water, and fresh seafood.",
  "flag": false,
  "time_start": "2025-02-13T11:30:00Z",
  "time_finish": "2025-02-13T14:00:00Z",
  "time_reminder": "30 minutes before",
  "culture": "Vietnamese",
  "recommended_time": "Afternoon",
  "price": "0.0",
  "activities": [
  {
  "name": "Beach Relaxation & Seafood Lunch",
  "description": "Enjoy the beach and have lunch at a local seafood restaurant.",
  "activities_possible": "Swimming, Sunbathing, Photography, Dining",
  "price": 300000.0,
  "rule": "Be mindful of your belongings.",
  "recommend": "Try the fresh seafood – it's a must-try!"
  }
  ]
  },
  {
  "name": "Helio Night Market",
  "day": 1,
  "description": "Experience the vibrant atmosphere of Da Nang's night market. Enjoy street food, shopping, and live music.",
  "flag": false,
  "time_start": "2025-02-13T18:00:00Z",
  "time_finish": "2025-02-13T21:00:00Z",
  "time_reminder": "30 minutes before",
  "culture": "Vietnamese",
  "recommended_time": "Evening",
  "price": "0",
  "activities": [
  {
  "name": "Street Food Adventure",
  "description": "Sample a variety of local dishes like Banh Xeo, Mi Quang, and fresh seafood.",
  "activities_possible": "Dining, Shopping, Live Music",
  "price": 200000.0,
  "rule": "Bargain respectfully when shopping.",
  "recommend": "Try as many different dishes as you can!"
  }
  ]
  },
  {
  "name": "Dragon Bridge",
  "day": 1,
  "description": "Witness the spectacular Dragon Bridge fire and water show (weekends only).",
  "flag": false,
  "time_start": "2025-02-13T21:00:00Z",
  "time_finish": "2025-02-13T22:00:00Z",
  "time_reminder": "30 minutes before",
  "culture": "Vietnamese",
  "recommended_time": "Night",
  "price": "0.0",
  "activities": [
  {
  "name": "Fire & Water Show",
  "description": "Watch the Dragon Bridge breathe fire and water (Saturdays and Sundays at 9 PM).",
  "activities_possible": "Photography, Sightseeing",
  "price": 0.0,
  "rule": "Arrive early to secure a good viewing spot.",
  "recommend": "A must-see spectacle in Da Nang."
  }
  ]
  },
  {
  "name": "Son Tra Peninsula (Monkey Mountain)",
  "day": 2,
  "description": "Explore the lush peninsula, visit Linh Ung Pagoda with its giant Lady Buddha statue, and enjoy breathtaking views of the coastline.",
  "flag": false,
  "time_start": "2025-02-14T08:00:00Z",
  "time_finish": "2025-02-14T12:00:00Z",
  "time_reminder": "30 minutes before",
  "culture": "Vietnamese, Buddhist",
  "recommended_time": "Morning",
  "price": "0.0",
  "activities": [
  {
  "name": "Linh Ung Pagoda & Lady Buddha",
  "description": "Visit the pagoda, admire the Lady Buddha statue, and enjoy panoramic views.",
  "activities_possible": "Photography, Sightseeing, Hiking",
  "price": 0.0,
  "rule": "Dress modestly when visiting the pagoda.",
  "recommend": "Highly recommended for its stunning views and spiritual atmosphere."
  },
  {
  "name": "Spot Wild Monkeys",
  "description": "Observe the local wild monkey",
  "activities_possible": "Photography, Sightseeing, Hiking",
  "price": 0.0,
  "rule": "Do not feed the monkeys.",
  "recommend": "Highly recommended for its natural scenery."
  }
  ]
  },
  {
  "name": "Han Market",
  "day": 2,
  "description": "Explore a local market where you can find souvenirs, local produce, and try some street food.",
  "flag": false,
  "time_start": "2025-02-14T12:30:00Z",
  "time_finish": "2025-02-14T14:30:00Z",
  "time_reminder": "30 minutes before",
  "culture": "Vietnamese",
  "recommended_time": "Afternoon",
  "price": "0.0",
  "activities": [
  {
  "name": "Shopping & Local Food",
  "description": "Browse for souvenirs and enjoy a local lunch.",
  "activities_possible": "Shopping, Dining, Photography",
  "price": 200000.0,
  "rule": "Bargain respectfully.",
  "recommend": "Try the local specialties like Mi Quang or Cao Lau."
  }
  ]
  },
  {
  "name": "Asia Park - Sun World Da Nang Wonders",
  "day": 2,
  "description": "Enjoy thrilling rides, cultural parks, and the iconic Sun Wheel.",
  "flag": false,
  "time_start": "2025-02-14T15:00:00Z",
  "time_finish": "2025-02-14T18:00:00Z",
  "time_reminder": "30 minutes before",
  "culture": "Vietnamese, Asian",
  "recommended_time": "Afternoon",
  "price": "350000",
  "activities": [
  {
  "name": "Ride the Sun Wheel",
  "description": "Take a ride for great view",
  "activities_possible": "Sightseeing, Photography",
  "price": 0,
  "rule": "Follow safety instructions.",
  "recommend": "Recommended for its beautiful scenery."
  },
  {
  "name": "Explore Cultural Parks",
  "description": "Explore miniature landmarks and cultural displays from various Asian countries.",
  "activities_possible": "Sightseeing, Photography",
  "price": 0.0,
  "rule": "Respect the cultural exhibits.",
  "recommend": "A great way to learn about different Asian cultures."
  }
  ]
  },
  {
  "name": "A local coffee shop",
  "day": 2,
  "description": "Enjoy the view of the city while enjoy a cup of coffee",
  "flag": false,
  "time_start": "2025-02-14T18:30:00Z",
  "time_finish": "2025-02-14T19:30:00Z",
  "time_reminder": "30 minutes before",
  "culture": "Vietnamese",
  "recommended_time": "Evening",
  "price": "50000",
  "activities": [
  {
  "name": "Enjoy local coffee",
  "description": "Try different type of coffee.",
  "activities_possible": "Sightseeing, Photography",
  "price": 50000,
  "rule": "Follow safety instructions.",
  "recommend": "Recommended for its beautiful scenery."
  }
  ]}
  ]}
  ''';

    Map<String, dynamic> parsedJson = json.decode(jsonData);
    Itinerary itinerary = Itinerary.fromJson(parsedJson);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailItineraryScreen(itineraryItems: itinerary),
      ),
    );
    // try {
    //   final response = await _apiService.request(
    //     path: '/itineraries/generate',
    //     method: 'POST',
    //     typeUrl: 'baseUrl',
    //     data: requestData
    //   );
    //
    //
    //
    //   _showResponseDialog('Success', 'Trip planned successfully!\n$response');
    // } catch (error) {
    //   _showResponseDialog('Error', 'Failed to plan trip: $error');
    // }
  }

  void _showResponseDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ItineraryAppBar(
        titleText: 'Create Itinerary',
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What is your budget range for the trip?",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Budget",
                  hintText: "Eg: 5.000.000VND",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "What are your interests?",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor),
              ),
              SizedBox(height: 10),
              ..._interests.keys.map((interest) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CheckboxListTile(
                    title: Text(interest),
                    value: _interests[interest],
                    activeColor: AppColors.orangeColor,
                    onChanged: (bool? value) {
                      setState(() {
                        _interests[interest] = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              }).toList(),
              SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sendDataToBackend,
                    // onPressed: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => DetailItineraryScreen(itineraryItems: itinerary),
                    //     ),
                    //   );
                    // },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeColor,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      'Start planning',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
