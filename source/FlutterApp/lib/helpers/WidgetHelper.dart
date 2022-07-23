import 'package:flutter/material.dart';

class WidgetHelper {
  static showLoadingAlert(BuildContext context, String title, String content) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showAlert(BuildContext context, String title, String content,
      {dynamic onOK}) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (onOK != null) {
              onOK();
            }
          },
          child: const Text("OK"),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static confirmAlert(BuildContext context, String title, String content,
      {dynamic onConfirm}) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (onConfirm != null) {
              onConfirm();
            }
          },
          child: const Text(
            "CEHCK-OUT",
            style: TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "CANCEL",
          ),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
