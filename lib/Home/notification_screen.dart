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
    );
  }
}
