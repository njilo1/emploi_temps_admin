import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_module_page.dart';

/// Page listant l'ensemble des modules enregistrés dans Firestore
class ModuleListPage extends StatelessWidget {
  const ModuleListPage({Key? key}) : super(key: key);

  Future<String> _getDocName(String collection, String id) async {
    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .get();
    final data = doc.data() as Map<String, dynamic>?;
    return data != null ? (data['nom'] ?? '') : '';
  }

  Future<void> _delete(String id) async {
    await FirebaseFirestore.instance.collection('modules').doc(id).delete();
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
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('modules').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Aucun module'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
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
                                  builder: (_) => AddModulePage(moduleId: doc.id),
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
                                await _delete(doc.id);
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
