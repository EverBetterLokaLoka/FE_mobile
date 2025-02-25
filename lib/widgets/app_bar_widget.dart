import 'package:flutter/material.dart';
import '../core/styles/colors.dart';
import '../features/notification/screens/notification_screen.dart';
import 'menu_widget.dart';

class AppBarCustom extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: AppColors.primaryColor,
        padding: EdgeInsets.symmetric(vertical: 3),
        notchMargin: 4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, '/home', AppColors.orangeColor, context),
            _buildNavItem(Icons.map, '/map', Colors.white, context),
            SizedBox(width: 40),
            _buildNavItem(Icons.notifications, '', Colors.white, context,
                screen: NotificationScreen()),
            _buildNavItem(Icons.menu, '', Colors.white, context, screen: Menu()),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String route, Color color,
      BuildContext context, {Widget? screen}) {
    return IconButton(
      icon: Icon(icon, color: color, size: 30),
      onPressed: () {
        if (screen != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => screen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
            ),
          );
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
