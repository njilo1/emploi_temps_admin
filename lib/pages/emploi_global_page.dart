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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Génération terminée')),
        );
      }
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
              onPressed: _loading || _selection.isEmpty ? null : _generer,
              child: const Text('Générer automatiquement'),
            ),
            const SizedBox(height: 20),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_resultat != null) Expanded(child: _buildResultats()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultats() {
    final deps = _resultat!['departements'] as List<dynamic>;
    if (deps.isEmpty) return const SizedBox.shrink();

    return DefaultTabController(
      length: deps.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [for (final d in deps) Tab(text: d['nom'])],
          ),
          Expanded(
            child: TabBarView(
              children: deps.map((d) {
                final classes = d['classes'] as List<dynamic>;
                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: classes.map((c) {
                    final emploi = (c['emplois'] as Map).map(
                      (k, v) => MapEntry(k, Map<String, String>.from(v))
                    );
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['nom'], 
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                              )
                            ),
                            const SizedBox(height: 8),
                            EmploiTable(
                              emploiData: Map<String, Map<String, String>>.from(emploi)
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}