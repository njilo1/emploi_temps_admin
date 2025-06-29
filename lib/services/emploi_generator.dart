import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'api_service.dart';

class EmploiGenerator {
  Future<void> genererEmploisAutomatiquement() async {
    await ApiService.generateEmplois();
  }

  Future<Map<String, Map<String, String>>> getEmploisParClasse(String classeId) {
    return ApiService.fetchEmploiParClasse(classeId);
  }

  Future<void> importerDepuisJson(Map<String, dynamic> data) async {
    await ApiService.importEmplois(data);
  }

  Future<void> importerDepuisFichier(String path) async {
    final contenu = await rootBundle.loadString(path);
    final Map<String, dynamic> data = json.decode(contenu) as Map<String, dynamic>;
    await importerDepuisJson(data);
  }
}
