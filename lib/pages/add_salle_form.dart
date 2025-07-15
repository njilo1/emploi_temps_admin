import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../pages/entity_list_page.dart';

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

  @override
  void dispose() {
    _nomController.dispose();
    _capaciteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'nom': _nomController.text.trim(),
      'capacite': int.tryParse(_capaciteController.text.trim()) ?? 0,
      'disponible': _disponible,
    };

    try {
      await ApiService.addSalle(data);
      if (!mounted) return;

      // Affiche le popup de succès
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Erreur : $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche la fermeture en cliquant à l'extérieur
      builder: (context) => AlertDialog(
        title: const Text("✅ Succès"),
        content: const Text("Salle enregistrée avec succès."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme le popup
              // Redirige vers la liste des salles
              Navigator.pushNamed(context, '/salles');
            },
            child: const Text("Voir la liste salle"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme le popup
              // Réinitialise le formulaire
              _formKey.currentState!.reset();
              _nomController.clear();
              _capaciteController.clear();
              setState(() => _disponible = true);
            },
            child: const Text("Ajouter une autre salle"),
          ),
        ],
      ),
    );
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
                "Ajouter une salle",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
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
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: const Icon(Icons.save),
                label: const Text("Ajouter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}