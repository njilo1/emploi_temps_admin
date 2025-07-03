import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_module_page.dart';

/// Page listant l'ensemble des modules enregistrés dans Firestore
class ModuleListPage extends StatefulWidget {
  const ModuleListPage({Key? key}) : super(key: key);

  @override
  State<ModuleListPage> createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> {
  Future<String> _getDocName(String collection, String id) async {
    switch (collection) {
      case 'classes':
        final classes = await ApiService.fetchClasses();
        return classes.firstWhere((c) => c['id'].toString() == id,
            orElse: () => {})['nom'] ?? '';
      case 'salles':
        final salles = await ApiService.fetchSalles();
        return salles.firstWhere((s) => s['id'].toString() == id,
            orElse: () => {})['nom'] ?? '';
      default:
        return '';
    }
  }

  Future<void> _delete(String id) async {
    await ApiService.deleteModule(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des modules')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddModulePage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.fetchModules(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!;
          if (docs.isEmpty) {
            return const Center(child: Text('Aucun module'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index] as Map<String, dynamic>;
              final docId = data['id']?.toString() ?? '';
              return FutureBuilder<List<String>>( 
                future: Future.wait([
                  _getDocName('classes', data['classe'] ?? ''),
                  _getDocName('salles', data['salle'] ?? ''),
                ]),
                builder: (context, snapshotNames) {
                  final classeNom =
                      snapshotNames.data != null ? snapshotNames.data![0] : '';
                  final salleNom =
                      snapshotNames.data != null ? snapshotNames.data![1] : '';
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(data['nom'] ?? ''),
                      subtitle: Text(
                          '${data['jour']} - ${data['heure']}\nClasse: $classeNom - Salle: $salleNom\nProf: ${data['prof']}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddModulePage(moduleId: int.parse(docId)),

                                ),
                              );
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
