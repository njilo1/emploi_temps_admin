import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/emploi_generator.dart';
import '../widgets/emploi_table.dart';

class EmploiGlobalPage extends StatefulWidget {
  const EmploiGlobalPage({super.key});

  @override
  State<EmploiGlobalPage> createState() => _EmploiGlobalPageState();
}

class _EmploiGlobalPageState extends State<EmploiGlobalPage> {
  final EmploiGenerator _generator = EmploiGenerator();
  List<String> _filieres = [];
  String? _filiere;
  Map<String, Map<String, Map<String, String>>> _emploiParClasse = {};

  @override
  void initState() {
    super.initState();
    _chargerFilieres();
  }

  Future<void> _chargerFilieres() async {
    final snapshot = await FirebaseFirestore.instance.collection('classes').get();
    final fil = snapshot.docs.map((e) => e['filiere'] as String).toSet().toList();
    setState(() {
      _filieres = fil;
      if (fil.isNotEmpty) _filiere = fil.first;
    });
    if (fil.isNotEmpty) {
      _chargerEmplois();
    }
  }

  Future<void> _chargerEmplois() async {
    if (_filiere == null) return;
    final classesSnapshot = await FirebaseFirestore.instance
        .collection('classes')
        .where('filiere', isEqualTo: _filiere)
        .get();
    Map<String, Map<String, Map<String, String>>> data = {};
    for (final classe in classesSnapshot.docs) {
      final emplois = await _generator.getEmploisParClasse(classe.id);
      data[classe['nom']] = emplois;
    }
    setState(() {
      _emploiParClasse = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emplois par Departement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _filiere,
              items: _filieres
                  .map((f) => DropdownMenuItem<String>(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _filiere = val;
                });
                _chargerEmplois();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _emploiParClasse.entries.map((entry) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          EmploiTable(emploiData: entry.value),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
