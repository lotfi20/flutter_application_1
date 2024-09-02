import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_application_1/Service/AnnouncementService.dart';
import 'package:flutter_application_1/technician_profile_page.dart';
import 'Service/auth_service.dart';


class SupervisorPage extends StatefulWidget {
  const SupervisorPage({super.key});

  @override
  _SupervisorPageState createState() => _SupervisorPageState();
}

class _SupervisorPageState extends State<SupervisorPage> {
  final AuthService _authService = AuthService();
  final AnnouncementService _announcementService = AnnouncementService();
  
  String? _supervisorName;
  String? _supervisorEmail;
  String? _supervisorPhone;
  late Future<List<dynamic>> _futureTechnicians;
  late Future<List<dynamic>> _futureInterventions;
  late Future<List<Map<String, dynamic>>> _futureAnnouncements;

  TextEditingController _searchController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  List<dynamic> _allTechnicians = [];
  List<dynamic> _filteredTechnicians = [];
  Map<String, int> _interventionCounts = {'Pending': 0, 'In Progress': 0, 'Completed': 0};
  bool _isLoadingInterventions = true;

  @override
  void initState() {
    super.initState();
    _fetchSupervisorInfo();
    _futureTechnicians = _fetchTechnicians();
    _futureInterventions = _fetchInterventions();
    _futureAnnouncements = _announcementService.fetchAnnouncements();
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

  Future<List<dynamic>> _fetchInterventions() async {
    try {
      final interventions = await _authService.getInterventions();
      setState(() {
        _interventionCounts = {
          'Pending': interventions.where((intervention) => intervention['status'] == 'Pending').length,
          'In Progress': interventions.where((intervention) => intervention['status'] == 'In Progress').length,
          'Completed': interventions.where((intervention) => intervention['status'] == 'Completed').length,
        };
        _isLoadingInterventions = false;
      });
      return interventions;
    } catch (e) {
      print('Failed to load interventions: $e');
      setState(() {
        _isLoadingInterventions = false;
      });
      return [];
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

  void _createAnnouncement() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Title and Content cannot be empty'),
      ));
      return;
    }

    try {
      await _announcementService.createAnnouncement({
        'title': _titleController.text,
        'content': _contentController.text,
        'audience': 'Technicians', // or 'Clients', depending on the audience
      });
      setState(() {
        _futureAnnouncements = _announcementService.fetchAnnouncements();
      });
      _titleController.clear();
      _contentController.clear();
    } catch (e) {
      print('Error creating announcement: $e');
    }
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
              Navigator.pushReplacementNamed(context, '/notifications');
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
              _buildAnnouncements(), // Announcements section
              const SizedBox(height: 16),
              _buildCreateAnnouncementForm(), // Form to create announcements
              const SizedBox(height: 16),
              _buildInterventionOverview(), // Dynamic Intervention Overview
              const SizedBox(height: 16),
              _buildTechnicianList(),
              const SizedBox(height: 16),
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

  Widget _buildAnnouncements() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Announcements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureAnnouncements,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No announcements available'));
                } else {
                  final announcements = snapshot.data!;
                  return Column(
                    children: announcements.map((announcement) {
                      return ListTile(
                        title: Text(announcement['title']),
                        subtitle: Text(announcement['content']),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateAnnouncementForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create New Announcement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _createAnnouncement,
              child: Text('Create Announcement'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Intervention Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingInterventions
                ? Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInterventionCard('Pending', _interventionCounts['Pending'] ?? 0, Colors.orangeAccent),
                      _buildInterventionCard('In Progress', _interventionCounts['In Progress'] ?? 0, Colors.blueAccent),
                      _buildInterventionCard('Completed', _interventionCounts['Completed'] ?? 0, Colors.greenAccent),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionCard(String status, int count, Color color) {
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

  void _showNotifications() {
    Navigator.pushReplacementNamed(context, '/notifications');
  }
}

class SideBar extends StatefulWidget {
  final String? supervisorName;

  SideBar({this.supervisorName});

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final AnnouncementService _announcementService = AnnouncementService();
  late Future<List<Map<String, dynamic>>> _futureAnnouncements;

  @override
  void initState() {
    super.initState();
    _futureAnnouncements = _announcementService.fetchAnnouncements();
  }

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
            onTap: () {
              Navigator.pushReplacementNamed(context, '/supervisor');
            },
          ),
          ListTile(
            leading: Icon(Icons.production_quantity_limits),
            title: Text('Stock'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/stocksuperviseur');
            },
          ),
          ListTile(
            leading: Icon(Icons.inbox),
            title: Text('Inbox'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/inbox');
            },
          ),
          ExpansionTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureAnnouncements,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No announcements available'));
                  } else {
                    final announcements = snapshot.data!;
                    return Column(
                      children: announcements.map((announcement) {
                        return ListTile(
                          title: Text(announcement['title']),
                          subtitle: Text(announcement['content']),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
          Spacer(),
          ListTile(
            leading: CircleAvatar(),
            title: Text(widget.supervisorName ?? 'Supervisor'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }
}



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
            onTap: () {
              Navigator.pushReplacementNamed(context, '/supervisor');
            },
          ),
          ListTile(
            leading: Icon(Icons.production_quantity_limits),
            title: Text('Stock'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/stocksuperviseur');
            },
          ),
          ListTile(
            leading: Icon(Icons.inbox),
            title: Text('Inbox'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/inbox');
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/notifications');
            },
          ),
          Spacer(),
       
        ],
      ),
    );
  }

