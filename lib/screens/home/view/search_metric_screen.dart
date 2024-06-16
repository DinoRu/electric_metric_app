import 'package:electric_meter_app/components/metric_card.dart';
import 'package:electric_meter_app/screens/home/bloc/metric_bloc/metric_bloc.dart';
import 'package:electric_meter_app/screens/home/bloc/prelevement_bloc/prelevement_bloc.dart';
import 'package:electric_meter_app/screens/home/view/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metric_repository/metric_repository.dart';
import 'package:user_repository/user_repository.dart';

class SearchMetric extends SearchDelegate<List> {
  MetricBloc metricBloc;
  final User user;
  List<Metric> searchMetrics = [];
  SearchMetric(this.metricBloc, this.user) {
    searchMetrics = List.from(metricBloc.getMetrics());
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
                          builder: (_) => BlocProvider.value(
                                value: metricBloc,
                                child: BlocProvider(
                                  create: (context) => PrelevementBloc(),
                                  child: DetailScreen(metric),
                                ),
                              )));
                },
                child: MetricCard(metric: metric));
          });
    }
  }
}
