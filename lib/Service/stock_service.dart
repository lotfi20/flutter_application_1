import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService {
  final String baseUrl = 'http://localhost:9090/soin';

  Future<List<dynamic>> fetchStocks() async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stocks');
    }
  }

  Future<void> createStock(Map<String, dynamic> stock) async {
    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(stock),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create stock');
    }
  }

  Future<void> updateStock(String id, Map<String, dynamic> stock) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(stock),
    );

    if (response.statusCode == 200) {
    print('Stock updated successfully');
  } else {
    print('Failed to update stock: ${response.body}');
    throw Exception('Failed to update stock');
  }
  }

  Future<void> deleteStock(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete stock');
    }
  }
}
