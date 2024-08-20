import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:nirvan_infotech/colors/colors.dart';

import '../const fiels/const.dart';

class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final ImagePicker _picker = ImagePicker();
  File? _image; // Initialize with null

  String _selectedRole = 'employee'; // Default selection
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  DateTime? _joiningDateTime; // Holds selected date and time
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _selectDateAndTime(BuildContext context) async {
    final initialDate = _joiningDateTime ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        setState(() {
          _joiningDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveUser() async {
    String apiUrl = 'http://$baseIpAddress/nirvan-api/admin/admin_add_user.php';

    // Validate required fields
    if (_nameController.text.isEmpty) {
      _showWarning('Name');
      return;
    }
    if (_contactController.text.isEmpty) {
      _showWarning('Contact');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showWarning('Email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showWarning('Password');
      return;
    }

    if (_selectedRole == 'employee') {
      if (_domainController.text.isEmpty) {
        _showWarning('Domain');
        return;
      }
      if (_experienceController.text.isEmpty) {
        _showWarning('Experience');
        return;
      }
    }

    String? base64Image;
    if (_image != null) {
      List<int> imageBytes = await _image!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    var body = {
      'role': _selectedRole,
      'id': _idController.text,
      'name': _nameController.text,
      'contact': _contactController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'joining_datetime': _joiningDateTime?.toIso8601String() ?? '',
      'photo': base64Image ?? '',
    };

    if (_selectedRole == 'employee') {
      body.addAll({
        'domain': _domainController.text,
        'experience': _experienceController.text,
        'empid': _idController
            .text, // Ensure this matches your form field for employee ID
      });
    }

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        _showSuccess('User added successfully');
      } else {
        var responseBody = jsonDecode(response.body);
        _showWarning(responseBody['error'] ?? 'Failed to add user');
      }
    } catch (e) {
      _showWarning('Error adding user: $e');
    }
  }

  void _showWarning(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllFields(); // Clear fields after successful addition
              },
            ),
          ],
        );
      },
    );
  }

  void _clearAllFields() {
    setState(() {
      _idController.clear();
      _nameController.clear();
      _contactController.clear();
      _domainController.clear();
      _experienceController.clear();
      _joiningDateTime = null;
      _emailController.clear();
      _passwordController.clear();
      _image = null;
    });
  }

  void _handleRoleChange(String? value) {
    setState(() {
      _selectedRole = value!;
      _clearAllFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add User",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColorOcenblue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04), // Adjust padding
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // Adjust padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  onChanged: _handleRoleChange,
                  items: <String>['employee', 'student']
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                              value == 'employee' ? 'Employee' : 'Student'),
                        ),
                      )
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Adjust spacing
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'ID',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.perm_identity),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Adjust spacing
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Adjust spacing
                TextField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: 'Contact',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Adjust spacing
                if (_selectedRole == 'employee') ...[
                  TextField(
                    controller: _domainController,
                    decoration: InputDecoration(
                      labelText: 'Domain',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.work),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // Adjust spacing
                  TextField(
                    controller: _experienceController,
                    decoration: InputDecoration(
                      labelText: 'Experience',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // Adjust spacing
                  InkWell(
                    onTap: () => _selectDateAndTime(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Joining Date & Time',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _joiningDateTime != null
                            ? '${_joiningDateTime!.day}/${_joiningDateTime!.month}/${_joiningDateTime!.year} ${_joiningDateTime!.hour}:${_joiningDateTime!.minute}'
                            : 'Select Date & Time',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
                if (_selectedRole == 'student') ...[
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Student Specific Field 1',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.book),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // Adjust spacing
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Student Specific Field 2',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // Adjust spacing
                  InkWell(
                    onTap: () => _selectDateAndTime(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Student Joining Date & Time',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _joiningDateTime != null
                            ? '${_joiningDateTime!.day}/${_joiningDateTime!.month}/${_joiningDateTime!.year} ${_joiningDateTime!.hour}:${_joiningDateTime!.minute}'
                            : 'Select Date & Time',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: screenHeight * 0.02), // Adjust spacing
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Adjust spacing
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Adjust spacing
                ElevatedButton(
                  onPressed: _getImageFromGallery,
                  child: Text(_image == null ? 'Select Image' : 'Change Image'),
                ),
                SizedBox(height: screenHeight * 0.02), // Adjust spacing
                if (_image != null) ...[
                  Center(
                    child: Image.file(
                      _image!,
                      height: 200,
                    ),
                  ),
                ],
                SizedBox(height: screenHeight * 0.02), // Adjust spacing
                ElevatedButton(
                  onPressed: _saveUser,
                  child: Text('Save User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
