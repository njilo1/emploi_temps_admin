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
  bool _isDisponible = true; // Valeur par défaut : disponible


  @override
  void dispose() {
    _nomController.dispose();
    _capaciteController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nom': _nomController.text.trim(),
        'capacite': int.tryParse(_capaciteController.text.trim()) ?? 0,
        'disponible': _isDisponible,
      };

      try {
        await ApiService.addSalle(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salle ajoutée avec succès')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _isDisponible = true;
        });
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
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Ajouter une Salle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom de la salle'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capaciteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacité'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Capacité requise' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Salle disponible'),
                value: _isDisponible,
                onChanged: (value) {
                  setState(() {
                    _isDisponible = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
