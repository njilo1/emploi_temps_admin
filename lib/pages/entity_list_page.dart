import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntityListPage extends StatelessWidget {
  final String collectionName;
  final List<String> fieldsToShow;

  const EntityListPage({
    Key? key,
    required this.collectionName,
    required this.fieldsToShow,
  }) : super(key: key);

  /// Fonction de suppression d'un document
  Future<void> _deleteEntity(String docId) async {
    await FirebaseFirestore.instance.collection(collectionName).doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste : $collectionName'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Erreur de chargement'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Aucun élément trouvé"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    fieldsToShow.map((f) => data[f]?.toString() ?? '').join(' - '),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Confirmation"),
                          content: const Text("Supprimer cet élément ?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Annuler"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Supprimer"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _deleteEntity(doc.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Élément supprimé')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
