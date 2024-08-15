import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirvan_infotech/colors/colors.dart';
import '../const fiels/const.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _filteredTasks = [];
  String _selectedStatus = 'All'; // Default filter for showing all tasks
  String? _empId; // Store the empId

  @override
  void initState() {
    super.initState();
    _getEmpId(); // Fetch empId on initialization
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
          _filterTasks(_selectedStatus); // Initial filtering
        });
      } else {
        print('Failed to load tasks, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  Future<void> _updateTaskStatus(int taskId, String status) async {
    if (_empId == null) {
      return; // empId is not available, do not proceed
    }

    // Map Flutter statuses to database enum values
    final statusMap = {
      'Completed': 'complete',
      'Pending': 'pending',
      'In Progress': 'in progress', // Ensure this matches the database enum
    };

    // Convert status to lowercase as expected by database
    final dbStatus = statusMap[status] ?? 'pending';

    try {
      final response = await http.post(
        Uri.parse('http://$baseIpAddress/nirvan-api/employee/fetch_task.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'update',
          'taskid': taskId,
          'status': dbStatus,
          'empid': _empId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          await _fetchTasks(); // Fetch tasks again after updating status
          print('Task status updated successfully');
        } else {
          print(
              'Failed to update task status on the server: ${data['message']}');
        }
      } else {
        print(
            'Failed to update task status, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating task status: $e');
    }
  }

  void _filterTasks(String status) {
    setState(() {
      _selectedStatus = status;

      print('Filtering tasks with status: $status'); // Debugging statement

      if (status == 'All') {
        _filteredTasks = List.from(_tasks);
      } else if (status == 'New') {
        final today = DateTime.now()
            .toLocal()
            .toString()
            .split(' ')[0]; // Get today's date
        _filteredTasks = _tasks.where((task) {
          final taskDate = task['deadline']?.split(' ')[0];
          return task['status'] == null && taskDate == today;
        }).toList();
      } else {
        String dbStatus;
        if (status == 'Completed') {
          dbStatus = 'complete';
        } else if (status == 'Pending') {
          dbStatus = 'pending';
        } else {
          dbStatus =
              status.toLowerCase(); // Default to lowercase if matches enum
        }

        _filteredTasks = _tasks.where((task) {
          final taskStatus = task['status']?.toLowerCase() ?? '';
          print('Task status: $taskStatus'); // Debugging statement
          print('Comparing with: $dbStatus'); // Debugging statement
          return taskStatus == dbStatus;
        }).toList();
      }

      print('Filtered tasks: $_filteredTasks'); // Debugging statement
    });
  }

  void _performSearch(String query) {
    setState(() {
      _filteredTasks = _tasks.where((task) {
        final taskName = task['task_name'] ?? '';
        return taskName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            height: 400, // Adjust height as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['task_name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          'Deadline: ${task['deadline'] ?? 'No Deadline'}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: secondaryColorSmokeGrey,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        if (task['task'] != null) ...[
                          Text(
                            'Details: ${task['task']}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: secondaryColorSmokeGrey,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                        ],
                        if (task['image_url'] != null) ...[
                          Image.network(
                            task['image_url'],
                            height: 150, // Adjust height as needed
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 10.0),
                        ],
                        Text(
                          'Status: ${task['status'] ?? 'No Status'}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color:
                                _getStatusColor(task['status'] ?? 'No Status'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statusButton(Icons.check_circle, Colors.green, () {
                      _updateTaskStatus(task['id'], 'Completed');
                      Navigator.of(context).pop();
                    }),
                    _statusButton(Icons.update, Colors.orange, () {
                      _updateTaskStatus(task['id'], 'Pending');
                      Navigator.of(context).pop();
                    }),
                    _statusButton(Icons.work_outline_rounded, Colors.blue, () {
                      _updateTaskStatus(task['id'], 'In Progress');
                      Navigator.of(context).pop();
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusButton(IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16.0),
        backgroundColor: color, // Set the button's background color
        foregroundColor: Colors.white, // Set the icon color
      ),
      child: Icon(icon, size: 24.0),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'complete':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  // Method to check if deadline is near
  bool _isDeadlineNear(String? deadline) {
    if (deadline == null) return false;

    final taskDate = DateTime.parse(deadline.split(' ')[0]);
    final today = DateTime.now();
    final difference = taskDate.difference(today).inDays;

    // Define the threshold for "near" deadlines (e.g., within 3 days)
    return difference <= 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(
            color: secondaryColorSmokewhite,
            fontFamily: 'poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColorOcenblue,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: secondaryColorSmokewhite,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _performSearch,
                    decoration: InputDecoration(
                      hintText: 'Search tasks',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    width: 8.0), // Adding gap between search bar and icon
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: secondaryColorBlack, width: 2.0),
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(
                                      Icons.add_task,
                                      size: 24.0,
                                      color: secondaryColorSmokeGrey,
                                    ),
                                    title: const Text('New Task'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _filterTasks('New');
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.pending_actions,
                                      size: 24.0,
                                      color: secondaryColorSmokeGrey,
                                    ),
                                    title: const Text('Pending Task'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _filterTasks('Pending');
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.task_alt,
                                      size: 24.0,
                                      color: secondaryColorSmokeGrey,
                                    ),
                                    title: const Text('Completed Task'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _filterTasks('Completed');
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.all_inbox,
                                      size: 24.0,
                                      color: secondaryColorSmokeGrey,
                                    ),
                                    title: const Text('All Tasks'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _filterTasks('All');
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.filter_list,
                        size: 24.0,
                        color: secondaryColorSmokeGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (BuildContext context, int index) {
                final task = _filteredTasks[index];
                final taskStatus = task['status']?.toLowerCase() ?? '';
                final isDeadlineNear = _isDeadlineNear(task['deadline']);

                Color statusColor;
                if (taskStatus == 'complete') {
                  statusColor = Colors.green;
                } else if (taskStatus == 'pending') {
                  statusColor = Colors.orange;
                } else if (taskStatus == 'in progress') {
                  statusColor = Colors.yellow;
                } else {
                  statusColor =
                      Colors.black; // Default color if status is unknown
                }

                return GestureDetector(
                  onTap: () {
                    _showTaskDetails(task);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isDeadlineNear ? Colors.red : Colors.transparent,
                        width: 2.0,
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
                          child: const Icon(Icons.task,
                              color: primaryColorOcenblue),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
