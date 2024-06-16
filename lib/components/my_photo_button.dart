import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PictureButton extends StatelessWidget {
  final String title;
  VoidCallback? onPressed;
  PictureButton(this.title, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(title));
  }
}
