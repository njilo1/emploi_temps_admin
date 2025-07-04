import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_module_page.dart';

class ModuleListPage extends StatefulWidget {
  const ModuleListPage({Key? key}) : super(key: key);

  @override
  State<ModuleListPage> createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> {
  // 🔁 Recharge automatique après ajout/modif
  Future<void> _refresh() async => setState(() {});

  // 🔁 Obtenir le nom d’un élément depuis son ID
  Future<String> _getDocName(String collection, String id) async {
    if (id.isEmpty) return '';
    switch (collection) {
      case 'classes':
        final classes = await ApiService.fetchClasses();
        return classes.firstWhere((c) => c['id'].toString() == id, orElse: () => {})['nom'] ?? '';
      case 'salles':
        final salles = await ApiService.fetchSalles();
        return salles.firstWhere((s) => s['id'].toString() == id, orElse: () => {})['nom'] ?? '';
      case 'professeurs':
        final profs = await ApiService.fetchProfesseurs();
        return profs.firstWhere((p) => p['id'].toString() == id, orElse: () => {})['nom'] ?? '';
      default:
        return '';
    }
  }

  Future<void> _delete(String id) async {
    await ApiService.deleteModule(id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des modules')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddModulePage()));
          await _refresh(); // 🔁 refresh après ajout
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.fetchModules(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Erreur de chargement'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!;
          if (docs.isEmpty) return const Center(child: Text('Aucun module'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              final docId = data['id']?.toString() ?? '';

              return FutureBuilder<List<String>>(
                future: Future.wait([
                  _getDocName('classes', data['classe'].toString()),
                  _getDocName('salles', data['salle'].toString()),
                  _getDocName('professeurs', data['prof'].toString()),
                ]),
                builder: (context, snapshotNames) {
                  if (!snapshotNames.hasData) return const SizedBox();
                  final classeNom = snapshotNames.data![0];
                  final salleNom = snapshotNames.data![1];
                  final profNom = snapshotNames.data![2];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(data['nom'] ?? ''),
                      subtitle: Text(
                        '${data['jour']} - ${data['heure']}\nClasse: $classeNom - Salle: $salleNom\nProf: $profNom',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddModulePage(moduleId: int.parse(docId)),
                                ),
                              );
                              await _refresh(); // 🔁 refresh après édition
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Confirmer'),
                                  content: const Text('Supprimer ce module ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _delete(docId);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
