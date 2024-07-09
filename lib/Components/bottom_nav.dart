import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:nirvan_infotech/Home/attendance_screen.dart';
import 'package:nirvan_infotech/Home/home_screen.dart';
import 'package:nirvan_infotech/Home/profile_screen.dart';
import 'package:nirvan_infotech/Home/settings_screen.dart';
import 'package:nirvan_infotech/colors/colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({
    Key? key,
  }) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late NavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    _navigationController = Get.put(
        NavigationController()); // Initialize NavigationController instance
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(() => CurvedNavigationBar(
            backgroundColor: Colors.transparent,
            buttonBackgroundColor: primaryColorOcenblue,
            color: primaryColorOcenblue,
            animationDuration: const Duration(milliseconds: 300),
            index: _navigationController.selectedIndex
                .value, // Use selectedIndex from NavigationController
            items: const <Widget>[
              Icon(Icons.home, size: 26, color: secondaryColorSmokewhite),
              Icon(Icons.person_add, size: 26, color: secondaryColorSmokewhite),
              Icon(Icons.search, size: 26, color: secondaryColorSmokewhite),
              Icon(Icons.settings, size: 26, color: secondaryColorSmokewhite),
            ],
            onTap: (index) {
              controller.selectedIndex.value = index;
              setState(() {}); // Trigger a rebuild to update the UI
            },
          )),
      body: Obx(() => _navigationController
          .screens[_navigationController.selectedIndex.value]),
    );
  }
}

// ignore: unused_element
List<Widget> _buildNavigationItems() {
  return [
    _buildNavigationItem(Icons.home, 26, secondaryColorSmokewhite),
    _buildNavigationItem(Icons.person_add, 26, secondaryColorSmokewhite),
    _buildNavigationItem(Icons.search, 26, secondaryColorSmokewhite),
    _buildNavigationItem(Icons.settings, 26, secondaryColorSmokewhite),
  ];
}

Widget _buildNavigationItem(IconData icon, double size, Color color) {
  return NavigationDestination(
    icon: Icon(icon, size: size, color: color),
    size: size,
    color: color,
  );
}

class NavigationDestination extends StatelessWidget {
  final Icon icon;
  final double size;
  final Color color;

  const NavigationDestination({
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
      ],
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    const AttendanceScreen(),
    const HomeScreen(),
    const ProfileScreen()
  ];
}
