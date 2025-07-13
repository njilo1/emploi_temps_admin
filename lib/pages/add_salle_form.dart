import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'entity_list_page.dart';

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
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'nom': _nomController.text.trim(),
      'capacite': int.tryParse(_capaciteController.text.trim()) ?? 0,
      'disponible': _disponible,
    };

    setState(() => _isLoading = true);

    try {
      await ApiService.addSalle(data);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('✅ Élément enregistré avec succès'),
          content: const Text('Voulez-vous voir la liste ou ajouter un nouveau ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EntityListPage(
                      endpoint: 'salles/',
                      fieldsToShow: ['nom', 'capacite', 'disponible'],
                    ),
                  ),
                );
              },
              child: const Text('Voir la liste'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState!.reset();
                _nomController.clear();
                _capaciteController.clear();
                setState(() => _disponible = true);
              },
              child: const Text('Ajouter un nouvel élément'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Ajouter"),
              ),
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
