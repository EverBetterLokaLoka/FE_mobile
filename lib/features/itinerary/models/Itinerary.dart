import 'package:flutter/material.dart';

class Itinerary {
  final String title;
  final String description;
  final double price;
  final List<Location> locations;

  Itinerary({
   required this.title,
    required this.description,
    required this.price,
    required this.locations
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      locations: (json['locations'] as List)
          .map((location) => Location.fromJson(location))
          .toList(),
    );
  }
}

class Location {
  final String name;
  final int day;
  final String description;
  final bool flag;
  final DateTime timeStart;
  final DateTime timeFinish;
  final String timeReminder;
  final String culture;
  final String recommendedTime;
  final double price;
  final List<Activity> activities;

  Location({
    required this.name,
    required this.day,
    required this.description,
    required this.flag,
    required this.timeStart,
    required this.timeFinish,
    required this.timeReminder,
    required this.culture,
    required this.recommendedTime,
    required this.price,
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
      price: double.parse(json['price']),
      activities: (json['activities'] as List)
          .map((activity) => Activity.fromJson(activity))
          .toList(),
    );
  }
}

class Activity {
  final String name;
  final String description;
  final String activitiesPossible;
  final double price;
  final String rule;
  final String recommend;

  Activity({
    required this.name,
    required this.description,
    required this.activitiesPossible,
    required this.price,
    required this.rule,
    required this.recommend,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json['name'],
      description: json['description'],
      activitiesPossible: json['activities_possible'],
      price: json['price'].toDouble(),
      rule: json['rule'],
      recommend: json['recommend'],
    );
  }
}