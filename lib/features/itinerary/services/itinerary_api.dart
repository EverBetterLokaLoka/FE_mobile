import '../../../core/utils/apis.dart';
import '../models/Itinerary.dart';

class ItineraryApi {
  final ApiService _apiService = ApiService();

  Future<bool?> saveItinerary(Itinerary itinerary) async {
    try {
      final Map<String, dynamic> body = {
        "title": itinerary.title,
        "description": itinerary.description,
        "price": itinerary.price,
        "locations": itinerary.locations.map((location) {
          return {
            "name": location.name,
            "day": location.day,
            "description": location.description,
            "flag": location.flag ?? false,
            "time_start": location.timeStart.toUtc().toIso8601String(),
            "time_finish": location.timeFinish.toUtc().toIso8601String(),
            "time_reminder": location.timeReminder,
            "culture": location.culture,
            "recommended_time": location.recommendedTime,
            "price": location.price ?? "0.0",
            "activities": location.activities.map((activity) {
              return {
                "name": activity.name,
                "description": activity.description,
                "activities_possible": activity.activitiesPossible,
                "price": activity.price,
                "rule": activity.rule,
                "recommend": activity.recommend,
              };
            }).toList(),
          };
        }).toList(),
      };

      final response = await _apiService.request(
        path: '/itineraries',
        method: 'POST',
        typeUrl: 'baseUrl',
        currentPath: '',
        data: body,
      );

      if (response.statusCode == 201) {
        print("Itinerary saved successfully!");
        return true;
      } else {
        print("Failed to save itinerary: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error saving itinerary: $e");
    }
  }
}
