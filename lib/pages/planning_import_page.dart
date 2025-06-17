import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../services/emploi_generator.dart';

class PlanningImportPage extends StatefulWidget {
  const PlanningImportPage({super.key});

  @override
  State<PlanningImportPage> createState() => _PlanningImportPageState();
}

class _PlanningImportPageState extends State<PlanningImportPage> {
  String? _filePath;
  bool _loading = false;
  String? _message;
  final EmploiGenerator _generator = EmploiGenerator();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Future<void> _sendFile() async {
    if (_filePath == null) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/parse-word'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', _filePath!));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final data = json.decode(body) as Map<String, dynamic>;
      await _generator.importerDepuisJson(data);
      setState(() {
        _message = 'Planning importé avec succès';
      });
    } else {
      setState(() {
        _message = "Erreur lors de l'import";
      });
    }
    setState(() {
      _loading = false;
    });
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
            Text(_filePath ?? 'Aucun fichier sélectionné'),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _sendFile,
                    icon: const Icon(Icons.upload),
                    label: const Text('Envoyer et importer'),
                  ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _message!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
