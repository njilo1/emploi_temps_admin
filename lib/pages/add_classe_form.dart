import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddClasseForm extends StatefulWidget {
  const AddClasseForm({Key? key}) : super(key: key);

  @override
  State<AddClasseForm> createState() => _AddClasseFormState();
}

class _AddClasseFormState extends State<AddClasseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _effectifController = TextEditingController();
  String? _selectedFiliere;

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
                'Ajouter une classe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Nom de la classe
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la classe',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 15),

              // Effectif
              TextFormField(
                controller: _effectifController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Effectif',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 15),

              // Liste des filières (dropdown)
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('filieres').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();

                  final filieres = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    value: _selectedFiliere,
                    items: filieres.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final filiereName = data['nom'] ?? 'Inconnu';
                      return DropdownMenuItem<String>(
                        value: filiereName,
                        child: Text(filiereName),
                      );
                    }).toList(),
                    
                    decoration: const InputDecoration(
                      labelText: 'Filière',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedFiliere = value;
                      });
                    },
                    validator: (value) =>
                    value == null ? 'Veuillez choisir une filière' : null,
                  );
                },
              ),

              const SizedBox(height: 20),

              // Bouton enregistrer
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _firestoreService.addData('classes', {
                      'nom': _nomController.text.trim(),
                      'filiere': _selectedFiliere,
                      'effectif': int.parse(_effectifController.text.trim()),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Classe enregistrée avec succès')),
                    );

                    _nomController.clear();
                    _effectifController.clear();
                    setState(() {
                      _selectedFiliere = null;
                    });
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
    _effectifController.dispose();
    super.dispose();
  }
}
