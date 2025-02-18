import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel AI App',
      theme: ThemeData(fontFamily: 'Roboto', primarySwatch: Colors.blue),
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
