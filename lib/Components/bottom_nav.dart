import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:nirvan_infotech/Admin/add_user.dart';
import 'package:nirvan_infotech/Admin/admin_home_screen.dart';
import 'package:nirvan_infotech/Admin/admin_profile.dart';
import 'package:nirvan_infotech/Home/attendance_screen.dart';
import 'package:nirvan_infotech/Home/home_screen.dart';
import 'package:nirvan_infotech/Home/profile_screen.dart';
import 'package:nirvan_infotech/Student/home_screen.dart';
import 'package:nirvan_infotech/colors/colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final String role;

  const CustomBottomNavigationBar({Key? key, required this.role})
      : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late NavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    _navigationController = Get.put(NavigationController());
    _navigationController.setRole(widget.role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Obx(() {
        return CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: primaryColorOcenblue,
          color: primaryColorOcenblue,
          animationDuration: const Duration(milliseconds: 300),
          index: _navigationController.selectedIndex.value,
          items: _buildNavigationItems(),
          onTap: (index) {
            _navigationController.selectedIndex.value = index;
          },
        );
      }),
      body: Obx(() {
        return _navigationController
            .screens[_navigationController.selectedIndex.value];
      }),
    );
  }

  List<Widget> _buildNavigationItems() {
    switch (widget.role) {
      case 'admin':
        return [
          const Icon(Icons.home, size: 26, color: primaryColorWhite),
          const Icon(Icons.person_add, size: 26, color: primaryColorWhite),
          const Icon(Icons.settings, size: 26, color: primaryColorWhite),
        ];
      case 'employee':
        return [
          const Icon(Icons.home, size: 26, color: primaryColorWhite),
          const Icon(Icons.assignment,
              size: 26, color: primaryColorWhite), // Example icon
          const Icon(Icons.person, size: 26, color: primaryColorWhite),
        ];
      case 'student':
        return [
          const Icon(Icons.home, size: 26, color: primaryColorWhite),
          const Icon(Icons.library_books,
              size: 26, color: primaryColorWhite), // Example icon
          const Icon(Icons.person, size: 26, color: primaryColorWhite),
        ];
      default:
        return [
          const Icon(Icons.home, size: 26, color: primaryColorWhite),
          const Icon(Icons.error,
              size: 26, color: primaryColorWhite), // Default error icon
          const Icon(Icons.error, size: 26, color: primaryColorWhite),
        ];
    }
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  late List<Widget> _screens;

  NavigationController() : _screens = [];

  List<Widget> get screens => _screens;

  void setRole(String role) {
    switch (role) {
      case 'admin':
        _screens = [
          const AdminHomeScreen(),
          const AddUser(),
          const AdminProfile()
        ];
        break;
      case 'employee':
        _screens = [
          const HomeScreen(),
          const AttendanceScreen(),
          const ProfileScreen()
        ];
        break;
      case 'student':
        _screens = [
          const StuHomeScreen(),
          const StuHomeScreen(), // Adjust according to actual screens
          const StuHomeScreen()
        ];
        break;
      default:
        _screens = [
          const AdminHomeScreen(), // Default screens or error handling
          const AdminHomeScreen(),
          const AdminHomeScreen()
        ];
    }
  }
}
