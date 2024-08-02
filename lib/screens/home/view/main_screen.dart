import 'package:electric_meter_app/blocs/auth_bloc.dart';
import 'package:electric_meter_app/screens/home/bloc/meter_bloc/meter_bloc.dart';
import 'package:electric_meter_app/screens/home/bloc/pending_bloc/pending_bloc.dart';
import 'package:electric_meter_app/screens/home/view/home_screen.dart';
import 'package:electric_meter_app/screens/home/view/pending_metric_screen.dart';
import 'package:electric_meter_app/screens/home/view/proccessed_meter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    PendingMetricScreen(),
    ProccessedMeterScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectIndex = index;
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    switch (index) {
      case 1:
        context.read<PendingBloc>().add(FetchPendingMeterEvent());
        break;

      case 2:
        final user = context.read<AuthBloc>().state.user;
        context.read<MeterBloc>().add(GetMeterEvent(user: user!));
    }

    // if (index == 2) {
    //   final user = context.read<AuthBloc>().state.user;
    //   context.read<MeterBloc>().add(GetMeterEvent(user: user!));
    // }
  }

  void _onSettingTapped() {
    //Go to Setting screen
  }

  void _onLogoutTapped() {
    //Implement the logout logic here;
    //Navigate to login screen
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.blue.shade50,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Column(
          children: [
            DrawerHeader(
                child: Image.asset('assets/icons/home_logo.png', width: 200)),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Список задач'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Ожиданые задач'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.done),
              title: const Text('Завершенные задачи'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: _onSettingTapped,
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Выход'),
              onTap: _onLogoutTapped,
            ),
            const SizedBox(height: 50)
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.donut_large), label: 'Выполняется'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending),
            label: "В ожидании",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Выполнено',
          ),
        ],
        currentIndex: _selectIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
