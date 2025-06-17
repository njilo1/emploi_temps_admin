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
  String? _selectedFiliereId;
  String? _selectedClassId;
  List<Map<String, dynamic>> _filieres = [];
  List<Map<String, dynamic>> _classes = [];
  Map<String, Map<String, String>> emplois = {};

  @override
  void initState() {
    super.initState();
    _loadFilieres();
  }

  Future<void> _loadFilieres() async {
    final snap = await FirebaseFirestore.instance.collection('filieres').get();
    setState(() {
      _filieres =
          snap.docs.map((d) => {'id': d.id, 'nom': d['nom'] ?? 'Filière'}).toList();
      if (_filieres.isNotEmpty) {
        _selectedFiliereId = _filieres.first['id'];
        _loadClasses();
      }
    });
  }

  Future<void> _loadClasses() async {
    if (_selectedFiliereId == null) return;
    final classesSnap = await FirebaseFirestore.instance
        .collection('classes')
        .where('filiere', isEqualTo: _selectedFiliereId)
        .get();
    setState(() {
      _classes = classesSnap.docs
          .map((c) => {'id': c.id, 'nom': c['nom']})
          .toList();
      if (_classes.isNotEmpty) {
        _selectedClassId = _classes.first['id'];
      }
    });
  }

  Future<void> _loadEmploi() async {
    if (_selectedClassId == null) return;
    final data = await _generator.getEmploisParClasse(_selectedClassId!);
    setState(() => emplois = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emplois du temps')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFiliereId,
                    hint: const Text('Filière'),
                    isExpanded: true,
                    items: _filieres
                        .map((f) => DropdownMenuItem(
                              value: f['id'],
                              child: Text(f['nom']),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedFiliereId = val;
                        _loadClasses();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedClassId,
                    hint: const Text('Classe'),
                    isExpanded: true,
                    items: _classes
                        .map((c) => DropdownMenuItem(
                              value: c['id'],
                              child: Text(c['nom']),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedClassId = val;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _loadEmploi,
                )
              ],
            ),
            const SizedBox(height: 20),
            if (emplois.isNotEmpty)
              Expanded(child: EmploiTable(emploiData: emplois)),
          ],
        ),
      ),
    );
  }
}
