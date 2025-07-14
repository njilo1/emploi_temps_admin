import 'package:flutter/material.dart';

class ConfirmationDialog {
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String viewButtonText,
    required String addButtonText,
    required VoidCallback onViewList,
    required VoidCallback onAddNew,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Enregistrement effectué avec succès.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAddNew();
            },
            child: Text(addButtonText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onViewList();
            },
            child: Text(viewButtonText),
          ),
        ],
      ),
    );
  }
}
