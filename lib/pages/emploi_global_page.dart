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

  @override
  void initState() {
    super.initState();
    _chargerDepartements();
  }

  Future<void> _chargerDepartements() async {
    final deps = await ApiService.fetchDepartements();
    setState(() => _departements = deps);
  }

  Future<void> _generer() async {
    if (_selection.isEmpty) return;
    final data = await ApiService.generateEmploisByDepartements(_selection.toList());
    if (mounted) {
      setState(() => _resultat = data);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Génération terminée')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emploi global')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: _departements.map((d) {
                  final id = d['id'] as int;
                  return CheckboxListTile(
                    title: Text(d['nom'] ?? ''),
                    value: _selection.contains(id),
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
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _generer,
              child: const Text('Générer automatiquement'),
            ),
            const SizedBox(height: 16),
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
                  children: classes.map((c) {
                    final emploi = (c['emplois'] as Map).map((k, v) => MapEntry(k, Map<String, String>.from(v)));
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c['nom'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            EmploiTable(emploiData: Map<String, Map<String, String>>.from(emploi)),
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
