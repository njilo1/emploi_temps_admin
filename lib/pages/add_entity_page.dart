import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddEntityPage extends StatefulWidget {
  final String collectionName;

  const AddEntityPage({super.key, required this.collectionName});

  @override
  State<AddEntityPage> createState() => _AddEntityPageState();
}

class _AddEntityPageState extends State<AddEntityPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter dans ${widget.collectionName}"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ générique (tu peux adapter selon la collection)
              TextFormField(
                decoration: const InputDecoration(labelText: "Nom"),
                onSaved: (value) => _formData['nom'] = value,
                validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
              ),

              if (widget.collectionName == 'classes') ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: "Filière"),
                  onSaved: (value) => _formData['filiere'] = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Effectif"),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _formData['effectif'] = int.tryParse(value ?? '0'),
                ),
              ],

              if (widget.collectionName == 'salles') ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: "Capacité"),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _formData['capacité'] = int.tryParse(value ?? '0'),
                ),
                SwitchListTile(
                  title: const Text("Disponible ?"),
                  value: _formData['disponible'] ?? true,
                  onChanged: (val) {
                    setState(() => _formData['disponible'] = val);
                  },
                ),
              ],

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveEntity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: const Text("Ajouter"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEntity() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        switch (widget.collectionName) {
          case 'classes':
            await ApiService.addClasse(_formData);
            break;
          case 'filieres':
            await ApiService.addFiliere(_formData);
            break;
          case 'professeurs':
            await ApiService.addProfesseur(_formData);
            break;
          case 'salles':
            await ApiService.addSalle(_formData);
            break;
          case 'modules':
            await ApiService.addModule(_formData);
            break;
          case 'departements':
            await ApiService.addDepartement(_formData);
            break;
          default:
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ajout réussi ✅")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    }
  }
}
