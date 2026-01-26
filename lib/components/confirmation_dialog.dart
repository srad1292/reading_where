import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog({required BuildContext context, required String body}) async {
  Widget dialog = _confirmationDialog(context, body);
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
      barrierDismissible: false
  )
      .then((value) {
    return value == true;
  });
}

Widget cancelButton(BuildContext context) {
  return TextButton(
    child: const Text(
      "Cancel",
      style: TextStyle(
        color: Colors.redAccent,
      ),
    ),
    onPressed: () {
      Navigator.of(context).pop(false);
    },
  );
}

Widget confirmButton(BuildContext context) {
  return TextButton(
    child: const Text(
      "Confirm",
    ),
    onPressed: () {
      Navigator.of(context).pop(true);
    },
  );
}

Widget _confirmationDialog(BuildContext context, String body) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    title: const Text(
      "Confirmation",
    ),
    content: Text(body),
    actions: [cancelButton(context), confirmButton(context)],
  );
}