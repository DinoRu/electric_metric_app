import 'package:electric_meter_app/blocs/auth_bloc.dart';
import 'package:electric_meter_app/components/meter_card.dart';
import 'package:electric_meter_app/screens/home/bloc/meter_bloc/meter_bloc.dart';
import 'package:electric_meter_app/screens/home/view/meter_search_screen.dart';
import 'package:electric_meter_app/screens/home/view/proccess_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

class ProccessedMeterScreen extends StatelessWidget {
  const ProccessedMeterScreen({super.key});

  Future<void> _refreshList(BuildContext context, User user) async {
    final state = context.read<MeterBloc>().state;
    if (state is MeterLoaded && state.meters.isNotEmpty) {
      context.read<MeterBloc>().add(GetMeterEvent(user: user));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = context.read<AuthBloc>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Завершенные задачи"),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: SearchMeter(BlocProvider.of<MeterBloc>(context),
                        authBloc.state.user!));
              },
              icon: const Icon(CupertinoIcons.search)),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: BlocBuilder<MeterBloc, MeterState>(
              builder: (context, state) {
                if (state is MeterLoaded) {
                  state.meters.sort((a, b) {
                    if (a.completionDate == null || b.completionDate == null) {
                      return 0;
                    }
                    return b.completionDate!.compareTo(a.completionDate!);
                  });
                  return Text(
                    '/${state.totalMeters}',
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
      body: BlocBuilder<MeterBloc, MeterState>(builder: (context, state) {
        if (state is MeterLoaded) {
          if (state.meters.isEmpty) {
            return const Center(
              child: Text(
                'Обходы не загружены',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => _refreshList(context, authBloc.state.user!),
            child: ListView.builder(
                itemExtent: 200,
                itemCount: state.meters.length,
                itemBuilder: (context, index) {
                  final meter = state.meters[index];
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProccessDetailScreen(meter: meter)));
                      },
                      child: MeterCard(meter: meter));
                }),
          );
        } else if (state is MeterLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('Счетчики недоступны!'));
        }
      }),
    );
  }
}
