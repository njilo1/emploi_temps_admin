import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../services/api_service.dart';
import '../services/pdf_exporter.dart';
import '../widgets/emploi_table.dart';

class EmploiPage extends StatefulWidget {
  const EmploiPage({super.key});

  @override
  State<EmploiPage> createState() => _EmploiPageState();
}

class _EmploiPageState extends State<EmploiPage> {
  final PdfExporter _pdfExporter = PdfExporter();

  bool _isLoading = false;
  String? _message;
  List<Map<String, dynamic>> _classes = [];
  String? _selectedClassId;
  Map<String, Map<String, String>> emplois = {};

  @override
  void initState() {
    super.initState();
    _chargerClasses();
  }

  Future<void> _chargerClasses() async {
    try {
      final data = await ApiService.fetchClasses();
      setState(() {
        _classes = data
            .map((c) => {
          'id': c['id'].toString(),
          'nom': c['nom'] ?? 'Sans nom',
        })
            .toList();
        if (_classes.isNotEmpty) {
          _selectedClassId = _classes.first['id'];
        }
      });
      print('📚 Classes chargées: ${_classes.length} classes trouvées');
    } catch (e) {
      print('❌ Erreur lors du chargement des classes: $e');
      setState(() {
        _classes = [];
        _selectedClassId = null;
      });
    }
  }

  Future<void> _genererEmploi() async {
    if (_selectedClassId == null) {
      setState(() {
        _message = "❌ Veuillez sélectionner une classe d'abord";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
      emplois = {};
    });

    try {
      print('🔄 Génération d\'emploi pour la classe $_selectedClassId');
      await ApiService.generateEmplois();

      // Attendre un peu pour que la génération soit terminée
      await Future.delayed(const Duration(milliseconds: 500));

      final result = await ApiService.fetchEmploiParClasse(_selectedClassId!);
      print('📅 Emploi reçu de l\'API (génération): $result');
      setState(() {
        emplois = result;
        _message = "✅ Emploi du temps généré avec succès ! ${result.length} jours";
      });
      print('📅 Emploi généré: ${result.length} jours');
    } catch (e) {
      print('❌ Erreur lors de la génération: $e');
      setState(() {
        _message = "❌ Erreur : $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importerEmploiDepuisJson() async {
    setState(() {
      _isLoading = true;
      _message = null;
      emplois = {};
    });

    try {
      // Forcer le rechargement du fichier JSON
      final String jsonContent = await rootBundle.loadString('assets/emploi_test.json');
      print('📄 Fichier JSON brut: $jsonContent');
      final Map<String, dynamic> data = json.decode(jsonContent);

      print('📥 Import des données: ${data['emplois'].length} emplois à importer');
      print('📄 Contenu JSON: ${json.encode(data)}');

      // Import des emplois
      await ApiService.post('/emplois/import/', data);

      // Recharger la liste des classes après import
      await _chargerClasses();

      // Attendre un peu pour que la base de données soit mise à jour
      await Future.delayed(const Duration(milliseconds: 1000));

      // Si une classe est sélectionnée, charger son emploi
      if (_selectedClassId != null) {
        final result = await ApiService.fetchEmploiParClasse(_selectedClassId!);
        print('📅 Emploi reçu de l\'API: $result');
        setState(() {
          emplois = result;
          _message = "✅ Emploi importé avec succès ! ${result.length} jours chargés";
        });
        print('📅 Emploi chargé pour la classe $_selectedClassId: ${result.length} jours');
      } else {
        setState(() {
          _message = "✅ Import réussi ! Sélectionnez une classe pour voir l'emploi";
        });
      }
    } catch (e) {
      print('❌ Erreur lors de l\'import: $e');
      setState(() {
        _message = "❌ Import échoué : $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

    Future<void> _exportPdf() async {
    if (_selectedClassId == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export PDF indisponible sur le Web')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Génération de l’emploi du temps'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.schedule, size: 80, color: Colors.teal),
            const SizedBox(height: 10),
            const Text(
              "Sélectionne une classe et génère ou importe son emploi du temps.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.class_, color: Colors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedClassId,
                          isExpanded: true,
                          hint: Text(_classes.isEmpty ? "Aucune classe trouvée" : "Choisir une classe"),
                          items: _classes.map((classe) {
                            return DropdownMenuItem<String>(
                              value: classe['id'],
                              child: Text(classe['nom']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClassId = value;
                            });
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _chargerClasses,
                      icon: const Icon(Icons.refresh, color: Colors.teal),
                      tooltip: 'Recharger les classes',
                    ),
                  ],
                ),
              ),
            ),
            if (_classes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Aucune classe disponible. Importez des données ou créez des classes.',
                  style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _exportPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exporter PDF'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _genererEmploi,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Générer automatiquement"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _importerEmploiDepuisJson,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Importer depuis JSON"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Demander confirmation avant de vider
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text('Êtes-vous sûr de vouloir vider toute la base de données des emplois ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Vider'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true) return;

                    setState(() {
                      _isLoading = true;
                      _message = null;
                      emplois = {};
                    });
                    try {
                      // Vider tous les emplois en utilisant DELETE
                      await ApiService.deleteAllEmplois();
                      await _chargerClasses();
                      setState(() {
                        _message = "🗑️ Base de données vidée";
                      });
                    } catch (e) {
                      setState(() {
                        _message = "❌ Erreur: $e";
                      });
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text("Vider la base"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.startsWith("✅") ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 10),
            if (emplois.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(top: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: EmploiTable(emploiData: emplois),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
