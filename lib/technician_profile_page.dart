import 'package:flutter/material.dart';
import 'Service/auth_service.dart';

class TechnicianProfilePage extends StatefulWidget {
  final Map<String, dynamic> technician;

  TechnicianProfilePage({required this.technician});

  @override
  _TechnicianProfilePageState createState() => _TechnicianProfilePageState();
}

class _TechnicianProfilePageState extends State<TechnicianProfilePage> {
  final AuthService _authService = AuthService();
  late Future<List<dynamic>> _futureInterventions;
  late Future<List<dynamic>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureInterventions = _fetchTechnicianInterventions();
    _futureUsers = _fetchUsers();
  }

  Future<List<dynamic>> _fetchTechnicianInterventions() async {
    try {
      return await _authService.getInterventionsForTechnician(widget.technician['id']);
    } catch (e) {
      print('Failed to fetch interventions: $e');
      return [];
    }
  }

  Future<List<dynamic>> _fetchUsers() async {
    try {
      return await _authService.getUsersForTechnician(widget.technician['id']);
    } catch (e) {
      print('Failed to fetch users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.technician['name']} Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTechnicianDetails(),
            const SizedBox(height: 16),
            _buildInterventionsSection(),
            const SizedBox(height: 16),
            _buildUsersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.technician['name']}', style: TextStyle(fontSize: 18)),
            Text('Email: ${widget.technician['email']}', style: TextStyle(fontSize: 18)),
            Text('Phone: ${widget.technician['phone']}', style: TextStyle(fontSize: 18)),
            Text('Status: ${widget.technician['status']}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionsSection() {
    return FutureBuilder<List<dynamic>>(
      future: _futureInterventions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No interventions available'));
        } else {
          final interventions = snapshot.data!;
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Interventions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ...interventions.map<Widget>((intervention) {
                  return ListTile(
                    title: Text(intervention['description']),
                    subtitle: Text('Status: ${intervention['status']}'),
                  );
                }).toList(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildUsersSection() {
    return FutureBuilder<List<dynamic>>(
      future: _futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No users available'));
        } else {
          final users = snapshot.data!;
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Users', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ...users.map<Widget>((user) {
                  return ListTile(
                    title: Text(user['name']),
                    subtitle: Text('Email: ${user['email']}'),
                  );
                }).toList(),
              ],
            ),
          );
        }
      },
    );
  }
}
