import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'service/technician_service.dart';
import 'service/announcementservice.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TechnicianService _technicianService = TechnicianService();
  final AnnouncementService _announcementService = AnnouncementService();
  List<dynamic> _technicians = [];
  late IO.Socket socket;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _setupSocketConnection();
    _fetchTechnicians();
    _loadUserName();
    _loadAnnouncements();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  void _setupSocketConnection() {
    socket = IO.io('http://localhost:9090', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('connect', (_) {
      print('Connected to the server');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from the server');
    });
  }

  void _fetchTechnicians() async {
    try {
      final technicians = await _technicianService.fetchTechnicians();
      setState(() {
        _technicians = technicians;
      });
    } catch (e) {
      print('Failed to load technicians: $e');
    }
  }

 void _loadAnnouncements() async {
  try {
    final announcements = await _announcementService.fetchAnnouncements();
    print('Fetched Announcements: $announcements');
    for (var announcement in announcements) {
      print('Announcement Audience: ${announcement['audience']}');
      if (announcement['audience'] == 'Clients' || announcement['audience'] == 'All') {
        print('Showing Announcement: ${announcement['title']}');
        _showFloatingBanner(context, announcement['title'], announcement['content']);
      }
    }
  } catch (e) {
    print('Failed to load announcements: $e');
  }
}




  void _showFloatingBanner(BuildContext context, String title, String content) {
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      print('Displaying Banner: $title');
      return Positioned(
        top: 50.0,
        left: MediaQuery.of(context).size.width * 0.05,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10.0,
                  spreadRadius: 5.0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        content,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    print('Closing Banner: $title');
                    overlayEntry.remove();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  Overlay.of(context).insert(overlayEntry);
}


  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $_userName!'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome to the app! Here are your available technicians:',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _technicians.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemBuilder: (context, index) {
                  final technician = _technicians[index];
                  return _buildCard(
                    context,
                    title: technician['name'] ?? 'No Name',
                    subtitle: technician['status'] ?? 'No Status',
                    icon: Icons.engineering,
                    onTap: technician['status'] == 'Available'
                        ? () => _showBookingDialog(technician['_id'])
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Technician not available')),
                            );
                          },
                    isAvailable: technician['status'] == 'Available',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Do you really want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showBookingDialog(String technicianId) {
    final TextEditingController descriptionController = TextEditingController();
    String _problemType = 'Other';
    String _replacementOption = 'No';
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Book Intervention',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.black54),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _problemType,
                      onChanged: (value) => setState(() => _problemType = value!),
                      items: const [
                        DropdownMenuItem(value: 'Broken', child: Text('Broken')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Problem Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _replacementOption,
                      onChanged: (value) => setState(() => _replacementOption = value!),
                      items: const [
                        DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                        DropdownMenuItem(value: 'No', child: Text('No')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Replacement Needed?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            startDate = picked;
                            endDate = picked.add(Duration(hours: 1));
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 10),
                          Text(
                            startDate != null
                                ? 'Selected Date: ${startDate!.toLocal()}'.split(' ')[0]
                                : 'Select Date',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        ),
                        onPressed: () {
                          if (startDate != null && descriptionController.text.isNotEmpty) {
                            _showConfirmationDialog(
                              technicianId,
                              descriptionController.text,
                              _problemType,
                              _replacementOption,
                              startDate!,
                              endDate!,
                            );
                          }
                        },
                        child: Text('Book'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog(
    String technicianId,
    String description,
    String problemType,
    String replacementOption,
    DateTime startDate,
    DateTime endDate,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Booking'),
          content: const Text('Are you sure you want to book this intervention?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _technicianService.createIntervention(
                    '66a1af29f8b32c7a347ca0f2', // Replace with actual client ID
                    technicianId,
                    description,
                    problemType,
                    replacementOption,
                    startDate,
                    endDate,
                  );
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Intervention booked successfully')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to book intervention')));
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title, required String subtitle, required IconData icon, required VoidCallback onTap, required bool isAvailable}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: isAvailable ? Colors.greenAccent : Colors.redAccent,
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
