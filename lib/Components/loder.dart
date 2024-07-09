import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nirvan_infotech/colors/colors.dart';

class WaveLoader extends StatelessWidget {
  final Color color;
  final double size;

  const WaveLoader({
    Key? key,
    this.color = primaryColorOcenblue,
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Set background color to white
      child: Center(
        child: SpinKitWave(
          color: color,
          size: size,
        ),
      ),
    );
  }
}
