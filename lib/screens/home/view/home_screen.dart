import 'package:electric_meter_app/blocs/auth_bloc.dart';
import 'package:electric_meter_app/components/metric_card.dart';
import 'package:electric_meter_app/screens/home/bloc/metric_bloc/metric_bloc.dart';
import 'package:electric_meter_app/screens/home/bloc/prelevement_bloc/prelevement_bloc.dart';
import 'package:electric_meter_app/screens/home/view/detail_screen.dart';
import 'package:electric_meter_app/screens/home/view/search_metric_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:user_repository/user_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _refreshList(BuildContext context, User user) async {
    final state = context.read<MetricBloc>().state;
    if (state is MetricLoaded && state.metrics.isNotEmpty) {
      context.read<MetricBloc>().add(FetchMetricByUser(user));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = context.read<AuthBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Список задач'), actions: [
        IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: SearchMetric(BlocProvider.of<MetricBloc>(context),
                      authBloc.state.user!));
            },
            icon: const Icon(CupertinoIcons.search)),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: BlocBuilder<MetricBloc, MetricState>(
            builder: (context, state) {
              if (state is MetricLoaded) {
                return Text(
                  '/${state.totalMetrics}',
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
      ]),
      // drawer: const MyDrawer(),
      body: BlocConsumer<MetricBloc, MetricState>(
        listener: (context, state) {
          if (state is MetricLoading) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.loading,
              title: 'Загрузка...',
              text: 'Получение данных',
              // barrierColor: Colors.green,
              barrierDismissible: false,
            );
          } else if (state is MetricError) {
            QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'Oops...',
                text: "Не удалось данные!",
                barrierDismissible: false);
          } else {
            Navigator.of(context, rootNavigator: true).pop(context);
          }
        },
        builder: (context, state) {
          if (state is MetricLoaded) {
            return RefreshIndicator(
              onRefresh: () => _refreshList(context, authBloc.state.user!),
              child: ListView.builder(
                  itemExtent: 200,
                  itemCount: state.metrics.length,
                  itemBuilder: (context, index) {
                    final metric = state.metrics[index];
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                        value: BlocProvider.of<MetricBloc>(
                                            context),
                                        child: BlocProvider(
                                          create: (context) =>
                                              PrelevementBloc(),
                                          child: DetailScreen(metric),
                                        ),
                                      )));
                        },
                        child: MetricCard(metric: metric));
                  }),
            );
          } else {
            return const Center(child: Text('Счетчики недоступны!'));
          }
        },
      ),
    );
  }
}
