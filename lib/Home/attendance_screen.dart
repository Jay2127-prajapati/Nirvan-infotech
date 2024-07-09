import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nirvan_infotech/Home/notification_screen.dart';
import 'package:nirvan_infotech/colors/colors.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now(); // Initialize with current date
  DateTime _firstDay =
      DateTime.utc(2024, 1, 1); // Example: Start of the year 2024
  DateTime _lastDay =
      DateTime.utc(2024, 12, 31); // Example: End of the year 2024
  DateTime? _selectedDay;
  Map<DateTime, Map<String, String>> attendanceStatus = {};
  List<DateTime> attendanceDates = [];
  List<Map<String, dynamic>> attendanceData = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission;

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, show a dialog to enable it
        bool enableResult = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Location Services Disabled'),
              content:
                  Text('Please enable location services to use this feature.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Enable'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        // If user chose to enable location services
        if (enableResult == true) {
          // Request permission
          permission = await Geolocator.requestPermission();
        } else {
          // Handle if user canceled enabling location services
          return;
        }
      } else {
        // Location services are enabled, request permission directly
        permission = await Geolocator.requestPermission();
      }

      // Handle the permission result
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied (permanent).');
      } else if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
      } else {
        print('Location permissions granted!');
      }
    } catch (e) {
      print('Error checking location permission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
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
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TableCalendar(
                    firstDay: _firstDay,
                    lastDay: _lastDay,
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day) ||
                        attendanceDates.contains(day),
                    onDaySelected: (selectedDay, focusedDay) {
                      _handleDaySelected(selectedDay, focusedDay);
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: TextStyle(color: Colors.red),
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                  ),
                  Divider(thickness: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Attendance Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Implement search functionality
                              },
                              icon: Icon(Icons.search),
                              color: Colors.blue,
                            ),
                            IconButton(
                              onPressed: () {
                                // Implement filter functionality
                              },
                              icon: Icon(Icons.filter_list),
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: attendanceData.length,
                    itemBuilder: (context, index) {
                      final data = attendanceData[index];
                      final entryTime =
                          attendanceStatus[data['date']]?['inTime'] ?? '-';
                      final exitTime =
                          attendanceStatus[data['date']]?['outTime'] ?? '-';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                '${data['date'].day}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text('Entry: $entryTime - Exit: $exitTime'),
                            subtitle: Text(
                              data['attended']
                                  ? 'Welcome To Nirvan Institute'
                                  : 'Thanks for your time.\nYour day is completed.',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    await _showAttendanceDialog(selectedDay);
  }

  Future<void> _showAttendanceDialog(DateTime selectedDay) async {
    bool hasExistingData = attendanceStatus.containsKey(selectedDay);

    bool isWithinLocation = await _checkLocation();

    if (!isWithinLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are not within the attendance area.')),
      );
      return;
    }

    String entryTime = '-';
    String exitTime = '-';

    if (hasExistingData) {
      entryTime = attendanceStatus[selectedDay]!['inTime'] ?? '-';
      exitTime = attendanceStatus[selectedDay]!['outTime'] ?? '-';
    }

    bool? isAttended = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "Attendance for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text("I'm in"),
                onTap: () {
                  Navigator.of(context).pop(true);
                },
              ),
              ListTile(
                title: Text("I'm out"),
                onTap: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        );
      },
    );

    if (isAttended != null) {
      setState(() {
        if (!hasExistingData) {
          attendanceStatus[selectedDay] = {
            'inTime': isAttended ? _formatTime(DateTime.now()) : '-',
            'outTime': isAttended ? '-' : _formatTime(DateTime.now()),
          };

          attendanceData.add({
            'date': selectedDay,
            'attended': isAttended,
          });

          if (isAttended) {
            attendanceDates.add(selectedDay);
          }
        } else {
          attendanceStatus[selectedDay]!['outTime'] =
              _formatTime(DateTime.now());

          attendanceData
              .where((element) => element['date'] == selectedDay)
              .forEach((element) {
            element['attended'] = isAttended;
          });

          if (isAttended) {
            if (!attendanceDates.contains(selectedDay)) {
              attendanceDates.add(selectedDay);
            }
          } else {
            attendanceDates.remove(selectedDay);
          }
        }
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour < 12 ? 'AM' : 'PM'}';
  }

  Future<bool> _checkLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double attendanceLatitude = 22.561703;
      double attendanceLongitude = 72.922973;

      double distanceInMeters = await Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        attendanceLatitude,
        attendanceLongitude,
      );

      return distanceInMeters <= 100;
    } catch (e) {
      print('Error fetching location: $e');
      return false;
    }
  }
}
