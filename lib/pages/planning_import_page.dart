import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import '../services/emploi_generator.dart';

class PlanningImportPage extends StatefulWidget {
  const PlanningImportPage({super.key});

  @override
  State<PlanningImportPage> createState() => _PlanningImportPageState();
}

class _PlanningImportPageState extends State<PlanningImportPage> {
  XFile? _selectedFile;
  bool _loading = false;
  String? _message;
  final EmploiGenerator _generator = EmploiGenerator();

  Future<void> _pickFile() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Documents Word',
      extensions: ['docx'],
    );

    final XFile? fichier = await openFile(acceptedTypeGroups: [typeGroup]);

    if (fichier != null) {
      setState(() {
        _selectedFile = fichier;
      });
    }
  }

  Future<void> _sendFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        // Remplace cette IP si besoin (10.0.2.2 pour Android emulator, sinon l'IP locale du PC)
        Uri.parse('http://10.213.46.183:8000/parse-word'),
      );

      if (kIsWeb) {
        final bytes = await _selectedFile!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('file', bytes,
            filename: _selectedFile!.name));
      } else {
        request.files
            .add(await http.MultipartFile.fromPath('file', _selectedFile!.path));
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(body) as Map<String, dynamic>;
        await _generator.importerDepuisJson(data);

        setState(() {
          _message = '✅ Planning importé avec succès';
        });
      } else {
        setState(() {
          _message = "❌ Erreur serveur : ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _message = '❌ Erreur : $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importer un planning')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Sélectionner le fichier Word'),
            ),
            const SizedBox(height: 10),
            Text(
              _selectedFile?.name ?? 'Aucun fichier sélectionné',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _sendFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Envoyer et importer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _message!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _message!.contains("✅") ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
