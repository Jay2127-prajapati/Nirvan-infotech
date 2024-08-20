import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nirvan_infotech/colors/colors.dart';

import '../const fiels/const.dart';

class WatchAttendance extends StatefulWidget {
  const WatchAttendance({Key? key}) : super(key: key);

  @override
  State<WatchAttendance> createState() => _WatchAttendanceState();
}

class _WatchAttendanceState extends State<WatchAttendance> {
  String _selectedFilter = 'All time'; // Default filter to show all data
  List<Map<String, dynamic>> _attendanceData = [];
  Map<String, List<Map<String, dynamic>>> _groupedData =
      {}; // Grouped data by date
  List<Map<String, dynamic>> _filteredData =
      []; // Filtered data (for non-grouped views)
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showSearchFAB = false; // To control visibility of the FAB
  DateTime? _searchDate;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'http://$baseIpAddress/nirvan-api/admin/fetch_attendance.php'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success']) {
          setState(() {
            _attendanceData =
                List<Map<String, dynamic>>.from(data['attendance']);
            _filterUsers(_selectedFilter); // Apply the initial filter
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load data';
            _isLoading = false;
            _showErrorSnackBar(_errorMessage);
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server Error Found. Check your server.';
          _isLoading = false;
          _showErrorSnackBar(_errorMessage);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Try again later.';
        _isLoading = false;
        _showErrorSnackBar(_errorMessage);
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3), // Duration of the toast message
      ),
    );
  }

  void _filterUsers(String filter) {
    setState(() {
      DateTime now = DateTime.now();
      List<Map<String, dynamic>> filtered = [];

      switch (filter) {
        case 'Today':
          filtered = _attendanceData.where((user) {
            DateTime entryDate = DateTime.parse(user['date']);
            return entryDate.year == now.year &&
                entryDate.month == now.month &&
                entryDate.day == now.day;
          }).toList();
          break;
        case 'Yesterday':
          DateTime yesterday = now.subtract(const Duration(days: 1));
          filtered = _attendanceData.where((user) {
            DateTime entryDate = DateTime.parse(user['date']);
            return entryDate.year == yesterday.year &&
                entryDate.month == yesterday.month &&
                entryDate.day == yesterday.day;
          }).toList();
          break;
        case 'Last 1 week':
          DateTime oneWeekAgo = now.subtract(const Duration(days: 7));
          filtered = _attendanceData.where((user) {
            DateTime entryDate = DateTime.parse(user['date']);
            return entryDate.isAfter(oneWeekAgo);
          }).toList();
          break;
        case 'Last 1 month':
          DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
          filtered = _attendanceData.where((user) {
            DateTime entryDate = DateTime.parse(user['date']);
            return entryDate.isAfter(oneMonthAgo);
          }).toList();
          _groupDataByDate(filtered); // Group data by date
          _showSearchFAB = true; // Show FAB
          return; // Early return to avoid overwriting grouped data
        case 'All time':
          filtered = List.from(_attendanceData);
          _groupDataByDate(filtered); // Group data by date
          _showSearchFAB = true; // Show FAB
          return; // Early return to avoid overwriting grouped data
        default:
          filtered = [];
          break;
      }

      // If not grouping, just use the filtered data
      setState(() {
        _groupedData = {}; // Clear grouped data
        _filteredData = filtered;
        _showSearchFAB = false; // Hide FAB
      });
    });
  }

  void _groupDataByDate(List<Map<String, dynamic>> data) {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var user in data) {
      DateTime entryDate = DateTime.parse(user['date']);
      String formattedDate = _formatDate(entryDate);

      if (!grouped.containsKey(formattedDate)) {
        grouped[formattedDate] = [];
      }
      grouped[formattedDate]!.add(user);
    }

    setState(() {
      _groupedData = grouped;
    });
  }

  String _formatDate(DateTime date) {
    DateTime now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.subtract(const Duration(days: 1)).day) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _showSearchDialog() async {
    final TextEditingController _dateController = TextEditingController(
        text: _searchDate != null
            ? '${_searchDate!.year}-${_searchDate!.month.toString().padLeft(2, '0')}-${_searchDate!.day.toString().padLeft(2, '0')}'
            : '');

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search by Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Enter date (YYYY-MM-DD)',
                ),
                keyboardType: TextInputType.datetime,
                onChanged: (value) {
                  setState(() {
                    _searchDate = DateTime.tryParse(value);
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_searchDate != null) {
                  _searchByDate(_searchDate!);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _searchByDate(DateTime date) {
    setState(() {
      _filteredData = _attendanceData.where((user) {
        DateTime entryDate = DateTime.parse(user['date']);
        return entryDate.year == date.year &&
            entryDate.month == date.month &&
            entryDate.day == date.day;
      }).toList();
      _groupedData = {}; // Clear grouped data when searching
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance",
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
            color: Colors.white, // Set the color of the back arrow
          ),
          onPressed: () {
            Navigator.pop(context); // Pop the current route
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                            _filterUsers(_selectedFilter);
                          });
                        },
                        items: [
                          'Today',
                          'Yesterday',
                          'Last 1 week',
                          'Last 1 month',
                          'All time'
                        ]
                            .map((String filter) => DropdownMenuItem<String>(
                                  value: filter,
                                  child: Text(filter),
                                ))
                            .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Filter',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _groupedData.isNotEmpty
                            ? _groupedData.keys.length
                            : _filteredData.length,
                        itemBuilder: (context, index) {
                          String date = _groupedData.isNotEmpty
                              ? _groupedData.keys.elementAt(index)
                              : '';
                          List<Map<String, dynamic>> users =
                              _groupedData.isNotEmpty
                                  ? _groupedData[date]!
                                  : [_filteredData[index]];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_groupedData.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Text(
                                    date,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                              ...users.map((user) {
                                return GestureDetector(
                                  onTap: () => _showUserDetails(context, user),
                                  child: Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.grey,
                                            child: Text(
                                              user['empid'].toString(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Employee ID: ${user['empid']}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Date: ${user['date']}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'In Time: ${user['intime'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Out Time: ${user['outtime'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _showSearchFAB
          ? FloatingActionButton(
              onPressed: _showSearchDialog,
              child: const Icon(Icons.search),
              backgroundColor: primaryColorOcenblue,
            )
          : null,
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee ID: ${user['empid']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${user['date']}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'In Time: ${user['intime'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Out Time: ${user['outtime'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Holiday Current Month: ${user['holiday_current_month'] ?? 'N/A'}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Holiday: ${user['total_holiday'] ?? 'N/A'}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
