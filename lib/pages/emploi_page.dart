import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> _viderBaseDeDonnees() async {
    setState(() {
      _isLoading = true;
      _message = null;
      emplois = {};
    });

    try {
      await ApiService.deleteAllEmplois();
      await _chargerClasses();
      
      setState(() {
        _message = "🗑️ Base de données vidée avec succès !";
      });
      
      print('🗑️ Base de données vidée');
    } catch (e) {
      print('❌ Erreur lors du vidage: $e');
      setState(() {
        _message = "❌ Erreur lors du vidage : $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
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

    try {
      Directory? saveDir;

      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de stockage refusée')),
          );
          return;
        }
        saveDir = await getExternalStorageDirectory();
      } else {
        saveDir = await getDownloadsDirectory();
        saveDir ??= await getApplicationDocumentsDirectory();
      }

      if (saveDir == null) throw Exception('Dossier inaccessible');

      final String path = '${saveDir.path}/emploi_${_selectedClassId!}.pdf';
      final data = emplois.isNotEmpty
          ? emplois
          : await ApiService.fetchEmploiParClasse(_selectedClassId!);

      await _pdfExporter.exportEmploi(path, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📄 PDF exporté : $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur export: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Génération de l\'emploi du temps'),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header avec icône
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.schedule,
                        size: 40,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Gestion des emplois du temps",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sélectionnez une classe et générez ou importez son emploi du temps",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Sélection de classe
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.class_, color: Colors.teal.shade600, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          "Sélection de classe",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedClassId,
                                isExpanded: true,
                                hint: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    _classes.isEmpty ? "Aucune classe trouvée" : "Choisir une classe",
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ),
                                items: _classes.map((classe) {
                                  return DropdownMenuItem<String>(
                                    value: classe['id'],
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        classe['nom'],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
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
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _chargerClasses,
                            icon: Icon(Icons.refresh, color: Colors.teal.shade700),
                            tooltip: 'Recharger les classes',
                          ),
                        ),
                      ],
                    ),
                    if (_classes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Aucune classe disponible. Ajoutez des classes via le menu.',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Boutons d'action
              if (_isLoading)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: Colors.teal),
                      const SizedBox(height: 16),
                      Text(
                        "Traitement en cours...",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Actions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 16), // Réduit de 20 à 16
                      
                      // Bouton Export PDF
                      _buildActionButton(
                        onPressed: _exportPdf,
                        icon: Icons.picture_as_pdf,
                        label: "Exporter PDF",
                        color: Colors.blue.shade600,
                        gradient: [Colors.blue.shade500, Colors.blue.shade600],
                      ),
                      const SizedBox(height: 8), // Réduit de 12 à 8
                      
                      // Bouton Générer automatiquement
                      _buildActionButton(
                        onPressed: _genererEmploi,
                        icon: Icons.auto_awesome,
                        label: "Générer automatiquement",
                        color: Colors.teal.shade600,
                        gradient: [Colors.teal.shade500, Colors.teal.shade600],
                      ),
                      const SizedBox(height: 8), // Réduit de 12 à 8
                      
                      // Bouton Importer depuis JSON
                      _buildActionButton(
                        onPressed: _importerEmploiDepuisJson,
                        icon: Icons.upload_file,
                        label: "Importer depuis JSON",
                        color: Colors.deepPurple.shade600,
                        gradient: [Colors.deepPurple.shade500, Colors.deepPurple.shade600],
                      ),
                      const SizedBox(height: 8), // Réduit de 12 à 8
                      
                      // Bouton Vider la base
                      _buildActionButton(
                        onPressed: _viderBaseDeDonnees,
                        icon: Icons.clear_all,
                        label: "Vider la base",
                        color: Colors.red.shade600,
                        gradient: [Colors.red.shade500, Colors.red.shade600],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Message de statut
              if (_message != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _message!.startsWith("✅") ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _message!.startsWith("✅") ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _message!.startsWith("✅") ? Icons.check_circle : Icons.error,
                        color: _message!.startsWith("✅") ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _message!,
                          style: TextStyle(
                            color: _message!.startsWith("✅") ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Affichage de l'emploi
              if (emplois.isNotEmpty)
                Container(
                  height: 400, // Hauteur fixe pour éviter l'overflow
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.table_chart, color: Colors.teal.shade700),
                            const SizedBox(width: 8),
                            Text(
                              "Emploi du temps",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: EmploiTable(emploiData: emplois),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      height: 42, // Augmenté de 36 à 42
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Augmenté de 8 à 10
        gradient: LinearGradient(colors: gradient),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4), // Augmenté de 0.3 à 0.4 pour plus de visibilité
            spreadRadius: 1,
            blurRadius: 6, // Augmenté de 4 à 6
            offset: const Offset(0, 3), // Augmenté de 2 à 3
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Augmenté de 8 à 10
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20), // Augmenté de 18 à 20
            const SizedBox(width: 8), // Augmenté de 6 à 8
            Text(
              label,
              style: const TextStyle(
                fontSize: 13, // Augmenté de 12 à 13
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
