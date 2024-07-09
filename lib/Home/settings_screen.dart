import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nirvan_infotech/colors/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _imageFile; // Variable to store the selected image file
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactNoController = TextEditingController();

  String _username = ''; // Variable to store current username
  String _email = ''; // Variable to store current email
  String _contactNo = ''; // Variable to store current contact number

  @override
  void initState() {
    super.initState();
    // Initialize current data
    _usernameController.text = _username;
    _emailController.text = _email;
    _contactNoController.text = _contactNo;
  }

  // Function to open gallery and select image
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _login() {
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: secondaryColorSmokewhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/img/nirvan-logo.png',
                  width: 72,
                ),
                const SizedBox(
                  height: 24,
                ),
                const Text(
                  'Confirm changes.',
                  style: TextStyle(
                    fontFamily: 'montserrat',
                    color: secondaryColorSmokeGrey,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 32,
                        ),
                        foregroundColor: orange,
                        side: const BorderSide(color: primaryColorNaiveblue),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: const Text('No'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColorNaiveblue,
                        foregroundColor: secondaryColorSmokeGrey,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 32,
                        ),
                      ),
                      onPressed: () {
                        // Save changes logic
                        setState(() {
                          _username = _usernameController.text;
                          _email = _emailController.text;
                          _contactNo = _contactNoController.text;
                        });
                        print('Changes confirmed and saved.');
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _contactNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.photo_camera),
                              title: const Text('Take a photo'),
                              onTap: () {
                                _pickImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from gallery'),
                              onTap: () {
                                _pickImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColorOcenblue, // Border color
                          width: 2, // Border width
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : const AssetImage('assets/img/kakashi_two.jpg'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 5.5,
                      child: Container(
                        padding: const EdgeInsets.all(0),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColorOcenblue, // Border color
                            width: 1.5, // Border width
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(
                              0), // Adjust padding to remove gap
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: secondaryColorSmokewhite,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: primaryColorOcenblue, // Icon color
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Username Field
              _buildTextField('Username', Icons.person, _usernameController),

              // Email Field
              const SizedBox(height: 20),
              _buildTextField('Email', Icons.email, _emailController),

              // Contact No Field
              const SizedBox(height: 20),
              _buildTextField('Contact No', Icons.phone, _contactNoController),

              const SizedBox(height: 100), // Increased gap to 100

              // Save Changes Button
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: _login,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(primaryColorOcenblue),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Save Changes',
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
    );
  }

  Widget _buildTextField(
      String labelText, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            labelText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: secondaryColorSmokeGrey,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: secondaryColorSmokeGrey,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: primaryColorOcenblue),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter $labelText',
                    hintStyle: const TextStyle(color: secondaryColorSmokeGrey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
