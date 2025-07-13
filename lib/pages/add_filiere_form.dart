import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'entity_list_page.dart';

class AddFiliereForm extends StatefulWidget {
  const AddFiliereForm({Key? key}) : super(key: key);

  @override
  State<AddFiliereForm> createState() => _AddFiliereFormState();
}

class _AddFiliereFormState extends State<AddFiliereForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _departementController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _departementController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "nom": _nomController.text.trim(),
      "departement": _departementController.text.trim(),
    };

    setState(() => _isLoading = true);

    try {
      await ApiService.addFiliere(data);

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
                      endpoint: 'filieres/',
                      fieldsToShow: ['nom', 'departement'],
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
                _departementController.clear();
              },
              child: const Text('Ajouter un nouvel élément'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
