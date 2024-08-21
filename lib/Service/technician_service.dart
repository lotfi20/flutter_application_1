import 'dart:convert';
import 'package:http/http.dart' as http;

class TechnicianService {
  final String baseUrl = 'http://localhost:9090/api';

 Future<dynamic> fetchTechnicianByEmailOrPhone(String email, String phone) async {
    final url = Uri.parse('$baseUrl/technicians/find?email=$email&phone=$phone');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load technician');
    }
  }

Future<dynamic> loginTechnician(String email, String phone) async {
    final url = Uri.parse('$baseUrl/technicians/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'phone': phone}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['technician'];
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<dynamic>> fetchTechnicians() async {
    final url = Uri.parse('$baseUrl/technicians');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load technicians');
    }
  }

  Future<void> createIntervention(
  String clientId,
  String technicianId,
  String description,
  String problemType,
  String replacementOption,
  DateTime startDate,
  DateTime endDate,
) async {
  final url = Uri.parse('$baseUrl/interventions');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'client': clientId,
      'technician': technicianId,
      'description': description,
      'problemType': problemType,
      'replacementOption': replacementOption,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': 'Pending',
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to create intervention');
  }
}
Future<List<dynamic>> fetchTechnicianInterventions(String technicianId) async {
    final url = Uri.parse('$baseUrl/api/interventions/technician/$technicianId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load interventions');
    }
  }

   Future<List<dynamic>> fetchInterventionsForTechnician(String technicianId) async {
    final url = Uri.parse('$baseUrl/interventions?technicianId=$technicianId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load interventions');
    }
  }

}
