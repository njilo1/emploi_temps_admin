import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/excel_importer.dart';

/// Page d'import d'un planning depuis un fichier Excel
class ImportExcelPage extends StatefulWidget {
  const ImportExcelPage({super.key});

  @override
  State<ImportExcelPage> createState() => _ImportExcelPageState();
}

class _ImportExcelPageState extends State<ImportExcelPage> {
  String? _filePath;
  bool _loading = false;
  String? _message;
  final ExcelImporter _importer = ExcelImporter();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Future<void> _import() async {
    if (_filePath == null) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final count = await _importer.importFile(_filePath!);
      setState(() {
        _message = '✅ Import terminé : $count entrées ajoutées';
      });
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
      appBar: AppBar(title: const Text('Importer un planning Excel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Sélectionner le fichier Excel'),
            ),
            const SizedBox(height: 10),
            Text(
              _filePath ?? 'Aucun fichier sélectionné',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _import,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Importer'),
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
                    color: _message!.contains('✅') ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
