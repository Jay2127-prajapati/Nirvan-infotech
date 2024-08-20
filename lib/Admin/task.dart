import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For encoding data

import 'package:nirvan_infotech/colors/colors.dart';

import '../const fiels/const.dart'; // For handling file paths

class Task extends StatefulWidget {
  const Task({Key? key}) : super(key: key);

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  final _taskNameController = TextEditingController();
  final _taskController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _empIdController = TextEditingController();
  final _sidController = TextEditingController();

  int _selectedRoleIndex = 0; // 0 for Employee, 1 for Student
  bool _isLoading = false; // Manage loading state

  // Function to send task data to the server
  Future<void> _sendTaskData() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Check if the form fields are valid
    final taskName = _taskNameController.text;
    final task = _taskController.text;
    final deadline = _deadlineController.text;

    if (taskName.isEmpty || task.isEmpty || deadline.isEmpty) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the required fields.'),
        ),
      );
      return;
    }

    final empId = _selectedRoleIndex == 0 ? _empIdController.text : null;
    final sid = _selectedRoleIndex == 1 ? _sidController.text : null;

    final url = Uri.parse(
        'http://$baseIpAddress/nirvan-api/admin/task.php'); // Replace with your server endpoint

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'taskname': taskName,
          'task': task,
          'empid': empId != null ? int.parse(empId) : null,
          'sid': sid != null ? int.parse(sid) : null,
          'deadline': deadline,
          'status': 'new', // Set default status to 'new'
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task assigned successfully.'),
            ),
          );
          // Clear the form fields
          _taskNameController.clear();
          _taskController.clear();
          _deadlineController.clear();
          _empIdController.clear();
          _sidController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server issue. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network issue. Please try again later.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Function to show Date and Time Picker
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final DateTime dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _deadlineController.text = dateTime.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Task",
          style: TextStyle(
            color: primaryColorWhite,
            fontFamily: 'roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColorOcenblue,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Centered Toggle Button for selecting role
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ToggleButtons(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Employee'),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Student'),
                          ),
                        ],
                        isSelected: [
                          _selectedRoleIndex == 0,
                          _selectedRoleIndex == 1
                        ],
                        onPressed: (index) {
                          setState(() {
                            _selectedRoleIndex = index;
                          });
                        },
                        color: Colors.black,
                        selectedColor: Colors.white,
                        fillColor: primaryColorOcenblue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Task Name Field
                  const Text(
                    'Task Name',
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryColorSmokeGrey,
                    ),
                  ),
                  TextField(
                    controller: _taskNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: secondaryColorSmokewhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Enter Task Name',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Task Field
                  const Text(
                    'Task Details',
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryColorSmokeGrey,
                    ),
                  ),
                  TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: secondaryColorSmokewhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Enter Task Details',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Deadline Date Field
                  const Text(
                    'Deadline Date & Time',
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryColorSmokeGrey,
                    ),
                  ),
                  TextField(
                    controller: _deadlineController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: secondaryColorSmokewhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Select Deadline Date & Time',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDateTime(context),
                  ),
                  const SizedBox(height: 16),

                  // Conditional fields based on selected role
                  if (_selectedRoleIndex == 0) ...[
                    // Employee
                    const Text(
                      'Employee ID',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryColorSmokeGrey,
                      ),
                    ),
                    TextField(
                      controller: _empIdController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: secondaryColorSmokewhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Enter Employee ID',
                      ),
                    ),
                  ] else if (_selectedRoleIndex == 1) ...[
                    // Student
                    const Text(
                      'Student ID',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryColorSmokeGrey,
                      ),
                    ),
                    TextField(
                      controller: _sidController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: secondaryColorSmokewhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Enter Student ID',
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Centered and Styled Assign Task Button
                  Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16.0), // Add horizontal padding
                      child: ElevatedButton(
                        onPressed: _sendTaskData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColorOcenblue, // Button color
                          foregroundColor: Colors.white, // Text color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 26, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Assign Task',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(primaryColorOcenblue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
