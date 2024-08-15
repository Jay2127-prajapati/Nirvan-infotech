// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:nirvan_infotech/Home/notification_screen.dart';
import 'package:nirvan_infotech/colors/colors.dart';

class StuHomeScreen extends StatefulWidget {
  const StuHomeScreen({Key? key}) : super(key: key);

  @override
  State<StuHomeScreen> createState() => _StuHomeScreenState();
}

class _StuHomeScreenState extends State<StuHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nirvan Infotech',
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
      body: Column(
        children: const <Widget>[
          SizedBox(
            height: 16.0,
          ),
          // You can add other widgets here if needed.
        ],
      ),
    );
  }
}
