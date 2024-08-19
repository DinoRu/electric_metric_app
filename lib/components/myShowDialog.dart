import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
            content: Center(child: CircularProgressIndicator()));
      });
}
