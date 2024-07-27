import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nirvan_infotech/Admin/ComponentsAdmin/bottom_bar.dart';
import 'package:nirvan_infotech/Components/bottom_nav.dart';
import 'package:nirvan_infotech/Student/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirvan_infotech/Authentications/login_screen.dart';
import 'package:nirvan_infotech/colors/colors.dart';

const String adminRole = 'admin';
const String studentRole = 'student';
const String employeeRole = 'employee';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String role = prefs.getString('role') ?? '';

    Timer(
      const Duration(seconds: 4),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (isLoggedIn) {
                switch (role) {
                  case adminRole:
                    return const AdminBottomNavigationBar();
                  case studentRole:
                    return const StuHomeScreen();
                  case employeeRole:
                    return const CustomBottomNavigationBar();
                  default:
                    return const LoginScreen();
                }
              } else {
                return const LoginScreen();
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Container(
                child: Image.asset(
                  'assets/img/nirvan-logo.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              Text(
                'NIRVAN',
                style: TextStyle(
                  color: primaryColorOcenblue,
                  fontSize: MediaQuery.of(context).size.width * 0.08,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'roboto',
                ),
              ),
              Text(
                'INFOTECH',
                style: TextStyle(
                  color: primaryColorOcenblue,
                  fontSize: MediaQuery.of(context).size.width * 0.08,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'roboto',
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.35),
              Text(
                'Presented By :- ',
                style: TextStyle(
                  color: primaryColorOcenblue,
                  fontSize: MediaQuery.of(context).size.width * 0.025,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'roboto',
                ),
              ),
              Text(
                'Nirvan Infotech',
                style: TextStyle(
                  color: primaryColorOcenblue,
                  fontSize: MediaQuery.of(context).size.width * 0.03,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'roboto',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
