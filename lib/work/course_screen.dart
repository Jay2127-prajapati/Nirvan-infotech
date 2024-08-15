import 'package:flutter/material.dart';
import 'package:nirvan_infotech/colors/colors.dart';
import 'package:nirvan_infotech/work/month_detail.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({Key? key}) : super(key: key);

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  // List of months to display
  List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  // Selected year, initialized to the current year
  int _selectedYear = DateTime.now().year;
  List<int> _years = [];

  @override
  void initState() {
    super.initState();
    _initializeYears();
  }

  // Initialize list of years starting from the current year and adding next years dynamically
  void _initializeYears() {
    int currentYear = DateTime.now().year;
    _years = List.generate(
        5, (index) => currentYear + index); // Generate next 5 years
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance',
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
            child: DropdownButtonFormField<int>(
              value: _selectedYear,
              items: _years.map((int year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text('$year'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedYear = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Year',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _months.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildMonthItem(_months[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to build each month item in the list
  Widget _buildMonthItem(String month, int monthIndex) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(
          Icons.calendar_today,
          size: 36.0,
          color: primaryColorOcenblue,
        ),
        title: Text(
          month,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          // Navigate to the new screen when a month is clicked
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MonthDetailScreen(
                month: month,
                monthIndex: monthIndex,
                selectedYear: _selectedYear,
              ),
            ),
          );
        },
      ),
    );
  }
}
