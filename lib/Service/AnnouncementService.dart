import 'dart:convert';
import 'package:http/http.dart' as http;

class AnnouncementService {
  final String baseUrl = 'http://localhost:9090/api/announcements';

  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load announcements');
    }
  }

  Future<void> createAnnouncement(Map<String, dynamic> announcement) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(announcement),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create announcement');
    }
  }
}
