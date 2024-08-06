import 'package:electric_meter_app/components/metric_card.dart';
import 'package:electric_meter_app/screens/home/bloc/data_list_bloc/data_list_bloc.dart';
import 'package:electric_meter_app/screens/home/view/pending_metric_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metric_repository/metric_repository.dart';

class DataListScreen extends StatefulWidget {
  const DataListScreen({super.key});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Pending metrics list",
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: BlocBuilder<DataListBloc, DataListState>(
                builder: (context, state) {
                  if (state is DataListLoaded) {
                    // state.metrics.sort((a, b) {
                    //   if (a.completionDate == null ||
                    //       b.completionDate == null) {
                    //     return 0;
                    //   }
                    //   return b.completionDate!.compareTo(a.completionDate!);
                    // });
                    return Text(
                      '/${state.total}',
                      style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    );
                  }
                  return Text(
                    '/0',
                    style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  );
                },
              ),
            )
          ],
        ),
        body:
            BlocBuilder<DataListBloc, DataListState>(builder: (context, state) {
          if (state is DataListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DataListError) {
            return const Center(child: Text('Error, no metrics available'));
          } else if (state is DataListLoaded) {
            final metrics = state.metrics;
            return ListView.builder(
                itemExtent: 200,
                itemCount: metrics.length,
                itemBuilder: (context, index) {
                  final metric = metrics[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PendingMetricDetailScreen(metric: metric)));
                    },
                    child: MetricCard(metric: metric),
                  );
                });
          } else {
            return const Center(child: Text('No data available'));
          }
        }));
  }
}
