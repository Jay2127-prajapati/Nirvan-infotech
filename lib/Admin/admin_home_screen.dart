import 'package:flutter/material.dart';
import 'package:nirvan_infotech/colors/colors.dart';

// Fake data for demonstration
List<Map<String, dynamic>> fakeUserData = [
  {
    'id': 1,
    'name': 'John Doe',
    'dpUrl': 'https://via.placeholder.com/150',
    'todayEntry': true,
    'entryTime': '10:00 AM',
    'exitTime': '05:00 PM',
    'completedTasks': 5,
    'pendingTasks': 2,
  },
  {
    'id': 2,
    'name': 'Jane Smith',
    'dpUrl': 'https://via.placeholder.com/150',
    'todayEntry': false,
  },
  {
    'id': 3,
    'name': 'Michael Johnson',
    'dpUrl': 'https://via.placeholder.com/150',
    'todayEntry': true,
    'entryTime': '09:30 AM',
  },
];

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String _selectedFilter = 'Today'; // Default filter
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filterUsers(_selectedFilter);
  }

  void _filterUsers(String filter) {
    setState(() {
      switch (filter) {
        case 'Today':
          _filteredUsers =
              fakeUserData.where((user) => user['todayEntry'] == true).toList();
          break;
        case 'Yesterday':
          // Logic to filter data for Yesterday
          // Not implemented in this demo
          break;
        case 'Last 1 week':
          // Logic to filter data for Last 1 week
          // Not implemented in this demo
          break;
        case 'Last 1 month':
          // Logic to filter data for Last 1 month
          // Not implemented in this demo
          break;
        default:
          _filteredUsers = [];
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: TextStyle(
            color: primaryColorWhite,
            fontFamily: 'roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColorOcenblue,
      ),
      body: Column(
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
              items: ['Today', 'Yesterday', 'Last 1 week', 'Last 1 month']
                  .map((String filter) => DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Filter',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return GestureDetector(
                  onTap: () => _showUserDetails(context, user),
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _showUserPopup(context, user),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(user['dpUrl']),
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (user['todayEntry'] != null)
                                Text(
                                  user['todayEntry']
                                      ? 'Entered at ${user['entryTime']}'
                                      : 'Did not enter today',
                                  style: TextStyle(
                                    color: user['todayEntry']
                                        ? Colors.green
                                        : Colors.black,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
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
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  user['todayEntry']
                      ? 'Entry Time: ${user['entryTime']}'
                      : 'Did not enter today',
                  style: TextStyle(
                    color: user['todayEntry'] ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                if (user['todayEntry'])
                  Text(
                    'Exit Time: ${user['exitTime']}',
                    style: TextStyle(color: Colors.blue),
                  ),
                SizedBox(height: 8),
                Text(
                  'Completed Tasks: ${user['completedTasks']}',
                ),
                SizedBox(height: 8),
                Text(
                  'Pending Tasks: ${user['pendingTasks']}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUserPopup(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user['dpUrl']),
                ),
                SizedBox(height: 16),
                Text(
                  user['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  user['todayEntry']
                      ? 'Entry Time: ${user['entryTime']}'
                      : 'Did not enter today',
                  style: TextStyle(
                    color: user['todayEntry'] ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                if (user['todayEntry'])
                  Text(
                    'Exit Time: ${user['exitTime']}',
                    style: TextStyle(color: Colors.blue),
                  ),
                SizedBox(height: 8),
                Text(
                  'Completed Tasks: ${user['completedTasks']}',
                ),
                SizedBox(height: 8),
                Text(
                  'Pending Tasks: ${user['pendingTasks']}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
