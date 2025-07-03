import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddProfesseurForm extends StatefulWidget {
  const AddProfesseurForm({Key? key}) : super(key: key);

  @override
  State<AddProfesseurForm> createState() => _AddProfesseurFormState();
}

class _AddProfesseurFormState extends State<AddProfesseurForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _dispoController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nom': _nomController.text.trim(),
        'disponibilites': _dispoController.text.trim(),
      };

      try {
        await ApiService.addProfesseur(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Professeur ajouté")));
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Ajouter un professeur", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: "Nom"),
                validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dispoController,
                decoration: const InputDecoration(labelText: "Disponibilités"),
                validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text("Ajouter")),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _dispoController.dispose();
    super.dispose();
  }
}
