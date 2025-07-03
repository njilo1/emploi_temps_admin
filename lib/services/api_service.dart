import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // ----- Méthodes génériques (corrigées) -----
  static Future<List<dynamic>> getData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load data from $endpoint');
  }

  static Future<void> deleteData(String endpointWithId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpointWithId'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete data from $endpointWithId');
    }
  }

  // ----- Classes -----
  static Future<List<dynamic>> fetchClasses() async {
    return getData('classes/');
  }

  static Future<void> addClasse(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/classes/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add classe');
    }
  }

  static Future<void> updateClasse(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/classes/$id/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update classe');
    }
  }

  static Future<void> deleteClasse(String id) async {
    await deleteData('classes/$id/');
  }

  // ----- Filières -----
  static Future<List<dynamic>> fetchFilieres() async {
    return getData('filieres/');
  }

  static Future<void> addFiliere(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/filieres/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add filiere');
    }
  }

  static Future<void> updateFiliere(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/filieres/$id/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update filiere');
    }
  }

  static Future<void> deleteFiliere(String id) async {
    await deleteData('filieres/$id/');
  }

  // ----- Professeurs -----
  static Future<List<dynamic>> fetchProfesseurs() async {
    return getData('professeurs/');
  }

  static Future<void> addProfesseur(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/professeurs/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add professeur');
    }
  }

  static Future<void> updateProfesseur(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/professeurs/$id/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update professeur');
    }
  }

  static Future<void> deleteProfesseur(String id) async {
    await deleteData('professeurs/$id/');
  }

  // ----- Salles -----
  static Future<List<dynamic>> fetchSalles() async {
    return getData('salles/');
  }

  static Future<void> addSalle(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/salles/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add salle');
    }
  }

  static Future<void> updateSalle(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/salles/$id/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update salle');
    }
  }

  static Future<void> deleteSalle(String id) async {
    await deleteData('salles/$id/');
  }

  // ----- Modules -----
  static Future<List<dynamic>> fetchModules() async {
    return getData('modules/');
  }

  static Future<void> addModule(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/modules/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add module');
    }
  }

  static Future<void> updateModule(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/modules/$id/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update module');
    }
  }

  static Future<void> deleteModule(String id) async {
    await deleteData('modules/$id/');
  }

  // ----- Emplois -----
  static Future<Map<String, Map<String, String>>> fetchEmploiParClasse(String classeId) async {
    final response = await http.get(Uri.parse('$baseUrl/emplois/classe/$classeId/'));
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
    final response = await http.post(
      Uri.parse('$baseUrl/emplois/import/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to import emplois');
    }
  }

  // ----- Départements -----
  static Future<List<dynamic>> fetchDepartements() async {
    return getData('departements/');
  }

  static Future<void> addDepartement(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/departements/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add departement');
    }
  }

  static Future<void> updateDepartement(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/departements/$id/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update departement');
    }
  }

  static Future<void> deleteDepartement(String id) async {
    await deleteData('departements/$id/');
  }
}
