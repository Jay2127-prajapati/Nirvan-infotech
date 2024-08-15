// admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:nirvan_infotech/Admin/all_employee_list.dart';
import 'package:nirvan_infotech/Admin/task.dart';
import 'package:nirvan_infotech/Admin/watch_attendance.dart';
import 'package:nirvan_infotech/colors/colors.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: primaryColorWhite,
            fontFamily: 'roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColorOcenblue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildBoxButton(
                context,
                icon: Icons.event, // Or Icons.calendar_today
                label: 'Employee Attendance',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WatchAttendance(),
                    ),
                  );
                },
              ),
              _buildBoxButton(
                context,
                icon: Icons.emoji_people_outlined,
                label: 'All Employes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllEmployeeList(),
                    ),
                  );
                },
              ),
              _buildBoxButton(
                context,
                icon: Icons.analytics,
                label: 'Task',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Task(),
                    ),
                  );
                },
              ),
              _buildBoxButton(
                context,
                icon: Icons.settings,
                label: 'Action 3',
                onTap: () {
                  // Implement action 3
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoxButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Custom shadow color
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3), // Shadow direction
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.blue, // Icon color
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
