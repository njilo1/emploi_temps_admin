import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddFiliereForm extends StatefulWidget {
  const AddFiliereForm({Key? key}) : super(key: key);

  @override
  State<AddFiliereForm> createState() => _AddFiliereFormState();
}

class _AddFiliereFormState extends State<AddFiliereForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _departementController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _departementController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "nom": _nomController.text.trim(),
        "departement": _departementController.text.trim(),
      };

      try {
        await ApiService.addFiliere(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filière ajoutée avec succès')),
        );
        _formKey.currentState!.reset();
        _nomController.clear();
        _departementController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

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
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la filière',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _departementController,
                decoration: const InputDecoration(
                  labelText: 'Département',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
