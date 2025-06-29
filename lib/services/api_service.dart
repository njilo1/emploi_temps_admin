import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  // Generic helper
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  // ----- Classes -----
  static Future<List<dynamic>> fetchClasses() async {
    final response = await http.get(Uri.parse('$baseUrl/classes/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load classes');
  }

  static Future<void> addClasse(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/classes/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 201) {
      throw Exception('Failed to add classe');
    }
  }

  static Future<void> updateClasse(String id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/classes/$id/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Failed to update classe');
    }
  }

  static Future<void> deleteClasse(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/classes/$id/'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete classe');
    }
  }

  // ----- Filières -----
  static Future<List<dynamic>> fetchFilieres() async {
    final response = await http.get(Uri.parse('$baseUrl/filieres/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load filieres');
  }

  static Future<void> addFiliere(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/filieres/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 201) {
      throw Exception('Failed to add filiere');
    }
  }

  static Future<void> updateFiliere(String id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/filieres/$id/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Failed to update filiere');
    }
  }

  static Future<void> deleteFiliere(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/filieres/$id/'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete filiere');
    }
  }

  // ----- Professeurs -----
  static Future<List<dynamic>> fetchProfesseurs() async {
    final response = await http.get(Uri.parse('$baseUrl/professeurs/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load professeurs');
  }

  static Future<void> addProfesseur(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/professeurs/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 201) {
      throw Exception('Failed to add professeur');
    }
  }

  static Future<void> updateProfesseur(
      String id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/professeurs/$id/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Failed to update professeur');
    }
  }

  static Future<void> deleteProfesseur(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/professeurs/$id/'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete professeur');
    }
  }

  // ----- Salles -----
  static Future<List<dynamic>> fetchSalles() async {
    final response = await http.get(Uri.parse('$baseUrl/salles/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load salles');
  }

  static Future<void> addSalle(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/salles/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 201) {
      throw Exception('Failed to add salle');
    }
  }

  static Future<void> updateSalle(String id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/salles/$id/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Failed to update salle');
    }
  }

  static Future<void> deleteSalle(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/salles/$id/'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete salle');
    }
  }

  // ----- Departements -----
  static Future<List<dynamic>> fetchDepartements() async {
    final response = await http.get(Uri.parse('$baseUrl/departements/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load departements');
  }

  static Future<void> addDepartement(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/departements/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 201) {
      throw Exception('Failed to add departement');
    }
  }

  static Future<void> updateDepartement(String id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/departements/$id/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Failed to update departement');
    }
  }

  static Future<void> deleteDepartement(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/departements/$id/'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete departement');
    }
  }

  // ----- Modules -----
  static Future<List<dynamic>> fetchModules() async {
    final response = await http.get(Uri.parse('$baseUrl/modules/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load modules');
  }

  static Future<Map<String, dynamic>> fetchModule(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/modules/$id/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load module');
  }

  static Future<void> addModule(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/modules/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 201) {
      throw Exception('Failed to add module');
    }
  }

  static Future<void> updateModule(String id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/modules/$id/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Failed to update module');
    }
  }

  static Future<void> deleteModule(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/modules/$id/'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete module');
    }
  }

  // ----- Emplois -----
  static Future<Map<String, Map<String, String>>> fetchEmploiParClasse(
      String classeId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/emplois/$classeId/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data.map((k, v) => MapEntry(k, Map<String, String>.from(v)));
    }
    throw Exception('Failed to load emploi');
  }

  static Future<void> generateEmplois() async {
    final response = await http.post(Uri.parse('$baseUrl/emplois/generate/'));
    if (response.statusCode != 200) {
      throw Exception('Failed to generate emplois');
    }
  }

  static Future<void> importEmplois(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/emplois/import/'),
        headers: _headers, body: jsonEncode(data));
    if (response.statusCode != 200) {
      throw Exception('Failed to import emplois');
    }
  }
}

