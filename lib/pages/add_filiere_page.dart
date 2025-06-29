import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Formulaire d'ajout d'une filière liée à un département
class AddFilierePage extends StatefulWidget {
  const AddFilierePage({Key? key}) : super(key: key);

  @override
  State<AddFilierePage> createState() => _AddFilierePageState();
}

class _AddFilierePageState extends State<AddFilierePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  String? _selectedDepartementId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une filière')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom de la filière'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<dynamic>>(
                future: ApiService.fetchDepartements(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final deps = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    value: _selectedDepartementId,
                    decoration:
                        const InputDecoration(labelText: 'Département'),
                    items: deps
                        .map((d) => DropdownMenuItem(
                              value: d['id']?.toString() ?? '',
                              child: Text(d['nom'] ?? ''),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedDepartementId = v),
                    validator: (v) => v == null ? 'Choisir un département' : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await ApiService.addFiliere({
                      'nom': _nomController.text.trim(),
                      'departement': _selectedDepartementId,
                    });
                    if (mounted) Navigator.pop(context);
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
    super.dispose();
  }
}
