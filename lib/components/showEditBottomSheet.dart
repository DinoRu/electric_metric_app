import 'package:electric_meter_app/components/editBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:metric_repository/metric_repository.dart';

void showEditBottomSheet(BuildContext context, Meter meter) {
  showBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Editbottomsheet(meter: meter),
        );
      });
}
