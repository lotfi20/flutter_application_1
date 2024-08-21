import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  final String baseUrl = 'http://localhost:9090/api';

  Future<Map<String, dynamic>> loginTechnician(String email, String phone) async {
    final url = Uri.parse('$baseUrl/technicians/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<dynamic>> getInterventionsForTechnician(String technicianId) async {
  try {
    final response = await http.get(Uri.parse('your-api-url/interventions/$technicianId'));

    if (response.statusCode == 200) {
      print('API response: ${response.body}'); // Log the response to see the data
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((intervention) {
        return {
          'id': intervention['id'] ?? '',
          'description': intervention['description'] ?? 'No description',
          'status': intervention['status'] ?? 'Unknown',
          // Add other fields with similar null checks
        };
      }).toList();
    } else {
      throw Exception('Failed to load interventions');
    }
  } catch (e) {
    print('Error fetching interventions: $e');
    return [];
  }
}



  Future<List<dynamic>> getUsersForTechnician(String technicianId) async {
  try {
    final response = await http.get(Uri.parse('your-api-url/users/$technicianId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((user) {
        return {
          'id': user['id'] ?? '',  // Provide a default value if null
          'name': user['name'] ?? 'No name available',
          'email': user['email'] ?? 'No email available',
          // Handle other fields as needed
        };
      }).toList();
    } else {
      throw Exception('Failed to load users');
    }
  } catch (e) {
    print('Error fetching users: $e');
    return []; // Return an empty list if an error occurs
  }
  }

 Future<Map<String, int>> getTaskStatusCounts() async {
    try {
final response = await http.get(Uri.parse('http://localhost:9090/api/taskStatusCounts'));


      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'Pending': data['pending'] ?? 0,
          'In Progress': data['inProgress'] ?? 0,
          'Completed': data['completed'] ?? 0,
        };
      } else {
        throw Exception('Failed to load task status counts');
      }
    } catch (e) {
      print('Error fetching task status counts: $e');
      return {'Pending': 0, 'In Progress': 0, 'Completed': 0}; // Default values on error
    }
  }

  Future<Map<String, dynamic>> loginClient(String email, String phone) async {
    final url = Uri.parse('$baseUrl/clients/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> loginSupervisor(String email, String phone) async {
    final url = Uri.parse('$baseUrl/supervisors/login'); // Ensure this matches your backend setup
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<dynamic>> getTechnicians() async {
    final url = Uri.parse('$baseUrl/technicians');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load technicians');
    }
  }

  Future<Map<String, dynamic>> getCurrentSupervisor() async {
    // Replace with actual code to get supervisor details
    return {'name': 'Supervisor Name'};
  }


  Future<Map<String, dynamic>> createIntervention(String clientId, String technicianId, String description, DateTime startDate, DateTime endDate) async {
  final url = Uri.parse('$baseUrl/interventions');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'client': clientId,
      'technician': technicianId,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to create intervention');
  }
}

Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Efface les données d'authentification stockées
  }
}
