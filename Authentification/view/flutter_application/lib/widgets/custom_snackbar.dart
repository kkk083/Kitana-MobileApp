import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(BuildContext context, {required String message, required bool isSuccess}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(isSuccess ? Icons.check_circle : Icons.error, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message) => show(context, message: message, isSuccess: true);
  static void error(BuildContext context, String message) => show(context, message: message, isSuccess: false);
}
