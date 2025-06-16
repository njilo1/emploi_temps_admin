import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddFiliereForm extends StatefulWidget {
  const AddFiliereForm({Key? key}) : super(key: key);

  @override
  State<AddFiliereForm> createState() => _AddFiliereFormState();
}

class _AddFiliereFormState extends State<AddFiliereForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _departementController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajouter une filière',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Nom de la filière
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la filière',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 15),

              // Département
              TextFormField(
                controller: _departementController,
                decoration: const InputDecoration(
                  labelText: 'Département',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 20),

              // Bouton Enregistrer
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _firestoreService.addData('filieres', {
                      'nom': _nomController.text.trim(),
                      'departement': _departementController.text.trim(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filière enregistrée avec succès')),
                    );

                    _nomController.clear();
                    _departementController.clear();
                  }
                },
                child: const Text('Enregistrer'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _departementController.dispose();
    super.dispose();
  }
}
