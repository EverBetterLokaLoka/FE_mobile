import 'package:flutter/material.dart';
import 'package:lokaloka/features/profile/screens/profile_screen.dart';
import '../core/constants/routes_constant.dart';
import '../features/auth/screens/intro_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/itinerary/screens/create_itinerary_screen.dart';

final router = RoutesConstant(); // Tạo instance của Router

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => IntroScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/login':
      return MaterialPageRoute(builder: (_) => Login());
      case '/create-itinerary':
        return MaterialPageRoute(builder: (_) => CreateItinerary());
      case '/profile':
      return MaterialPageRoute(builder: (_) => ProfileScreen());
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
