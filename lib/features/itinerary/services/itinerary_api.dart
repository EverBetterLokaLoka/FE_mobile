import 'dart:convert';

import '../../../core/utils/apis.dart';
import '../models/Itinerary.dart';

class ItineraryApi {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> fetchItineraries() async {
    try {
      final response = await _apiService.request(
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
            return List<Map<String, dynamic>>.from(data);
          }
        }
      }
    } catch (e) {
      print("Error fetching itineraries: $e");
    }
    return [];
  }

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
        return false;
      }
    } catch (e) {
      print("Error saving itinerary: $e");
    }
    return false;
  }

  Future<Itinerary> getItineraryById(int itineraryId) async {
    try {
      final response = await _apiService.request(
        path: '/itineraries/$itineraryId',
        method: 'GET',
        typeUrl: 'baseUrl',
        currentPath: '',
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);

        if (responseBody is Map<String, dynamic>) {
          if (responseBody.containsKey('data') &&
              responseBody['data'] != null) {
            return Itinerary.fromJson(responseBody['data']);
          }
          return Itinerary(
              id: 0,
              title: "Unknown",
              description: "No data",
              price: "0",
              locations: []);
        }
      }
    } catch (e) {
      print("Error fetching itinerary by ID: $e");
    }
    return Itinerary(locations: [], id: 0);
  }

  Future<bool?> deleteItinerary(int itineraryId) async {
    try {
      final response = await _apiService.request(
        path: '/itineraries/$itineraryId',
        method: 'DELETE',
        typeUrl: 'baseUrl',
        currentPath: '',
      );

      if (response.statusCode == 200) {
        print("Itinerary deleted successfully!");
        return true;
      } else {
        print("Failed to delete itinerary: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error deleting itinerary: $e");
      return false;
    }
  }
}
