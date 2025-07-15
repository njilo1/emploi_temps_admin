import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/emploi_table.dart';

class EmploiGlobalPage extends StatefulWidget {
  const EmploiGlobalPage({super.key});

  @override
  State<EmploiGlobalPage> createState() => _EmploiGlobalPageState();
}

class _EmploiGlobalPageState extends State<EmploiGlobalPage> {
  List<dynamic> _departements = [];
  final Set<int> _selection = {};
  Map<String, dynamic>? _resultat;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _chargerDepartements();
  }

  Future<void> _chargerDepartements() async {
    final data = await ApiService.fetchDepartements();
    setState(() {
      _departements = data;
    });
  }

  Future<void> _generer() async {
    if (_selection.isEmpty) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.generateEmploisParDepartements(_selection.toList());
      setState(() {
        _resultat = res;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emploi global')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choisissez les départements à générer:'),
            ..._departements.map((d) {
              final id = d['id'] as int;
              return CheckboxListTile(
                value: _selection.contains(id),
                title: Text(d['nom'] ?? ''),
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selection.add(id);
                    } else {
                      _selection.remove(id);
                    }
                  });
                },
              );
            }),
            ElevatedButton(
              onPressed: _loading ? null : _generer,
              child: const Text('Générer automatiquement'),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_resultat != null)
              Expanded(
                child: ListView(
                  children: (_resultat!['departements'] as List<dynamic>).map((dep) {
                    final classes = dep['classes'] as List<dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dep['nom'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ...classes.map((cl) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(cl['nom'] ?? '', style: const TextStyle(fontSize: 16)),
                                  EmploiTable(
                                    emploiData: (cl['emplois'] as Map<String, dynamic>)
                                        .map((k, v) => MapEntry(k, Map<String, String>.from(v))),
                                  ),
                                ],
                              );
                            }).toList(),
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
