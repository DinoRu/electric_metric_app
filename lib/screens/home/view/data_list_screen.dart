import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:electric_meter_app/components/mySnackBar.dart';
import 'package:electric_meter_app/components/sync_card.dart';
import 'package:electric_meter_app/screens/home/bloc/data_list_bloc/data_list_bloc.dart';
import 'package:electric_meter_app/screens/home/bloc/sync_bloc/sync_bloc.dart';
import 'package:electric_meter_app/screens/home/view/pending_metric_detail_screen.dart';
import 'package:electric_meter_app/screens/home/view/pending_search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:metric_repository/metric_repository.dart';

class DataListScreen extends StatefulWidget {
  const DataListScreen({super.key});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _uploadAllMetrics(BuildContext context) async {
    final result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      showSnackBar(context, "Интернет недоступен", Colors.red);
      return;
    }

    //Check if there are pending metrics
    final state = context.read<DataListBloc>().state;
    if (state is DataListLoaded && state.metrics.isEmpty) {
      showSnackBar(context, "Нет Обходов", Colors.orange);
      return;
    }
    //Process sync
    context.read<SyncBloc>().add(SyncAllMetricsEvent());
    context.read<DataListBloc>().add(GetPendingMetricEvent());
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Отправка на сервер",
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: PendingSearchScreen(
                            BlocProvider.of<DataListBloc>(context)));
                  },
                  icon: const Icon(CupertinoIcons.search)),
              const SizedBox(width: 10),
              IconButton(
                  onPressed: () => _uploadAllMetrics(context),
                  icon: const Icon(
                    BoxIcons.bx_upload,
                    size: 34,
                  )),
              const SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BlocBuilder<DataListBloc, DataListState>(
                  builder: (context, state) {
                    if (state is DataListLoaded) {
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
          body: BlocListener<SyncBloc, SyncState>(
            listener: (context, state) {
              final progressHUD = ProgressHUD.of(context);
              if (state is SyncLoading) {
                progressHUD?.show();
              } else if (state is SyncSuccess) {
                progressHUD?.dismiss();
                showSnackBar(
                    context, 'Задание выполнено успешно!', Colors.greenAccent);
                context.read<DataListBloc>().add(GetPendingMetricEvent());
              } else if (state is SyncError) {
                progressHUD?.dismiss();
                log("Нет обходов");
              }
            },
            child: BlocBuilder<DataListBloc, DataListState>(
                builder: (context, state) {
              if (state is DataListLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DataListError) {
                return const Center(child: Text('Error, no metrics available'));
              } else if (state is DataListLoaded) {
                final metrics = state.metrics;
                if (metrics.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нет обходов',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }
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
                                      PendingMetricDetailScreen(
                                          metric: metric)));
                        },
                        child: SyncCard(metric: metric),
                      );
                    });
              } else {
                return const Center(child: Text('No data available'));
              }
            }),
          )),
    );
  }
}
