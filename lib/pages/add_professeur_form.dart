import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'entity_list_page.dart';

class AddProfesseurForm extends StatefulWidget {
  const AddProfesseurForm({Key? key}) : super(key: key);

  @override
  State<AddProfesseurForm> createState() => _AddProfesseurFormState();
}

class _AddProfesseurFormState extends State<AddProfesseurForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _dispoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'nom': _nomController.text.trim(),
      'disponibilites': _dispoController.text.trim(),
    };

    setState(() => _isLoading = true);

    try {
      await ApiService.addProfesseur(data);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('✅ Élément enregistré avec succès'),
          content:
              const Text('Voulez-vous voir la liste ou ajouter un nouveau ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EntityListPage(
                      endpoint: 'professeurs/',
                      fieldsToShow: ['nom'],
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
                _dispoController.clear();
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
    _dispoController.dispose();
    super.dispose();
  }
}
