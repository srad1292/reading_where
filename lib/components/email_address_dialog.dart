import 'package:flutter/material.dart';


Future<String?> showEmailAddressDialog({required BuildContext context}) async {
  Widget dialog = passwordDialog(context);
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
      barrierDismissible: true
  )
      .then((value) {
    return value;
  });
}


Widget doneButton(BuildContext dialogContext, BuildContext parentContext, StateSetter dialogSetState, TextEditingController input) {
  return TextButton(
    child: const Text(
      "Done",
    ),
    onPressed: () {
      if(input.text.trim().isEmpty) { return; }
      Navigator.of(parentContext).pop(input.text.trim());
    },
  );
}

Widget cancelButton(BuildContext parentContext) {
  return TextButton(
    child: const Text(
      "Cancel",
    ),
    onPressed: () {
      Navigator.of(parentContext).pop('');
    },
  );
}



Widget passwordDialog(BuildContext parentContext) {
  TextEditingController emailController = new TextEditingController();

  return StatefulBuilder(
      builder: (dialogContext, dialogSetState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Enter Recipient Email",
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: "Type Email",
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [cancelButton(parentContext), doneButton(dialogContext, parentContext, dialogSetState, emailController)],
        );
      }
  );
}