import 'package:flutter/material.dart';
import 'package:nirvan_infotech/Authentications/login_screen.dart';
import 'package:nirvan_infotech/Home/notification_screen.dart';
import 'package:nirvan_infotech/Home/settings_screen.dart';
import 'package:nirvan_infotech/colors/colors.dart';
import 'package:nirvan_infotech/work/course_screen.dart';
import 'package:nirvan_infotech/work/task_screen.dart';
import 'package:nirvan_infotech/work/work_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false; // Track the state of dark mode

  // Function to show the logout confirmation dialog
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: secondaryColorSmokewhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/img/nirvan-logo.png',
                  width: 72,
                ),
                const SizedBox(
                  height: 24,
                ),
                const Text(
                  'Nirvan Infotech',
                  style: TextStyle(
                    fontFamily: 'montserrat',
                    color: secondaryColorSmokeGrey,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                const Text(
                  'Are You Sure You \n Want To Logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'roboto',
                    color: secondaryColorSmokeGrey,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 32,
                        ),
                        foregroundColor: orange,
                        side: const BorderSide(color: primaryColorNaiveblue),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: const Text('NO'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColorNaiveblue,
                        foregroundColor: secondaryColorSmokeGrey,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 32,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        _logout(); // Call logout function
                      },
                      child: const Text(
                        'YES',
                        style: TextStyle(
                            fontFamily: 'roboto',
                            color: secondaryColorSmokeGrey,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to handle logout
  void _logout() async {
    // Clear any stored user information if using SharedPreferences or similar
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
        'isLoggedIn'); // Assuming 'isLoggedIn' is the key used for login status

    // Navigate to login screen and clear the navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) =>
          false, // This ensures the user cannot go back to the previous screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: secondaryColorSmokewhite,
            fontFamily: 'poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColorOcenblue,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications),
            color: secondaryColorSmokewhite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 8.5,
              ),
              CircleAvatar(
                radius: 75,
                backgroundColor: secondaryColorSmokeGrey,
                backgroundImage: const AssetImage('assets/img/boy.png'),
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColorNaiveblue,
                        width: 3.0,
                      ),
                    ),
                    child: Image.asset(
                      'assets/img/boy.png',
                      fit: BoxFit.cover,
                      width: 170,
                      height: 170,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                'Jay Prajapati',
                style: TextStyle(
                  color: secondaryColorSmokeGrey,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModulesScreen(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        const Text(
                          'Domain',
                          style: TextStyle(
                            fontSize: 15.5,
                            color: secondaryColorSmokeGrey,
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '    Software \n Development',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: secondaryColorSmokeGrey,
                            fontFamily: 'roboto',
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: secondaryColorSmokeGrey,
                          child: ClipOval(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColorNaiveblue,
                                  width: 3.0,
                                ),
                              ),
                              child: Image.asset(
                                'assets/img/course.png',
                                width: 70,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 13.5,
                        ),
                        const Text(
                          'Modules',
                          style: TextStyle(
                            fontFamily: 'roboto',
                            color: secondaryColorSmokeGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkScreen(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        const Text(
                          'Experience',
                          style: TextStyle(
                            fontSize: 15.5,
                            color: secondaryColorSmokeGrey,
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '5 years',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: secondaryColorSmokeGrey,
                            fontFamily: 'roboto',
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: secondaryColorSmokeGrey,
                          child: ClipOval(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColorNaiveblue,
                                  width: 3.0,
                                ),
                              ),
                              child: Image.asset(
                                'assets/img/working.png',
                                width: 70,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          'Your Work',
                          style: TextStyle(
                            fontFamily: 'roboto',
                            color: secondaryColorSmokeGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TaskScreen(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        const Text(
                          'Completed Task',
                          style: TextStyle(
                            fontSize: 15.5,
                            color: secondaryColorSmokeGrey,
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '100+',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: secondaryColorSmokeGrey,
                            fontFamily: 'roboto',
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: secondaryColorSmokeGrey,
                          child: ClipOval(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColorNaiveblue,
                                  width: 3.0,
                                ),
                              ),
                              child: Image.asset(
                                'assets/img/planning.png',
                                width: 70,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        const Text(
                          'Tasks',
                          style: TextStyle(
                            fontFamily: 'roboto',
                            color: secondaryColorSmokeGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.86,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        secondaryColorSmokewhite, // Your desired background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(
                        color:
                            secondaryColorSmokeGrey, // Your desired border color
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13.0, horizontal: 1.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/img/settings.png',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color:
                                secondaryColorSmokeGrey, // Your desired text color
                            fontFamily: 'roboto',
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/img/arrow.png',
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.86,
                margin: const EdgeInsets.symmetric(vertical: 1.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle onPressed event
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      secondaryColorSmokewhite,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: secondaryColorSmokeGrey,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 3.5, horizontal: 1.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/img/theme.png',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: secondaryColorSmokeGrey,
                            fontFamily: 'roboto',
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            value: isDarkMode,
                            onChanged: (value) {
                              setState(() {
                                isDarkMode = value;
                                // Implement dark mode toggle functionality here
                              });
                            },
                            activeColor: primaryColorSkyblue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.86,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed: _showLogoutConfirmationDialog,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      secondaryColorSmokewhite,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: secondaryColorSmokeGrey,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 1.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: secondaryColorSmokeGrey,
                              fontFamily: 'roboto',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/img/logout.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
