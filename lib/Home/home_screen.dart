import 'package:flutter/material.dart';
import 'package:nirvan_infotech/Home/notification_screen.dart';
import 'package:nirvan_infotech/colors/colors.dart';
import 'package:nirvan_infotech/const%20fiels/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _empId;
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> newTasks = [];
  List<Map<String, dynamic>> pendingTasks = [];

  @override
  void initState() {
    super.initState();
    _getEmpId(); // Retrieve empId and fetch tasks
  }

  Future<void> _getEmpId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _empId = prefs.getString('employeeId'); // Use the correct key
      print('Retrieved empId: $_empId'); // Debug print
    });
    if (_empId != null && _empId!.isNotEmpty) {
      _fetchTasks(); // Fetch tasks after empId is retrieved
    } else {
      print('Employee ID is not available.');
    }
  }

  Future<void> _fetchTasks() async {
    if (_empId == null || _empId!.isEmpty) {
      print('Employee ID is not available.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://$baseIpAddress/nirvan-api/employee/fetch_task.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'fetch', 'empid': _empId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _tasks = List<Map<String, dynamic>>.from(data['tasks']);
            _filterTasks(); // Filter tasks based on their status
          });
        } else {
          print('Error fetching tasks: ${data['message']}');
        }
      } else {
        print('Failed to load tasks, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  void _filterTasks() {
    newTasks = _tasks.where((task) => task['status'] == 'new').toList();
    pendingTasks = _tasks.where((task) => task['status'] == 'pending').toList();
  }

  Widget _buildTaskItem(Map<String, dynamic> task, double itemWidth) {
    Color statusColor;
    if (task['status'] == 'new') {
      statusColor = Colors.blue;
    } else if (task['status'] == 'pending') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.black;
    }

    return Container(
      width: itemWidth,
      margin: EdgeInsets.symmetric(
        horizontal: itemWidth * 0.02, // Responsive margin
        vertical: 8.0, // Fixed vertical margin for better spacing
      ),
      padding: EdgeInsets.all(12.0), // Consistent padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: secondaryColorSmokewhite,
            child: Icon(Icons.task, color: primaryColorOcenblue, size: 24),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['task_name'] ?? 'No Name',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Deadline: ${task['deadline'] ?? 'No Deadline'}',
                  style:
                      TextStyle(fontSize: 14.0, color: secondaryColorSmokeGrey),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Status: ${task['status'] ?? 'No Status'}',
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoCard() {
    return Center(
      child: Container(
        width:
            MediaQuery.of(context).size.width * 0.85, // Adjust width as needed
        child: Card(
          elevation: 4.0,
          margin: EdgeInsets.symmetric(vertical: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/img/nirvan-logo.png', // Replace with the path to your logo image
                  height: 100,
                  width: 100,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Welcome To Nirvan Institute',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: primaryColorOcenblue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nirvan Infotech',
          style: TextStyle(
            color: secondaryColorSmokewhite,
            fontFamily: 'poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20.0,
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
            icon: Icon(Icons.notifications, size: 24),
            color: secondaryColorSmokewhite,
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return LayoutBuilder(
            builder: (context, constraints) {
              double itemWidth = constraints.maxWidth * 0.9;
              if (constraints.maxWidth > 600) {
                itemWidth = constraints.maxWidth * 0.45;
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLogoCard(),
                      SizedBox(height: 16.0),
                      Text(
                        'New Tasks',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: primaryColorOcenblue),
                      ),
                      SizedBox(height: 8.0),
                      Wrap(
                        children: newTasks
                            .map((task) => _buildTaskItem(task, itemWidth))
                            .toList(),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Pending Tasks',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: primaryColorOcenblue),
                      ),
                      SizedBox(height: 8.0),
                      Wrap(
                        children: pendingTasks
                            .map((task) => _buildTaskItem(task, itemWidth))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
