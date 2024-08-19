import 'dart:developer';

import 'package:electric_meter_app/components/showEditBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:metric_repository/metric_repository.dart';

// ignore: must_be_immutable
class ProccessDetailScreen extends StatelessWidget {
  final Meter meter;
  ProccessDetailScreen({super.key, required this.meter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${meter.number}'),
        actions: [
          IconButton(
              onPressed: () {
                log('Update bottom sheet');
              },
              icon: const Icon(Icons.edit, color: Colors.grey)),
          const SizedBox(width: 10)
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Исполнитель", meter.implementer),
              divider,
              _buildDetailRow("Код счетчика", meter.number),
              divider,
              _buildDetailRow("Наименование", meter.name),
              divider,
              _buildDetailRow(
                  "Предыдущие показания", meter.previousIndication.toString()),
              divider,
              _buildDetailRow(
                  "Текущие показания", meter.currentIndication.toString()),
              divider,
              _buildDetailRow("Комментарий", meter.comment),
              divider,
              _pictureBox(meter.farPhotoUrl ?? ''),
              divider,
              _pictureBox(meter.nearPhotoUrl ?? ''),
              divider,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String fieldName, String? fieldValue) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
            height: 60,
            margin: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fieldName),
                const SizedBox(height: 10),
                Expanded(
                  child: Text(fieldValue ?? 'N/A', style: medium),
                ),
              ],
            )));
  }

  Widget _pictureBox(String path) {
    return Image.network(
      path,
      width: double.maxFinite,
      height: 200,
      fit: BoxFit.cover,
    );
  }

  TextStyle medium = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  Divider divider = Divider(color: Colors.green[300]);
}
