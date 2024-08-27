import 'package:flutter/material.dart';
import 'service/announcementservice.dart';

class MyHomePageTechnicien extends StatefulWidget {
  @override
  _MyHomePageTechnicienState createState() => _MyHomePageTechnicienState();
}

class _MyHomePageTechnicienState extends State<MyHomePageTechnicien> {
  final AnnouncementService _announcementService = AnnouncementService();

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  void _loadAnnouncements() async {
    try {
      final announcements = await _announcementService.fetchAnnouncements();
      for (var announcement in announcements) {
        if (announcement['audience'] == 'Technicians' || announcement['audience'] == 'All') {
          _showFloatingBanner(context, announcement['title'], announcement['content']);
        }
      }
    } catch (e) {
      print('Failed to load announcements: $e');
    }
  }

  void _showFloatingBanner(BuildContext context, String title, String content) {
    late OverlayEntry overlayEntry;  // Declare with `late` keyword
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
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
                  onPressed: () => overlayEntry.remove(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the technician data passed from the login page
    final technician = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String technicianName = technician?['name'] ?? 'Unknown Technician';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des Interventions'),
        backgroundColor: Colors.blueGrey,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Accueil'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Mon Agenda'),
              onTap: () {
                Navigator.pushNamed(context, '/agenda');
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Stock des pièces'),
              onTap: () {
                Navigator.pushNamed(context, '/stock');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Déconnexion', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Bienvenue, $technicianName ! Voici votre tableau de bord.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildCard(
                    context,
                    title: 'Mon Agenda',
                    subtitle: 'Voir les interventions planifiées',
                    icon: Icons.calendar_today,
                    onTap: () {
                      Navigator.pushNamed(context, '/agenda');
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'Stock des pièces',
                    subtitle: 'Vérifier les pièces disponibles',
                    icon: Icons.inventory,
                    onTap: () {
                      Navigator.pushNamed(context, '/stock');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blueGrey),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: 60, color: Colors.redAccent),
                const SizedBox(height: 20),
                Text(
                  'Are you sure?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Do you really want to logout?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
