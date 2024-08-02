import 'package:electric_meter_app/screens/home/bloc/pending_bloc/pending_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingMetricScreen extends StatefulWidget {
  const PendingMetricScreen({super.key});

  @override
  State<PendingMetricScreen> createState() => _PendingMetricScreenState();
}

class _PendingMetricScreenState extends State<PendingMetricScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("В Ожидании"),
        ),
        body: BlocBuilder<PendingBloc, PendingState>(
          builder: (context, state) {
            if (state is PendingLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.grey));
            } else if (state is PendingLoaded) {
              return ListView.builder(
                  itemCount: state.pendingMeters.length,
                  itemBuilder: (cxt, index) {
                    var meter = state.pendingMeters[index];
                    return ListTile(
                      title: Text(meter.meterName),
                      subtitle: Text("${meter.currentIndication}"),
                    );
                  });
            } else if (state is PendingEmpty) {
              return const Center(child: Text("No pending meters found"));
            } else if (state is PendingError) {
              return Center(child: Text("Error: ${state.error}"));
            } else {
              return const Center(child: Text('Unknown state'));
            }
          },
        ));
  }
}
