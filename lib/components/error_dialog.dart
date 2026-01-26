import 'package:flutter/material.dart';

Future<void> showErrorDialog({required BuildContext context, required String body}) async {
  Widget dialog = _errorDialog(context, body);
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
      barrierDismissible: true
  )
      .then((value) { return;});
}

Widget confirmButton(BuildContext context) {
  return TextButton(
    child: const Text(
      "Ok",
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
}

Widget _errorDialog(BuildContext context, String body) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    // backgroundColor: stmGradientEnd,
    title: const Text(
      "Error",
    ),
    content: Text(body),
    actions: [confirmButton(context)],
  );
}