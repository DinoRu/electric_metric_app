// import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:metric_repository/metric_repository.dart';

class Editbottomsheet extends StatefulWidget {
  final Meter meter;
  const Editbottomsheet({super.key, required this.meter});

  @override
  State<Editbottomsheet> createState() => _EditbottomsheetState();
}

class _EditbottomsheetState extends State<Editbottomsheet> {
  final _formKey = GlobalKey<FormState>();
  late String _currentIndication;
  late String _previousIndication;
  late String _comment;
  // File? _farPhoto;
  // File? _nearPhoto;

  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentIndication = widget.meter.currentIndication.toString();
    _previousIndication = widget.meter.previousIndication.toString();
    _comment = widget.meter.comment ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modifier les détails du compteur',
                style: Theme.of(context).textTheme.bodyMedium),
            TextFormField(
              initialValue: _previousIndication,
              decoration: const InputDecoration(
                labelText: "Ancienne valeur",
              ),
              onChanged: (value) => _previousIndication = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'ancienne indication';
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: _currentIndication,
              decoration:
                  const InputDecoration(labelText: "Current indication"),
              onChanged: (value) => _currentIndication = value,
              validator: (value) {
                if (value == null) {
                  return "Veuiller renseigner ce champs";
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: _comment,
              decoration: const InputDecoration(labelText: 'Comments'),
              onChanged: (value) => _comment = value,
            )
          ],
        ));
  }
}
