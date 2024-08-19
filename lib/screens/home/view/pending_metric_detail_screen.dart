import 'dart:io';

import 'package:flutter/material.dart';
import 'package:metric_repository/metric_repository.dart';

class PendingMetricDetailScreen extends StatelessWidget {
  final Metric metric;
  const PendingMetricDetailScreen({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(metric.number!),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name:\n${metric.name}"),
              const SizedBox(height: 8),
              Text("Number:\n${metric.number}"),
              const SizedBox(height: 8),
              Text("Address:\n${metric.address}"),
              const SizedBox(height: 8),
              Text("Previous reading:\n${metric.previousIndication}"),
              const SizedBox(height: 8),
              Text("Current reading\n${metric.currentIndication}"),
              Text("Comment:\n${metric.comment}"),
              const SizedBox(height: 16),
              const Text('Photo 1\n'),
              if (metric.nearPhotoUrl!.isNotEmpty)
                Image.file(
                  File(metric.nearPhotoUrl!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              const SizedBox(height: 10),
              const Text('Photo 2\n'),
              if (metric.farPhotoUrl!.isNotEmpty)
                Image.file(
                  File(metric.farPhotoUrl!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
