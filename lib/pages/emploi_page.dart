// lib/pages/emploi_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/emploi_generator.dart';
import '../services/pdf_exporter.dart';
import '../widgets/emploi_table.dart';
import 'package:file_selector/file_selector.dart';

class EmploiPage extends StatefulWidget {
  const EmploiPage({super.key});

  @override
  State<EmploiPage> createState() => _EmploiPageState();
}

class _EmploiPageState extends State<EmploiPage> {
  final EmploiGenerator _generator = EmploiGenerator();
  bool _isLoading = false;
  String? _message;

  List<Map<String, dynamic>> _classes = [];
  String? _selectedClassId;
  Map<String, Map<String, String>> emplois = {};
  final PdfExporter _pdfExporter = PdfExporter();

  @override
  void initState() {
    super.initState();
    _chargerClasses();
  }

  Future<void> _chargerClasses() async {
    final snapshot = await FirebaseFirestore.instance.collection('classes').get();
    setState(() {
      _classes = snapshot.docs.map((doc) => {
        'id': doc.id,
        'nom': (doc.data()['nom'] ?? 'Sans nom'),
      }).toList();
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
      emplois = {}; // réinitialise le tableau affiché
    });

    try {
      await _generator.genererEmploisAutomatiquement();
      final result = await _generator.getEmploisParClasse(_selectedClassId!);
      setState(() {
        emplois = result;
        _message = "✅ Emploi du temps généré avec succès !";
      });
      debugPrint('Emplois récupérés: $result');
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

  Future<void> _exportPdf() async {
    if (_selectedClassId == null) return;
    final XTypeGroup typeGroup = const XTypeGroup(label: 'PDF', extensions: ['pdf']);
    final path = await getSavePath(suggestedName: 'emploi.pdf', acceptedTypeGroups: [typeGroup]);
    if (path == null) return;

    try {
      final data = emplois.isNotEmpty ? emplois : await _generator.getEmploisParClasse(_selectedClassId!);
      await _pdfExporter.exportEmploi(path, data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exporté')),);
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
              "Sélectionne une classe et génère automatiquement son emploi du temps.",
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
                : ElevatedButton.icon(
              onPressed: _genererEmploi,
              icon: const Icon(Icons.refresh),
              label: const Text("Générer l'emploi du temps"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
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
