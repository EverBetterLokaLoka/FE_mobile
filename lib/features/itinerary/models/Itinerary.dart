import 'dart:convert';

class ItineraryResponse {
  final List<Itinerary> itinerary;

  ItineraryResponse({required this.itinerary});

  factory ItineraryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    if (data != null) {
      final itineraryData = data['itinerary'];
      List<dynamic> itineraryList = [];

      if (itineraryData is List) {
        itineraryList = itineraryData;
      } else if (itineraryData is Map) {
        itineraryList = [itineraryData];
      }

      return ItineraryResponse(
        itinerary: itineraryList.map((e) => Itinerary.fromJson(e)).toList(),
      );
    }

    return ItineraryResponse(itinerary: []);
  }
}

class Itinerary {
  String? title;
  final String? description;
  final String? price;
  final List<Location> locations;

  Itinerary({
    this.title,
    this.description,
    this.price,
    required this.locations,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      title: json['title'],
      description: json['description'],
      // price: (json['price'] as num).toDouble(),
      price: json['price'].toString(),
      locations:
          (json['locations'] as List).map((e) => Location.fromJson(e)).toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'Itinerary(title: $title, description: $description, price: $price, locations: $locations)';
  }
}

class Location {
  final String name;
  final int? day;
  final String description;
  final bool? flag;
  final DateTime timeStart;
  final DateTime timeFinish;
  final String? timeReminder;
  final String? culture;
  final String? recommendedTime;
  final String? price;
  final List<Activity> activities;

  Location({
    required this.name,
    this.day,
    required this.description,
    this.flag,
    required this.timeStart,
    required this.timeFinish,
    this.timeReminder,
    this.culture,
    this.recommendedTime,
    this.price,
    required this.activities,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'],
      day: json['day'],
      description: json['description'],
      flag: json['flag'],
      timeStart: DateTime.parse(json['time_start']),
      timeFinish: DateTime.parse(json['time_finish']),
      timeReminder: json['time_reminder'],
      culture: json['culture'],
      recommendedTime: json['recommended_time'],
      price: json['price'].toString(),
      activities: (json['activities'] as List)
          .map((e) => Activity.fromJson(e))
          .toList(),
    );
  }
}

class Activity {
  final String? name;
  final String? description;
  final String? activitiesPossible;
  final String? price;
  final String? rule;
  final String? recommend;

  Activity({
    this.name,
    this.description,
    this.activitiesPossible,
    this.price,
    this.rule,
    this.recommend,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json['name'] as String,
      description: json['description'] as String,
      activitiesPossible: json['activityPossible'] as String?,
      recommend: json['recommend'] as String?,
      rule: json['rule'] as String?,
      // price: (json['price'] is num)
      //     ? (json['price'] as num).toDouble()
      //     : double.tryParse(json['price'].toString()) ?? 0.0,
      price: json['price'].toString()
    );
  }

  @override
  String toString() {
    return 'Activity(name: $name, description: $description, price: $price)';
  }
}

ItineraryResponse parseItineraryResponse(String jsonStr) {
  final Map<String, dynamic> jsonData = json.decode(jsonStr);
  return ItineraryResponse.fromJson(jsonData);
}
