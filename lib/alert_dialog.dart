import 'package:flutter/material.dart';

class Alert_dialog {
  final BuildContext context;
  final String title;
  final String msg;

  Alert_dialog({this.context, this.title, this.msg});

  show() {
    // Create button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(this.context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("${this.title}"),
      content: Text("${this.msg}"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
