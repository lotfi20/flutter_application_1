import 'dart:convert';
import 'package:http/http.dart' as http;

class InterventionService {
  final String baseUrl = 'http://localhost:9090/api';

  // Méthode pour récupérer toutes les interventions
  Future<List<dynamic>> fetchInterventions() async {
    final url = Uri.parse('$baseUrl/interventions');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load interventions');
    }
  }

  // Nouvelle méthode pour récupérer les interventions d'un technicien spécifique
Future<List<dynamic>> fetchInterventionsByTechnician(String technicianId) async {
  final url = Uri.parse('http://localhost:9090/api/interventions/technician/$technicianId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load interventions for technician');
  }
}


  // Méthode pour mettre à jour une intervention
  Future<Map<String, dynamic>> updateIntervention(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/interventions/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update intervention');
    }
  }
}
