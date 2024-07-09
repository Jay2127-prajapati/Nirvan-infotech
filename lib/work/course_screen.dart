import 'package:flutter/material.dart';
import 'package:nirvan_infotech/colors/colors.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({Key? key}) : super(key: key);

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _modules = [
    {
      'name': 'Module 1',
      'logo': Icons.book,
      'tasks': [
        {'name': 'Task 1', 'deadline': '2024-07-05', 'status': 'New'},
        {'name': 'Task 2', 'deadline': '2024-07-10', 'status': 'Completed'},
        {'name': 'Task 3', 'deadline': '2024-07-15', 'status': 'Current'},
      ],
    },
    {
      'name': 'Module 2',
      'logo': Icons.book,
      'tasks': [
        {'name': 'Task 4', 'deadline': '2024-07-20', 'status': 'New'},
        {'name': 'Task 5', 'deadline': '2024-07-25', 'status': 'Completed'},
      ],
    },
  ];

  List<Map<String, dynamic>> _filteredModules = [];

  @override
  void initState() {
    super.initState();
    _filteredModules = List.from(_modules); // Initially show all modules
  }

  void _performSearch(String query) {
    setState(() {
      _filteredModules = _modules
          .where((module) =>
              module['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modules',
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
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search modules',
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
          Expanded(
            child: ListView.builder(
              itemCount: _filteredModules.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildModuleItem(_filteredModules[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleItem(Map<String, dynamic> module) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(
          module['logo'],
          size: 36.0,
          color: primaryColorOcenblue,
        ),
        title: Text(
          module['name'],
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
