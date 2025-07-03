import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddSalleForm extends StatefulWidget {
  const AddSalleForm({Key? key}) : super(key: key);

  @override
  State<AddSalleForm> createState() => _AddSalleFormState();
}

class _AddSalleFormState extends State<AddSalleForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _capaciteController = TextEditingController();
  bool _disponible = true;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nom': _nomController.text.trim(),
        'capacite': int.tryParse(_capaciteController.text.trim()) ?? 0,
        'disponible': _disponible,
      };

      try {
        await ApiService.addSalle(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Salle ajoutée")));
        _formKey.currentState!.reset();
        setState(() => _disponible = true);
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
              const Text("Ajouter une salle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: "Nom de la salle"),
                validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capaciteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Capacité"),
                validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
              ),
              SwitchListTile(
                value: _disponible,
                title: const Text("Salle disponible"),
                onChanged: (v) => setState(() => _disponible = v),
              ),
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
    _capaciteController.dispose();
    super.dispose();
  }
}
