import 'dart:ui';

import 'package:electric_meter_app/screens/home/bloc/sync_bloc/sync_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metric_repository/metric_repository.dart';

// ignore: must_be_immutable
class SyncCard extends StatelessWidget {
  final Metric metric;
  SyncCard({required this.metric, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(metric.number ?? 'N/A', style: large),
              IconButton(
                  onPressed: () {
                    print("Send data to server");
                    context.read<SyncBloc>().add(SendDataEvent(metric));
                  },
                  icon: const Icon(
                    CupertinoIcons.cloud_upload,
                  ))
            ],
          ),
          const SizedBox(height: 10),
          Flexible(
              child: Text(
            metric.name ?? 'N/A',
            style: medium,
            maxLines: 2,
          )),
          const SizedBox(height: 10),
          Expanded(
            child: Text(metric.address ?? 'N/A',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  TextStyle medium = const TextStyle(fontSize: 18);
  TextStyle large = const TextStyle(fontWeight: FontWeight.w500, fontSize: 24);
}
