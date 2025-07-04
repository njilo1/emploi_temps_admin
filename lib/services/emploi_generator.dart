import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'api_service.dart';

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

    // Utilise ApiService pour gérer la conversion noms → IDs et l'envoi
    await ApiService.post('/emplois/import/', {'emplois': emplois});
  }

  // Ancien utilitaire de conversion noms → IDs conservé pour référence
  // mais plus utilisé depuis l’intégration d'ApiService.post
}
