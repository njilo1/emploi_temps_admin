import 'dart:convert';
import 'dart:io';

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
  bool _loading = false;
  String? _message;
  final EmploiGenerator _generator = EmploiGenerator();

  Future<void> _importPlanning() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['docx']);
    if (result == null) return;
    final path = result.files.single.path!;

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('http://localhost:8000/parse-word'));
      request.files.add(await http.MultipartFile.fromPath('file', path));
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode == 200) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        await _generator.importFromJson(data);
        setState(() => _message = 'Import réussi');
      } else {
        setState(() => _message = 'Erreur serveur');
      }
    } catch (e) {
      setState(() => _message = 'Erreur : $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importer un planning')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _importPlanning,
              child: const Text('Sélectionner un fichier Word'),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_message != null) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_message!),
            ),
          ],
        ),
      ),
    );
  }
}
