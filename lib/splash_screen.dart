import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 70.0,
          ),
          Center(
            child: Container(
              child: Image.asset(
                'assets/img/nirvan-logo.png',
                width: 180,
                height: 180,
              ),
            ),
          ),
          const SizedBox(),
          Container(
            child: Text('data'),
          ),
        ],
      ),
    );
  }
}
