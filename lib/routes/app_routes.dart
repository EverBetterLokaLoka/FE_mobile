import 'package:flutter/material.dart';
import '../core/constants/routes_constant.dart';
import '../features/auth/screens/intro_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/itinerary/screens/create_itinerary_screen.dart';

final router = RoutesConstant();  // Tạo instance của Router

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => CreateItinerary());
        // return MaterialPageRoute(builder: (_) => IntroScreen());
      case '/login':
        // return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/profile':
        // return MaterialPageRoute(builder: (_) => ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Không tìm thấy trang: ${settings.name}'),
            ),
          ),
        );
    }
  }
}