import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_application_1/technician_profile_page.dart';
import 'Service/auth_service.dart';

class SupervisorPage extends StatefulWidget {
  const SupervisorPage({super.key});

  @override
  _SupervisorPageState createState() => _SupervisorPageState();
}

class _SupervisorPageState extends State<SupervisorPage> {
  final AuthService _authService = AuthService();
  String? _supervisorName;
  String? _supervisorEmail;
  String? _supervisorPhone;
  late Future<List<dynamic>> _futureTechnicians;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _allTechnicians = [];
  List<dynamic> _filteredTechnicians = [];
  
  Map<String, int> _taskCounts = {'Pending': 0, 'In Progress': 0, 'Completed': 0};
  bool _isLoadingTasks = true;

  @override
  void initState() {
    super.initState();
    _fetchSupervisorInfo();
    _futureTechnicians = _fetchTechnicians();
    _fetchTaskStatusCounts(); // Fetch task status counts
  }

  Future<void> _fetchSupervisorInfo() async {
    try {
      final supervisor = await _authService.getCurrentSupervisor();
      setState(() {
        _supervisorName = supervisor['name'];
        _supervisorEmail = supervisor['email'];
        _supervisorPhone = supervisor['phone'];
      });
    } catch (e) {
      print('Failed to load supervisor: $e');
      setState(() {
        _supervisorName = 'Error loading supervisor';
        _supervisorEmail = '';
        _supervisorPhone = '';
      });
    }
  }

  Future<List<dynamic>> _fetchTechnicians() async {
    try {
      final technicians = await _authService.getTechnicians();
      setState(() {
        _allTechnicians = technicians;
        _filteredTechnicians = technicians;
      });
      return technicians;
    } catch (e) {
      print('Failed to fetch technicians: $e');
      return [];
    }
  }

  Future<void> _fetchTaskStatusCounts() async {
    try {
      final taskCounts = await _authService.getTaskStatusCounts();
      setState(() {
        _taskCounts = taskCounts;
        _isLoadingTasks = false;
      });
    } catch (e) {
      print('Failed to load task status counts: $e');
      setState(() {
        _isLoadingTasks = false;
      });
    }
  }

  void _filterTechnicians(String query) {
    final filtered = _allTechnicians.where((technician) {
      final nameLower = technician['name'].toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredTechnicians = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supervisor Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _showNotifications();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      drawer: SideBar(supervisorName: _supervisorName),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${_supervisorName ?? 'Loading...'}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildAnnouncements(),
              const SizedBox(height: 16),
              _buildTaskOverview(), // Dynamic Task Overview
              const SizedBox(height: 16),
              _buildTechnicianList(),
              const SizedBox(height: 16),
              _buildFeedbackSection(),
              const SizedBox(height: 16),
              _buildRecentActivityLog(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: 'Search Technicians...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: _filterTechnicians,
    );
  }

  Widget _buildTaskOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingTasks
                ? Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTaskCard('Pending', _taskCounts['Pending'] ?? 0, Colors.orangeAccent),
                      _buildTaskCard('In Progress', _taskCounts['In Progress'] ?? 0, Colors.blueAccent),
                      _buildTaskCard('Completed', _taskCounts['Completed'] ?? 0, Colors.greenAccent),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(String status, int count, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                status,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncements() {
    return OpenContainer(
      closedElevation: 0,
      openElevation: 4,
      transitionType: ContainerTransitionType.fadeThrough,
      closedBuilder: (context, openContainer) => ListTile(
        onTap: openContainer,
        leading: Icon(Icons.announcement, size: 40),
        title: Text('Announcements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text('View recent announcements'),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
      openBuilder: (context, closeContainer) => Scaffold(
        appBar: AppBar(
          title: Text('Announcements'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.announcement),
                title: Text('No new announcements.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicianList() {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.people, size: 40),
            title: Text('Technicians', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Text('View and manage technicians'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<dynamic>>(
              future: _futureTechnicians,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (_filteredTechnicians.isEmpty) {
                  return Center(child: Text('No technicians available'));
                } else {
                  return Column(
                    children: _filteredTechnicians.map<Widget>((technician) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(technician['name']),
                        subtitle: Text('Status: ${technician['status']}'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TechnicianProfilePage(technician: technician),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feedback',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: Icon(Icons.thumb_up, color: Colors.greenAccent),
                  title: Text('Great work by Mohamed Ben Ali!'),
                ),
                ListTile(
                  leading: Icon(Icons.thumb_down, color: Colors.redAccent),
                  title: Text('Youssef Saadi needs improvement.'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityLog() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.greenAccent),
                  title: Text('Mohamed Ben Ali completed a task.'),
                  subtitle: Text('2 hours ago'),
                ),
                ListTile(
                  leading: Icon(Icons.error, color: Colors.redAccent),
                  title: Text('Youssef Saadi reported an issue.'),
                  subtitle: Text('5 hours ago'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Notifications'),
          content: Text('No new notifications.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class SideBar extends StatelessWidget {
  final String? supervisorName;

  SideBar({this.supervisorName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.production_quantity_limits),
            title: Text('Products'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Statistics'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.inbox),
            title: Text('Inbox'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () {},
          ),
          Spacer(),
          ListTile(
            leading: CircleAvatar(),
            title: Text(supervisorName ?? 'Supervisor'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
