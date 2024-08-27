import 'package:flutter/material.dart';
import 'package:flutter_application_1/Service/AnnouncementService.dart';

class AnnouncementPage extends StatefulWidget {
  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final AnnouncementService _announcementService = AnnouncementService();
  late Future<List<Map<String, dynamic>>> _futureAnnouncements;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _audience = 'technicians';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    setState(() {
      _futureAnnouncements = _announcementService.fetchAnnouncements();
    });
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _audience = 'technicians';
    });
  }

  void _addAnnouncement() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
              DropdownButtonFormField<String>(
                value: _audience,
                onChanged: (value) {
                  setState(() {
                    _audience = value ?? 'technicians';
                  });
                },
                items: [
                  DropdownMenuItem(value: 'technicians', child: Text('Technicians')),
                  DropdownMenuItem(value: 'clients', child: Text('Clients')),
                  DropdownMenuItem(value: 'both', child: Text('Both')),
                ],
                decoration: InputDecoration(labelText: 'Audience'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields.')),
                  );
                  return;
                }

                final announcement = {
                  'title': _titleController.text,
                  'content': _contentController.text,
                  'audience': _audience,
                  'createdAt': DateTime.now().toIso8601String(),
                };
                try {
                  await _announcementService.createAnnouncement(announcement);
                  Navigator.of(context).pop();
                  _clearForm();
                  _loadAnnouncements();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating announcement: $e')),
                  );
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addAnnouncement,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
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
              return ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return Dismissible(
                    key: Key(announcement['title']),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${announcement['title']} dismissed')),
                      );
                    },
                    background: Container(color: Colors.red),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(announcement['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(announcement['content']),
                            SizedBox(height: 8),
                            Text('Audience: ${announcement['audience']}',
                                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
