import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nirvan_infotech/Authentications/login_screen.dart';
import 'package:nirvan_infotech/Home/notification_screen.dart';
import 'package:nirvan_infotech/colors/colors.dart';
import 'package:nirvan_infotech/work/course_screen.dart';
import 'package:nirvan_infotech/work/work_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../const fiels/const.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({Key? key}) : super(key: key);

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  bool isDarkMode = false; // Track the state of dark mode
  Map<String, dynamic> profileData = {}; // Store profile data
  Uint8List? imageBytes; // Store image bytes

  @override
  void initState() {
    super.initState();
    fetchProfileData(); // Fetch profile data when the screen initializes
  }

  // Function to fetch profile data from the API
  Future<void> fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final empId = prefs.getString('empId');

    if (empId != null) {
      final response = await http.get(
        Uri.parse(
            'http://$baseIpAddress/nirvan-api/employee/fetch_emp.php?empId=$empId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('Decoded Response Data: $data');

        if (data['success']) {
          setState(() {
            profileData = data;
            if (data['image'] != null) {
              try {
                print('Base64 Image String: ${data['image']}');

                // Normalize and decode the Base64 string
                String normalizedBase64 = base64Normalize(data['image']);
                print('Normalized Base64 String: $normalizedBase64');
                imageBytes = base64Decode(normalizedBase64);
                print('Image bytes: $imageBytes');

                // Optional: Load the image into an Image widget
                // imageWidget = Image.memory(imageBytes);
              } catch (e) {
                print('Error decoding image: $e');
              }
            }
          });
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } else {
      print('empId is null');
    }
  }

  String base64Normalize(String base64String) {
    return base64String.padRight(
        base64String.length + (4 - base64String.length % 4) % 4, '=');
  }

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
    // Clear all stored data in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This will remove all key-value pairs

    // Optionally, clear cached files or other local data
    // Uncomment and adjust the following if needed:
    // await _clearCachedFiles();

    // Navigate to login screen and clear the navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) =>
          false, // This ensures the user cannot go back to the previous screen
    );
  }

  // Optional: Function to clear cached files or other local data
  // Future<void> _clearCachedFiles() async {
  //   // Implement logic to clear cached files, if applicable
  // }

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
              const CircleAvatar(
                radius: 75,
                backgroundColor: secondaryColorSmokeGrey,
                backgroundImage: AssetImage('assets/img/boy.png'),
                child:
                    null, // No need to display a child icon since the image is always available
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                profileData.isNotEmpty ? profileData['name'] : '',
                style: const TextStyle(
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
                        Text(
                          profileData.isNotEmpty
                              ? (profileData['domain'] != null
                                  ? profileData['domain'].toString()
                                  : 'No domain data') // Fallback text
                              : 'No domain data', // Fallback text
                          style: const TextStyle(
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
                        Text(
                          profileData.isNotEmpty
                              ? (profileData['experience'] != null
                                  ? profileData['experience'].toString()
                                  : 'No experience data') // Fallback text
                              : 'No experience data', // Fallback text
                          style: const TextStyle(
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
                ],
              ),

              // Container(
              //   width: MediaQuery.of(context).size.width * 0.86,
              //   margin: const EdgeInsets.symmetric(vertical: 10.0),
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Navigate to the next screen
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const SettingsScreen()),
              //       );
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor:
              //           secondaryColorSmokewhite, // Your desired background color
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10.0),
              //         side: const BorderSide(
              //           color:
              //               secondaryColorSmokeGrey, // Your desired border color
              //           width: 2.0,
              //         ),
              //       ),
              //     ),
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(
              //           vertical: 13.0, horizontal: 1.0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Align(
              //             alignment: Alignment.centerLeft,
              //             child: Image.asset(
              //               'assets/img/settings.png',
              //               width: 28,
              //               height: 28,
              //             ),
              //           ),
              //           const Text(
              //             'Settings',
              //             style: TextStyle(
              //               fontSize: 18.0,
              //               fontWeight: FontWeight.bold,
              //               color:
              //                   secondaryColorSmokeGrey, // Your desired text color
              //               fontFamily: 'roboto',
              //             ),
              //           ),
              //           Align(
              //             alignment: Alignment.centerLeft,
              //             child: Image.asset(
              //               'assets/img/arrow.png',
              //               width: 28,
              //               height: 28,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              Container(
                width: MediaQuery.of(context).size.width * 0.86,
                margin: const EdgeInsets.symmetric(vertical: 20.0),
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
