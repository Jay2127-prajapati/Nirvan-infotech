import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nirvan_infotech/Components/loder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirvan_infotech/Components/bottom_nav.dart';
import 'package:nirvan_infotech/colors/colors.dart';
import '../const fiels/const.dart';

const String adminRole = 'admin';
const String studentRole = 'student';
const String employeeRole = 'employee';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Color _emailBorderColor = secondaryColorSmokeGrey;
  Color _passwordBorderColor = secondaryColorSmokeGrey;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? roles = prefs.getStringList('roles');
    String? currentRole = prefs.getString('currentRole');

    if (roles != null && currentRole != null && roles.contains(currentRole)) {
      _navigateToRoleScreen(currentRole);
    }
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (!isValidEmail(email)) {
      setState(() {
        _emailBorderColor = warningRed; // Indicate error
      });
      _showToastMessage('Invalid email format');
      return;
    }

    setState(() {
      _isLoading = true;
      _emailBorderColor = secondaryColorSmokeGrey;
      _passwordBorderColor = secondaryColorSmokeGrey;
    });

    await loginVerification(email, password);

    setState(() {
      _isLoading = false;
    });
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showToastMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> loginVerification(String email, String password) async {
    final url =
        Uri.parse('http://$baseIpAddress/nirvan-api/employee/emp_login.php');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response data: $responseData'); // Debug print

        if (responseData['success'] == true) {
          String role = responseData['role'] ?? '';

          // Determine the ID based on the role
          String? userId;
          switch (role) {
            case adminRole:
              userId = responseData['adminId'].toString(); // Convert to string
              break;
            case studentRole:
              userId = responseData['stuId'].toString(); // Convert to string
              break;
            case employeeRole:
              userId = responseData['empId'].toString(); // Convert to string
              break;
            default:
              _showToastMessage('Unknown role');
              return;
          }

          if (userId == null || userId.isEmpty) {
            _showToastMessage('User ID is missing');
            return;
          }

          final prefs = await SharedPreferences.getInstance();

          // Get the list of roles and add the new role if not present
          List<String>? roles = prefs.getStringList('roles') ?? [];
          if (!roles.contains(role)) {
            roles.add(role);
            await prefs.setStringList('roles', roles);
          }

          // Store the userId based on role
          await prefs.setString('${role}Id', userId);
          print(
              'Stored ${role}Id: ${prefs.getString('${role}Id')}'); // Debug print

          // Set current role
          await prefs.setString('currentRole', role);

          print('User logged in successfully. userId: $userId');

          _navigateToRoleScreen(role);
        } else {
          _showToastMessage(responseData['message'] ?? 'Login failed');
        }
      } else {
        _showToastMessage("Server error. Please try again later.");
      }
    } catch (error) {
      print('Error: $error');
      _showToastMessage("Network error. Please try again later.");
    }
  }

  void _navigateToRoleScreen(String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CustomBottomNavigationBar(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.001),
                  Container(
                    child: Image.asset(
                      'assets/img/nirvan-logo.png',
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Text(
                    'Welcome To',
                    style: TextStyle(
                      color: secondaryColorSmokeGrey,
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'roboto',
                    ),
                  ),
                  Text(
                    'NIRVAN',
                    style: TextStyle(
                      color: secondaryColorSmokeGrey,
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'roboto',
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.86,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(color: _emailBorderColor, width: 2.0),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 15.0,
                          backgroundImage: AssetImage('assets/img/user.png'),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                color: secondaryColorSmokeGrey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.86,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      border:
                          Border.all(color: _passwordBorderColor, width: 2.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                color: secondaryColorSmokeGrey,
                              ),
                            ),
                            obscureText: _obscurePassword,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: secondaryColorSmokeGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.86,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            primaryColorOcenblue),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: WaveLoader(
                  color: primaryColorOcenblue,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
