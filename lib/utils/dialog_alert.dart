import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String title,
  String message,
) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Center(child: Text(title)),
      content: SizedBox(
        width: 200.0,
        height: 100.0,
        child: Center(child: Text(message)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
