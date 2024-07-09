import 'package:flutter/material.dart';
import 'package:nirvan_infotech/colors/colors.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

enum TaskStatus {
  New,
  Completed,
  Current,
}

class _TaskScreenState extends State<TaskScreen> {
  TextEditingController _searchController = TextEditingController();
  TaskStatus _selectedStatus = TaskStatus.Current; // Default filter: Current

  List<Map<String, dynamic>> _tasks = [
    {
      'name': 'Task 1',
      'status': TaskStatus.New,
      'deadline': '2024-07-05',
      'logo': Icons.work,
    },
    {
      'name': 'Task 2',
      'status': TaskStatus.Completed,
      'deadline': '2024-07-10',
      'logo': Icons.work,
    },
    {
      'name': 'Task 3',
      'status': TaskStatus.Current,
      'deadline': '2024-07-15',
      'logo': Icons.work,
    },
    {
      'name': 'Task 4',
      'status': TaskStatus.New,
      'deadline': '2024-07-20',
      'logo': Icons.work,
    },
    {
      'name': 'Task 5',
      'status': TaskStatus.Completed,
      'deadline': '2024-07-25',
      'logo': Icons.work,
    },
  ];

  List<Map<String, dynamic>> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _filterTasks(_selectedStatus); // Initial filtering
  }

  void _filterTasks(TaskStatus status) {
    setState(() {
      _selectedStatus = status;
      _filteredTasks =
          _tasks.where((task) => task['status'] == status).toList();
    });
  }

  void _performSearch(String query) {
    setState(() {
      _filteredTasks = _tasks
          .where((task) =>
              task['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
                                      color:
                                          secondaryColorSmokeGrey, // Set color here
                                    ),
                                    title: const Text(
                                      'New Task',
                                      style: TextStyle(fontFamily: 'roboto'),
                                    ),
                                    onTap: () {
                                      _filterTasks(TaskStatus.New);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.task_alt,
                                      size: 24.0,
                                      color:
                                          secondaryColorSmokeGrey, // Set color here
                                    ),
                                    title: const Text(
                                      'Completed Task',
                                      style: TextStyle(fontFamily: 'roboto'),
                                    ),
                                    onTap: () {
                                      _filterTasks(TaskStatus.Completed);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.task_sharp,
                                      size: 24.0,
                                      color:
                                          secondaryColorSmokeGrey, // Set color here
                                    ),
                                    title: const Text(
                                      'Current Task',
                                      style: TextStyle(fontFamily: 'roboto'),
                                    ),
                                    onTap: () {
                                      _filterTasks(TaskStatus.Current);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.filter_alt),
                      color: secondaryColorBlack,
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
                return _buildTaskItem(_filteredTasks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: secondaryColorSmokewhite,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            task['logo'],
            size: 36.0,
            color: primaryColorOcenblue,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['name'],
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Deadline: ${task['deadline']}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: secondaryColorSmokeGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _getStatusText(task['status']),
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(task['status']),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.New:
        return 'New';
      case TaskStatus.Completed:
        return 'Completed';
      case TaskStatus.Current:
        return 'Current';
      default:
        return '';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.New:
        return orange;
      case TaskStatus.Completed:
        return Green;
      case TaskStatus.Current:
        return primaryColorNaiveblue;
      default:
        return secondaryColorBlack;
    }
  }
}
