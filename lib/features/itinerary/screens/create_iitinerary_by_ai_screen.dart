import 'package:flutter/material.dart';
import '../../../core/utils/apis.dart';
import '../../../core/utils/transfer_money.dart';
import '../widgets/itinerary-app_bar.dart';
import '../../../core/styles/colors.dart';
import 'created_2itinerary_screen.dart';
import '../models/Itinerary.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  bool isPending = false;

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
    try {
      final String dateInfo =
          (widget.startDate.isNotEmpty && widget.endDate.isNotEmpty)
              ? "from ${widget.startDate} to ${widget.endDate} "
              : "";

      final String budgetText = _budgetController.text.trim();
      final String formattedBudget = budgetText.isNotEmpty
          ? CurrencyFormatter.format(budgetText)
          : "Not specified";

      int night = int.parse(widget.totalDay);
      night = night - 1;

      final String prompt =
          "I want to travel ${dateInfo}in ${widget.location} for ${widget.totalDay} Days and $night. "
          "My budget is $formattedBudget. "
          "I am interested in activities such as: ${_interests.entries.where((entry) => entry.value).map((entry) => entry.key).join(', ')}."
          "At least 4 location in one day. "
          "Important: Please generate for me 2 type plan for me to select but don't create new KEY!!!"
          "Please focus on my KEYS VALUES!!!";

      final Map<String, dynamic> requestData = {
        'prompt': prompt,
      };

      try {
        final response = await _apiService.request(
          path: '/itineraries/generate',
          method: 'POST',
          typeUrl: 'baseUrl',
          currentPath: '',
          data: requestData,
        );
//         final responseBody = '''
//         {
//     "success": true,
//     "status": 200,
//     "message": "Itinerary generated successfully",
//     "data": {
//         "itinerary": [
//             {
//                 "title": "Da Nang Nature & Culture Itinerary Plan 1",
//                 "description": "Explore Da Nang's famous beaches, cultural sites, and local markets on a budget.",
//                 "price": 4500000.0,
//                 "locations": [
//                     {
//                         "name": "My Khe Beach",
//                         "day": 1,
//                         "description": "One of the most beautiful beaches in Da Nang, perfect for sunrise and swimming.",
//                         "flag": false,
//                         "time_start": "2024-07-27T06:00:00Z",
//                         "time_finish": "2024-07-27T08:00:00Z",
//                         "time_reminder": "15 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Morning",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Sunrise walk and swim",
//                                 "description": "Enjoy the peaceful sunrise and a refreshing swim in the sea.",
//                                 "activities_possible": "Swimming, Sunbathing, Photography",
//                                 "price": 0.0,
//                                 "rule": "Follow beach safety guidelines",
//                                 "recommend": "Perfect start to the day."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Marble Mountains",
//                         "day": 1,
//                         "description": "A cluster of five marble and limestone hills with pagodas, caves, and stunning views.",
//                         "flag": false,
//                         "time_start": "2024-07-27T09:00:00Z",
//                         "time_finish": "2024-07-27T12:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese, Buddhist",
//                         "recommended_time": "Morning",
//                         "price": "40000",
//                         "activities": [
//                             {
//                                 "name": "Explore caves and pagodas",
//                                 "description": "Discover the natural caves, ancient pagodas, and enjoy panoramic views from the mountain top.",
//                                 "activities_possible": "Hiking, Sightseeing, Photography, Cultural Exploration",
//                                 "price": 40000.0,
//                                 "rule": "Wear comfortable shoes for climbing",
//                                 "recommend": "Must-visit for cultural and scenic beauty."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Linh Ung Pagoda (Son Tra Peninsula)",
//                         "day": 1,
//                         "description": "A magnificent pagoda with a giant Lady Buddha statue overlooking the city and sea.",
//                         "flag": false,
//                         "time_start": "2024-07-27T14:00:00Z",
//                         "time_finish": "2024-07-27T16:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese, Buddhist",
//                         "recommended_time": "Afternoon",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Visit Lady Buddha statue and pagoda",
//                                 "description": "Admire the towering Lady Buddha statue, explore the pagoda complex, and enjoy breathtaking views.",
//                                 "activities_possible": "Sightseeing, Photography, Cultural Exploration, Relaxation",
//                                 "price": 0.0,
//                                 "rule": "Dress respectfully when visiting religious sites",
//                                 "recommend": "Iconic landmark with stunning views."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Han Market",
//                         "day": 1,
//                         "description": "A bustling local market where you can find everything from fresh produce to souvenirs and street food.",
//                         "flag": false,
//                         "time_start": "2024-07-27T17:00:00Z",
//                         "time_finish": "2024-07-27T19:00:00Z",
//                         "time_reminder": "15 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Evening",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Explore local products and street food",
//                                 "description": "Wander through the market, sample local street food, and shop for souvenirs and local products.",
//                                 "activities_possible": "Shopping, Food Tasting, Cultural Immersion",
//                                 "price": 200000.0,
//                                 "rule": "Bargaining is common",
//                                 "recommend": "Great place to experience local life and cuisine."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Ba Na Hills (Optional - consider budget)",
//                         "day": 2,
//                         "description": "A mountain resort with French Village, Golden Bridge, and Fantasy Park (Entrance fee is high).",
//                         "flag": false,
//                         "time_start": "2024-07-28T08:00:00Z",
//                         "time_finish": "2024-07-28T17:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "French, Vietnamese",
//                         "recommended_time": "Full Day",
//                         "price": "900000",
//                         "activities": [
//                             {
//                                 "name": "Golden Bridge, French Village, Fantasy Park",
//                                 "description": "Walk on the iconic Golden Bridge, explore the French Village, and enjoy rides at Fantasy Park.",
//                                 "activities_possible": "Sightseeing, Photography, Amusement Park, Cultural Exploration",
//                                 "price": 900000.0,
//                                 "rule": "Check weather conditions before visiting",
//                                 "recommend": "Popular attraction with unique experiences."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Son Tra Peninsula (Alternative to Ba Na Hills)",
//                         "day": 2,
//                         "description": "A beautiful peninsula with lush forests, beaches, and viewpoints (Free if Ba Na Hills is too expensive).",
//                         "flag": false,
//                         "time_start": "2024-07-28T08:00:00Z",
//                         "time_finish": "2024-07-28T12:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Morning",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Explore Son Tra Nature Reserve",
//                                 "description": "Drive around the peninsula, enjoy scenic viewpoints, and spot wildlife like monkeys.",
//                                 "activities_possible": "Nature Exploration, Sightseeing, Photography, Wildlife Spotting",
//                                 "price": 0.0,
//                                 "rule": "Drive carefully on mountain roads",
//                                 "recommend": "Great for nature lovers and scenic drives."
//                             },
//                             {
//                                 "name": "Bai But Beach (Buddha Beach)",
//                                 "description": "Relax on a secluded beach on Son Tra Peninsula.",
//                                 "activities_possible": "Swimming, Sunbathing, Relaxation",
//                                 "price": 0.0,
//                                 "rule": "Bring your own snacks and drinks",
//                                 "recommend": "Quiet beach escape."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Con Market",
//                         "day": 2,
//                         "description": "Another large local market, known for its variety of food stalls and local snacks.",
//                         "flag": false,
//                         "time_start": "2024-07-28T16:00:00Z",
//                         "time_finish": "2024-07-28T18:00:00Z",
//                         "time_reminder": "15 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Afternoon/Evening",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Street food tour",
//                                 "description": "Sample various local dishes and snacks at Con Market's food stalls.",
//                                 "activities_possible": "Food Tasting, Cultural Immersion",
//                                 "price": 150000.0,
//                                 "rule": "Try small portions to sample more dishes",
//                                 "recommend": "Foodie paradise."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Dragon Bridge",
//                         "day": 2,
//                         "description": "A famous bridge that breathes fire and water on weekends (check schedule).",
//                         "flag": false,
//                         "time_start": "2024-07-28T20:30:00Z",
//                         "time_finish": "2024-07-28T21:30:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Evening (Weekend)",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Watch Dragon Bridge fire and water show",
//                                 "description": "Witness the spectacular fire and water breathing show on Dragon Bridge (weekends only).",
//                                 "activities_possible": "Sightseeing, Photography, Entertainment",
//                                 "price": 0.0,
//                                 "rule": "Check show schedule in advance",
//                                 "recommend": "Unique Da Nang experience."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Hoi An Ancient Town (Day Trip)",
//                         "day": 3,
//                         "description": "A UNESCO World Heritage site, charming ancient town with tailor shops, lanterns, and historical houses.",
//                         "flag": false,
//                         "time_start": "2024-07-29T09:00:00Z",
//                         "time_finish": "2024-07-29T17:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese, Chinese, Japanese",
//                         "recommended_time": "Full Day",
//                         "price": "150000",
//                         "activities": [
//                             {
//                                 "name": "Explore Ancient Town and historical sites",
//                                 "description": "Wander through the ancient streets, visit Japanese Covered Bridge, Tan Ky Old House, and Assembly Halls.",
//                                 "activities_possible": "Sightseeing, Photography, Cultural Exploration, Shopping",
//                                 "price": 150000.0,
//                                 "rule": "Walking is the best way to explore",
//                                 "recommend": "Must-visit for history and culture."
//                             },
//                             {
//                                 "name": "Lantern Boat Ride (Evening)",
//                                 "description": "Enjoy a romantic boat ride on Thu Bon River with colorful lanterns (optional, evening activity in Hoi An).",
//                                 "activities_possible": "Relaxation, Sightseeing, Romantic Experience",
//                                 "price": 100000.0,
//                                 "rule": "Negotiate price before boarding",
//                                 "recommend": "Magical evening experience."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Japanese Covered Bridge (Hoi An)",
//                         "day": 3,
//                         "description": "Iconic symbol of Hoi An, a beautiful bridge with a small temple inside.",
//                         "flag": false,
//                         "time_start": "2024-07-29T10:00:00Z",
//                         "time_finish": "2024-07-29T11:00:00Z",
//                         "time_reminder": "15 minutes before",
//                         "culture": "Japanese, Vietnamese",
//                         "recommended_time": "Morning",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Visit and photograph the bridge",
//                                 "description": "Admire the unique architecture and history of the Japanese Covered Bridge.",
//                                 "activities_possible": "Sightseeing, Photography, Cultural Exploration",
//                                 "price": 0.0,
//                                 "rule": "Respect the historical site",
//                                 "recommend": "Iconic landmark of Hoi An."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Tan Ky Old House (Hoi An)",
//                         "day": 3,
//                         "description": "Well-preserved ancient merchant house showcasing Hoi An's architectural heritage.",
//                         "flag": false,
//                         "time_start": "2024-07-29T11:30:00Z",
//                         "time_finish": "2024-07-29T12:30:00Z",
//                         "time_reminder": "15 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Morning",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Tour the ancient house",
//                                 "description": "Explore the interior and learn about the history and architecture of the old merchant house.",
//                                 "activities_possible": "Cultural Exploration, Historical Learning, Sightseeing",
//                                 "price": 0.0,
//                                 "rule": "Follow tour guide instructions if available",
//                                 "recommend": "Insight into Hoi An's past."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Local Restaurant in Hoi An (Morning Glory)",
//                         "day": 3,
//                         "description": "Enjoy authentic Hoi An cuisine at a local restaurant.",
//                         "flag": false,
//                         "time_start": "2024-07-29T13:00:00Z",
//                         "time_finish": "2024-07-29T14:30:00Z",
//                         "time_reminder": "15 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Lunch",
//                         "price": "250000",
//                         "activities": [
//                             {
//                                 "name": "Lunch with local specialties",
//                                 "description": "Taste Cao Lau, White Rose dumplings, and other Hoi An signature dishes.",
//                                 "activities_possible": "Food Tasting, Cultural Immersion",
//                                 "price": 250000.0,
//                                 "rule": "Try local recommendations",
//                                 "recommend": "Culinary highlight of Hoi An."
//                             }
//                         ]
//                     }
//                 ]
//             },
//             {
//                 "title": "Da Nang Nature & Local Experience Itinerary Plan 2",
//                 "description": "Discover Da Nang's hidden natural gems, local villages, and authentic culinary experiences.",
//                 "price": 4800000.0,
//                 "locations": [
//                     {
//                         "name": "Non Nuoc Beach",
//                         "day": 1,
//                         "description": "A quieter and more serene beach south of My Khe, known for its tranquility.",
//                         "flag": false,
//                         "time_start": "2024-07-27T07:00:00Z",
//                         "time_finish": "2024-07-27T09:00:00Z",
//                         "time_reminder": "15 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Morning",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Relax and enjoy the peaceful beach",
//                                 "description": "Start your day with a relaxing walk or swim in the calm waters of Non Nuoc Beach.",
//                                 "activities_possible": "Swimming, Sunbathing, Relaxation, Photography",
//                                 "price": 0.0,
//                                 "rule": "Maintain beach cleanliness",
//                                 "recommend": "Tranquil beach escape."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Nam O Fish Sauce Village",
//                         "day": 1,
//                         "description": "A traditional village famous for producing high-quality fish sauce using age-old methods.",
//                         "flag": false,
//                         "time_start": "2024-07-27T10:00:00Z",
//                         "time_finish": "2024-07-27T12:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Morning",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Village tour and fish sauce making process",
//                                 "description": "Visit local workshops, learn about the fish sauce making process, and sample authentic fish sauce.",
//                                 "activities_possible": "Cultural Immersion, Local Experience, Food Tasting, Learning",
//                                 "price": 50000.0,
//                                 "rule": "Ask for permission before taking photos",
//                                 "recommend": "Unique cultural and culinary experience."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Hai Van Pass",
//                         "day": 1,
//                         "description": "A scenic mountain pass with breathtaking views of the coastline and surrounding landscapes.",
//                         "flag": false,
//                         "time_start": "2024-07-27T14:00:00Z",
//                         "time_finish": "2024-07-27T17:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Afternoon",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Scenic motorbike or car ride",
//                                 "description": "Enjoy a motorbike or car ride along the Hai Van Pass, stopping at viewpoints for photos.",
//                                 "activities_possible": "Scenic Drive, Photography, Nature Exploration",
//                                 "price": 300000.0,
//                                 "rule": "Drive safely and wear helmets if motorbiking",
//                                 "recommend": "Iconic scenic route."
//                             },
//                             {
//                                 "name": "Lang Co Beach viewpoint",
//                                 "description": "Stop at Lang Co Beach viewpoint for stunning views of the lagoon and beach.",
//                                 "activities_possible": "Sightseeing, Photography",
//                                 "price": 0.0,
//                                 "rule": "Be mindful of traffic when stopping",
//                                 "recommend": "Picture-perfect viewpoint."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Thanh Khe Beach",
//                         "day": 1,
//                         "description": "A local beach frequented by Da Nang residents, offering a glimpse into local beach life.",
//                         "flag": false,
//                         "time_start": "2024-07-27T18:00:00Z",
//                         "time_finish": "2024-07-27T20:00:00Z",
//                         "time_reminder": "15 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Evening",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Evening walk and local seafood",
//                                 "description": "Enjoy an evening walk along the beach and dine at a local seafood restaurant.",
//                                 "activities_possible": "Relaxation, Food Tasting, Cultural Immersion",
//                                 "price": 300000.0,
//                                 "rule": "Choose restaurants with fresh seafood",
//                                 "recommend": "Local beach experience with fresh seafood."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Suoi Hoa Waterfall",
//                         "day": 2,
//                         "description": "A natural waterfall area with pools for swimming and relaxing in nature.",
//                         "flag": false,
//                         "time_start": "2024-07-28T09:00:00Z",
//                         "time_finish": "2024-07-28T12:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Morning",
//                         "price": "50000",
//                         "activities": [
//                             {
//                                 "name": "Swimming and relaxing at the waterfall",
//                                 "description": "Enjoy swimming in the natural pools and relax amidst the lush greenery.",
//                                 "activities_possible": "Swimming, Nature Relaxation, Picnic, Photography",
//                                 "price": 50000.0,
//                                 "rule": "Be cautious on slippery rocks",
//                                 "recommend": "Nature escape and refreshing swim."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Hoa Phu Thanh Waterfall (Alternative - Adventure)",
//                         "day": 2,
//                         "description": "An adventure waterfall with ziplining and water sliding activities (Entrance fee higher).",
//                         "flag": false,
//                         "time_start": "2024-07-28T09:00:00Z",
//                         "time_finish": "2024-07-28T13:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Morning",
//                         "price": "250000",
//                         "activities": [
//                             {
//                                 "name": "Ziplining and water sliding",
//                                 "description": "Experience thrilling ziplines and water slides at Hoa Phu Thanh Waterfall.",
//                                 "activities_possible": "Adventure Activities, Water Fun, Nature",
//                                 "price": 250000.0,
//                                 "rule": "Follow safety instructions for activities",
//                                 "recommend": "Adventure and adrenaline rush."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Cam Le Village",
//                         "day": 2,
//                         "description": "A traditional village known for making rice paper and tofu using traditional methods.",
//                         "flag": false,
//                         "time_start": "2024-07-28T15:00:00Z",
//                         "time_finish": "2024-07-28T17:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Afternoon",
//                         "price": "0",
//                         "activities": [
//                             {
//                                 "name": "Rice paper and tofu making demonstration",
//                                 "description": "Visit local families, witness the rice paper and tofu making process, and try making your own.",
//                                 "activities_possible": "Cultural Immersion, Local Experience, Learning, Food Tasting",
//                                 "price": 50000.0,
//                                 "rule": "Support local products by purchasing",
//                                 "recommend": "Authentic village experience."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Local Seafood Restaurant (Beachfront)",
//                         "day": 2,
//                         "description": "Enjoy fresh and affordable seafood at a local restaurant near the beach.",
//                         "flag": false,
//                         "time_start": "2024-07-28T19:00:00Z",
//                         "time_finish": "2024-07-28T21:00:00Z",
//                         "time_reminder": "15 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Evening",
//                         "price": "400000",
//                         "activities": [
//                             {
//                                 "name": "Seafood dinner",
//                                 "description": "Indulge in a delicious seafood dinner with a variety of fresh catches.",
//                                 "activities_possible": "Food Tasting, Local Cuisine, Relaxation",
//                                 "price": 400000.0,
//                                 "rule": "Check prices before ordering",
//                                 "recommend": "Fresh and flavorful seafood experience."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Cu Lao Cham Island (Day Trip)",
//                         "day": 3,
//                         "description": "A beautiful island with pristine beaches, coral reefs, and Cham ruins (Ferry required).",
//                         "flag": false,
//                         "time_start": "2024-07-29T08:00:00Z",
//                         "time_finish": "2024-07-29T17:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese, Cham",
//                         "recommended_time": "Full Day",
//                         "price": "600000",
//                         "activities": [
//                             {
//                                 "name": "Snorkeling and island exploration",
//                                 "description": "Snorkel or dive in the clear waters, explore beaches, and visit Cham ruins.",
//                                 "activities_possible": "Snorkeling, Diving, Beach Relaxation, Cultural Exploration, Island Hopping",
//                                 "price": 600000.0,
//                                 "rule": "Book ferry tickets in advance",
//                                 "recommend": "Island paradise escape."
//                             },
//                             {
//                                 "name": "Bai Chong Beach",
//                                 "description": "Relax on the beautiful Bai Chong Beach in Cu Lao Cham.",
//                                 "activities_possible": "Swimming, Sunbathing, Relaxation",
//                                 "price": 0.0,
//                                 "rule": "Protect marine environment",
//                                 "recommend": "Pristine beach experience."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Hon Yen Island (Alternative - Unique Rocks)",
//                         "day": 3,
//                         "description": "A unique island with striking black rock formations and tide pools (Ferry required, check tide times).",
//                         "flag": false,
//                         "time_start": "2024-07-29T08:00:00Z",
//                         "time_finish": "2024-07-29T12:00:00Z",
//                         "time_reminder": "30 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Morning",
//                         "price": "500000",
//                         "activities": [
//                             {
//                                 "name": "Explore rock formations and tide pools",
//                                 "description": "Walk around the island, admire the unique rock formations, and explore tide pools during low tide.",
//                                 "activities_possible": "Nature Exploration, Photography, Tide Pool Exploration",
//                                 "price": 500000.0,
//                                 "rule": "Check tide times before visiting",
//                                 "recommend": "Unique geological landscape."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "Seafood Market at Port (Local Lunch)",
//                         "day": 3,
//                         "description": "Enjoy fresh and affordable seafood directly from the market at the port.",
//                         "flag": false,
//                         "time_start": "2024-07-29T13:00:00Z",
//                         "time_finish": "2024-07-29T14:30:00Z",
//                         "time_reminder": "15 minutes before",
//                         "culture": "Vietnamese",
//                         "recommended_time": "Lunch",
//                         "price": "300000",
//                         "activities": [
//                             {
//                                 "name": "Seafood lunch",
//                                 "description": "Choose your seafood from the market and have it cooked at a nearby eatery.",
//                                 "activities_possible": "Food Tasting, Local Cuisine, Market Experience",
//                                 "price": 300000.0,
//                                 "rule": "Bargain for seafood prices",
//                                 "recommend": "Freshest seafood at best prices."
//                             }
//                         ]
//                     },
//                     {
//                         "name": "City View Coffee Shop (Roof Top)",
//                         "day": 3,
//                         "description": "Relax and enjoy panoramic city views from a rooftop coffee shop.",
//                         "flag": false,
//                         "time_start": "2024-07-29T16:00:00Z",
//                         "time_finish": "2024-07-29T18:00:00Z",
//                         "time_reminder": "15 minutes before",
//                         "culture": "Vietnamese, Modern",
//                         "recommended_time": "Afternoon/Evening",
//                         "price": "100000",
//                         "activities": [
//                             {
//                                 "name": "Coffee and city view",
//                                 "description": "Sip Vietnamese coffee and enjoy the sunset views over Da Nang city.",
//                                 "activities_possible": "Relaxation, Sightseeing, Photography, Socializing",
//                                 "price": 100000.0,
//                                 "rule": "Check for rooftop access",
//                                 "recommend": "Relaxing end to the trip."
//                             }
//                         ]
//                     }
//                 ]
//             }
//         ]
//     }
// }
//         ''';

        final responseBody = response.body;
        final itineraryResponse = parseItineraryResponse(responseBody);
        print("data cha${itineraryResponse.itinerary}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItineraryCreated(data: itineraryResponse),
          ),
        );
      } catch (e, stackTrace) {
        print("Lỗi khi xử lý JSON: $e");
        print("Stack Trace: $stackTrace");
      }
    } catch (error) {
      _showResponseDialog('Error', 'Failed to plan trip: $error');
    }
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
      body: Stack(
        children: [
          Padding(
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
                  }),
                  SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isPending ? null : _handleStartPlanning,
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
          if (isPending)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: LoadingAnimationWidget.threeRotatingDots(
                  color: AppColors.orangeColor,
                  size: 80,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleStartPlanning() async {
    setState(() {
      isPending = true;
    });

    await _sendDataToBackend();

    setState(() {
      isPending = false;
    });
  }
}
