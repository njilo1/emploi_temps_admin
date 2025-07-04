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
  }

  Future<void> _genererEmploi() async {
    if (_selectedClassId == null) return;

    setState(() {
      _isLoading = true;
      _message = null;
      emplois = {};
    });

    try {
      await ApiService.generateEmplois();
      final result = await ApiService.fetchEmploiParClasse(_selectedClassId!);
      setState(() {
        emplois = result;
        _message = "✅ Emploi du temps généré avec succès !";
      });
    } catch (e) {
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
    });

    try {
      final String jsonContent = await rootBundle.loadString('assets/emploi_test.json');
      final Map<String, dynamic> data = json.decode(jsonContent);

      // 🔁 Remplacement de la ligne problématique
      await ApiService.post('/emplois/import/', data);

      if (_selectedClassId != null) {
        final result = await ApiService.fetchEmploiParClasse(_selectedClassId!);
        setState(() {
          emplois = result;
          _message = "✅ Emploi importé avec succès depuis JSON !";
        });
      }
    } catch (e) {
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
                          hint: const Text("Choisir une classe"),
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
                  ],
                ),
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
