import 'package:flutter/material.dart';
import 'package:nirvan_infotech/Components/loder.dart';
import 'package:nirvan_infotech/Home/home_screen.dart';
import 'package:nirvan_infotech/colors/colors.dart';

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

  bool _isLoading = false; // State variable to control the loader

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    setState(() {
      _isLoading = true; // Show loader when login process starts
      _emailBorderColor = secondaryColorSmokeGrey;
      _passwordBorderColor = secondaryColorSmokeGrey;
    });

    // Simulate async verification (replace with actual async call to your backend)
    await Future.delayed(
        const Duration(seconds: 2)); // Simulating a delay of 2 seconds

    setState(() {
      _isLoading = false; // Hide loader when verification is complete
    });

    if (email.isEmpty) {
      setState(() {
        _emailBorderColor = warningRed;
      });
      _showToastMessage("Please enter your email");
    } else if (!isValidEmail(email)) {
      setState(() {
        _emailBorderColor = warningRed;
      });
      _showToastMessage("Wrong Email");
    } else if (password.isEmpty) {
      setState(() {
        _passwordBorderColor = warningRed;
      });
      _showToastMessage("Please enter your password");
    } else if (password != "your_valid_password") {
      setState(() {
        _passwordBorderColor = warningRed;
      });
      _showToastMessage("Incorrect Password");
    } else {
      // Navigate to home screen on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  bool isValidEmail(String email) {
    // Implement your email validation logic here
    // For example, a basic email validation can be done as follows:
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
                        backgroundColor: WidgetStateProperty.all<Color>(
                            primaryColorOcenblue),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
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
          if (_isLoading) // Show loader if _isLoading is true
            Container(
              color: Colors.black
                  .withOpacity(0.5), // Semi-transparent black background
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
