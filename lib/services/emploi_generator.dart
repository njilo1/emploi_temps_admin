import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

const String baseUrl = "http://127.0.0.1:8000/api"; // Remplace par ton IP en production

class EmploiGenerator {
  final List<String> tranchesHoraires = [
    '07H30 - 10H00',
    '10H15 - 12H45',
    '13H00 - 15H30', // Pause
    '15H45 - 18H15',
  ];

  final List<String> joursSemaine = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
  ];

  /// POST /api/emplois/generate/
  Future<void> genererEmploisAutomatiquement() async {
    final url = Uri.parse('$baseUrl/emplois/generate/');
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la génération : ${response.body}');
    }
  }

  /// GET /api/emplois/classe/<id>/
  Future<Map<String, Map<String, String>>> getEmploisParClasse(String classeId) async {
    final url = Uri.parse('$baseUrl/emplois/classe/$classeId/');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Erreur de chargement de l'emploi : ${response.body}");
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    final Map<String, Map<String, String>> emploi = {};

    for (final item in data) {
      final jour = item['jour'];
      final heure = item['heure'];
      final moduleNom = item['module_nom'] ?? 'Module';
      final salleNom = item['salle_nom'] ?? 'Salle';
      final profNom = item['prof_nom'] ?? 'Professeur';

      final contenu = "$moduleNom – $salleNom – $profNom";

      emploi.putIfAbsent(jour, () => {});
      emploi[jour]![heure] = contenu;
    }

    return emploi;
  }

  /// Importe un fichier JSON et l'envoie à l’API après conversion noms → IDs
  Future<void> importerDepuisFichier(String path) async {
    final contenu = await rootBundle.loadString(path);
    final Map<String, dynamic> data = json.decode(contenu);
    await importerDepuisJson(data);
  }

  /// Envoie les emplois du JSON à l’API Django avec noms convertis en IDs
  Future<void> importerDepuisJson(Map<String, dynamic> data) async {
    final emplois = data['emplois'] as List<dynamic>?;
    if (emplois == null) return;

    // 🔁 Obtenir les correspondances nom → ID
    final classMap = await _fetchIdMap('classes');
    final moduleMap = await _fetchIdMap('modules');
    final profMap = await _fetchIdMap('professeurs');
    final salleMap = await _fetchIdMap('salles');

    for (final e in emplois) {
      final payload = {
        'classe': classMap[e['classe']] ?? e['classe'],
        'jour': e['jour'],
        'heure': e['heure'],
        'module': moduleMap[e['module']] ?? e['module'],
        'prof': profMap[e['prof']] ?? e['prof'],
        'salle': salleMap[e['salle']] ?? e['salle'],
      };

      print('Payload envoyé : $payload'); // Debug

      final response = await http.post(
        Uri.parse('$baseUrl/emplois/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 201) {
        print('Erreur import : ${response.body}');
      }
    }
  }

  /// Mappe les noms (ou libellés) vers leur ID à partir de l’API
  Future<Map<String, int>> _fetchIdMap(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final Map<String, int> map = {};

      for (final item in data) {
        final name = item['nom'] ?? item['libelle'] ?? item['label'];
        if (name != null) {
          map[name] = item['id'];
        }
      }

      return map;
    } else {
      throw Exception('Impossible de charger les données de $endpoint');
    }
  }
}
