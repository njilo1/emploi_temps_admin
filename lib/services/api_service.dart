import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/platform_utils.dart';

class ApiService {
  // Configuration adaptative selon la plateforme
  static String get baseUrl {
    if (PlatformUtils.isWeb) {
      return 'http://localhost:8000/api';
    } else if (PlatformUtils.isAndroid) {
      return 'http://10.0.2.2:8000/api'; // Pour l'émulateur Android
    } else {
      return 'http://localhost:8000/api';
    }
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // ----- Méthodes génériques -----
  static Future<List<dynamic>> getData(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('❌ Failed to load data from $endpoint\nStatus: ${response.statusCode}\nBody: ${response.body}');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur de connexion: $e');
    }
  }

  static Future<void> deleteData(String endpointWithId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpointWithId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 204) {
        throw Exception('❌ Failed to delete data from $endpointWithId\nStatus: ${response.statusCode}\nBody: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur de connexion: $e');
    }
  }

  // ----- Classes -----
  static Future<List<dynamic>> fetchClasses() async => getData('classes/');

  static Future<void> addClasse(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/classes/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to add classe: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de l\'ajout de la classe: $e');
    }
  }

  static Future<void> updateClasse(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/classes/$id/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to update classe: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de la mise à jour de la classe: $e');
    }
  }

  static Future<void> deleteClasse(String id) async => deleteData('classes/$id/');

  // ----- Filières -----
  static Future<List<dynamic>> fetchFilieres() async => getData('filieres/');

  static Future<void> addFiliere(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/filieres/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to add filiere: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de l\'ajout de la filière: $e');
    }
  }

  static Future<void> updateFiliere(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/filieres/$id/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to update filiere: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de la mise à jour de la filière: $e');
    }
  }

  static Future<void> deleteFiliere(String id) async => deleteData('filieres/$id/');

  // ----- Professeurs -----
  static Future<List<dynamic>> fetchProfesseurs() async => getData('professeurs/');

  static Future<void> addProfesseur(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/professeurs/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to add professeur: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de l\'ajout du professeur: $e');
    }
  }

  static Future<void> updateProfesseur(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/professeurs/$id/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to update professeur: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de la mise à jour du professeur: $e');
    }
  }

  static Future<void> deleteProfesseur(String id) async => deleteData('professeurs/$id/');

  // ----- Salles -----
  static Future<List<dynamic>> fetchSalles() async => getData('salles/');

  static Future<void> addSalle(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/salles/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to add salle: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de l\'ajout de la salle: $e');
    }
  }

  static Future<void> updateSalle(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/salles/$id/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to update salle: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de la mise à jour de la salle: $e');
    }
  }

  static Future<void> deleteSalle(String id) async => deleteData('salles/$id/');

  // ----- Modules -----
  static Future<List<dynamic>> fetchModules() async => getData('modules/');

  static Future<void> addModule(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/modules/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to add module: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de l\'ajout du module: $e');
    }
  }

  static Future<void> updateModule(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/modules/$id/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to update module: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de la mise à jour du module: $e');
    }
  }

  static Future<void> deleteModule(String id) async => deleteData('modules/$id/');

  // ----- Emplois -----
  static Future<Map<String, Map<String, String>>> fetchEmploiParClasse(String classeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/emplois/classe/$classeId/'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data.map((k, v) => MapEntry(k, Map<String, String>.from(v)));
      }
      throw Exception('❌ Failed to load emploi\nStatus: ${response.statusCode}\nBody: ${response.body}');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors du chargement de l\'emploi: $e');
    }
  }

  static Future<void> generateEmplois() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/emplois/generate/'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to generate emplois: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de la génération des emplois: $e');
    }
  }

  static Future<void> importEmplois(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/emplois/import/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        print('❌ Erreur import : ${response.statusCode}');
        print(response.body);
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to import emplois: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de l\'import des emplois: $e');
    }
  }

  // ----- Départements -----
  static Future<List<dynamic>> fetchDepartements() async => getData('departements/');

  static Future<void> addDepartement(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/departements/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to add departement: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de l\'ajout du département: $e');
    }
  }

  static Future<void> updateDepartement(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/departements/$id/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception('❌ Failed to update departement: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur lors de la mise à jour du département: $e');
    }
  }

  static Future<void> deleteDepartement(String id) async => deleteData('departements/$id/');

  // ✅ Méthode POST générique
  static Future<void> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception('Erreur ${response.statusCode} : ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur de connexion: $e');
    }
  }

  // 🗑️ Méthode pour vider tous les emplois
  static Future<void> deleteAllEmplois() async {
    try {
      final url = Uri.parse('$baseUrl/emplois/clear/');
      final response = await http.delete(url, headers: _headers).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorBody = jsonDecode(response.body);
        throw Exception('Erreur ${response.statusCode} : ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('❌ Timeout: Le serveur ne répond pas. Vérifiez que le backend Django est démarré.');
      }
      throw Exception('❌ Erreur de connexion: $e');
    }
  }
}
