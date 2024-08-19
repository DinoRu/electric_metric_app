import 'package:electric_meter_app/components/meter_card.dart';
import 'package:electric_meter_app/screens/home/bloc/meter_bloc/meter_bloc.dart';
import 'package:electric_meter_app/screens/home/view/proccess_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:metric_repository/metric_repository.dart';
import 'package:user_repository/user_repository.dart';

class SearchMeter extends SearchDelegate<List> {
  MeterBloc meterBloc;
  final User user;
  List<Meter> searchMeters = [];
  SearchMeter(this.meterBloc, this.user) {
    searchMeters = List.from(meterBloc.getMeters());
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
    List<Meter> results = searchMeters.where((meter) {
      final searchLower = query.toLowerCase();
      return meter.number!.toLowerCase().contains(searchLower) ||
          (meter.name?.toLowerCase().contains(searchLower) ?? false) ||
          meter.address!.toLowerCase().contains(searchLower);
    }).toList();
    if (results.isEmpty) {
      return const Center(child: Text("счетчик не найден"));
    } else {
      return ListView.builder(
          itemExtent: 200,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final meter = results[index];
            return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProccessDetailScreen(meter: meter)));
                },
                child: MeterCard(meter: meter));
          });
    }
  }
}
