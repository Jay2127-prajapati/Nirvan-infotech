import 'package:flutter/material.dart';
import 'package:nirvan_infotech/colors/colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: secondaryColorSmokewhite,
            fontWeight: FontWeight.bold,
            fontFamily: 'roboto',
          ),
        ),
        backgroundColor: primaryColorOcenblue,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: secondaryColorSmokewhite,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loader
            const CircularProgressIndicator(
              color: primaryColorNaiveblue, // Adjust color as needed
            ),
            const SizedBox(height: 20.0), // Space between loader and text
            // Work in progress message
            Text(
              "Work in progress. Not built yet.",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: secondaryColorSmokeGrey,
                fontFamily: 'roboto',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
