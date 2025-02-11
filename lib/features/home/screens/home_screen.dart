import 'package:flutter/material.dart';
import '../widgets/home_card.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final HomeController _controller = HomeController();  // Khởi tạo controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang Chủ Du Lịch AI'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _controller.getDestinations().length,
          itemBuilder: (context, index) {
            final destination = _controller.getDestinations()[index];
            return HomeCard(destination: destination);  // Sử dụng widget HomeCard
          },
        ),
      ),
    );
  }
}
