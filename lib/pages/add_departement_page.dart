import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Page d'ajout d'un département
class AddDepartementPage extends StatefulWidget {
  const AddDepartementPage({Key? key}) : super(key: key);

  @override
  State<AddDepartementPage> createState() => _AddDepartementPageState();
}

class _AddDepartementPageState extends State<AddDepartementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _codeController = TextEditingController();

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('departements').add({
        'nom': _nomController.text.trim(),
        'code': _codeController.text.trim(),
      });
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un département')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
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
    _codeController.dispose();
    super.dispose();
  }
}
