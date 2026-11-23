import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  String get baseUrl =>
      kIsWeb ? "http://127.0.0.1:5000" : "http://10.0.2.2:5000";

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? "API Error");
    }
  }

  Future<double> predictGlucose(double carbs, double insulin) async {
    final response = await post('/predict', {
      "carbs": carbs,
      "insulinDose": insulin,
    });

    return (response['prediction'] as num).toDouble();
  }

  Future<void> saveEntry(Map<String, dynamic> data) async {
    await post('/add_entry', data);
  }

  Future<List<dynamic>> fetchHistory(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/history/$email'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load history");
    }
  }
}
