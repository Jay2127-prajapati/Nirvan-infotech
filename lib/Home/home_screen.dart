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
      _empId =
          prefs.getString('empId'); // Retrieve empId from SharedPreferences
    });
    _fetchTasks(); // Fetch tasks after empId is retrieved
  }

  Future<void> _fetchTasks() async {
    if (_empId == null) {
      return; // empId is not available, do not proceed
    }

    try {
      final response = await http.post(
        Uri.parse('http://$baseIpAddress/nirvan-api/employee/fetch_task.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'fetch', 'empid': _empId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _tasks = List<Map<String, dynamic>>.from(data['tasks']);
          _filterTasks(); // Filter tasks based on their status
        });
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
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
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
            child: const Icon(Icons.task, color: primaryColorOcenblue),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['task_name'] ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Deadline: ${task['deadline'] ?? 'No Deadline'}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: secondaryColorSmokeGrey,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Status: ${task['status'] ?? 'No Status'}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
      body: LayoutBuilder(
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
                  const SizedBox(height: 16.0),
                  const Text(
                    'New Tasks',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: primaryColorOcenblue,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    children: newTasks
                        .map((task) => _buildTaskItem(task, itemWidth))
                        .toList(),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Pending Tasks',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: primaryColorOcenblue,
                    ),
                  ),
                  const SizedBox(height: 8.0),
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
      ),
    );
  }
}
