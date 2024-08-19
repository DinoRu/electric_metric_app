import 'package:electric_meter_app/components/metric_card.dart';
import 'package:electric_meter_app/screens/home/bloc/data_list_bloc/data_list_bloc.dart';
import 'package:electric_meter_app/screens/home/view/pending_metric_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:metric_repository/metric_repository.dart';

class PendingSearchScreen extends SearchDelegate<List> {
  DataListBloc dataBloc;
  List<Metric> searchMetrics = [];
  PendingSearchScreen(this.dataBloc) {
    searchMetrics = List.from(dataBloc.getPendingMetrics());
  }

  @override
  String? get searchFieldLabel => "Код, Наименование, Адрес счетчик";

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        close(context, []);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Metric> results = searchMetrics.where((metric) {
      final searchLower = query.toLowerCase();
      return metric.number!.toLowerCase().contains(searchLower) ||
          (metric.name?.toLowerCase().contains(searchLower) ?? false) ||
          metric.address!.toLowerCase().contains(searchLower);
    }).toList();
    if (results.isEmpty) {
      return const Center(child: Text("счетчик не найден"));
    } else {
      return ListView.builder(
          itemExtent: 200,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final metric = results[index];
            return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PendingMetricDetailScreen(metric: metric)));
                },
                child: MetricCard(metric: metric));
          });
    }
  }
}
