import 'package:electric_meter_app/blocs/auth_bloc.dart';
import 'package:electric_meter_app/screens/auth/bloc/sign_in_bloc/sign_in_bloc.dart';
import 'package:electric_meter_app/screens/auth/view/welcome_screen.dart';
import 'package:electric_meter_app/screens/home/bloc/data_list_bloc/data_list_bloc.dart';
import 'package:electric_meter_app/screens/home/bloc/meter_bloc/meter_bloc.dart';
import 'package:electric_meter_app/screens/home/bloc/metric_bloc/metric_bloc.dart';
import 'package:electric_meter_app/screens/home/bloc/search_bloc/search_bloc.dart';
// import 'package:electric_meter_app/screens/home/view/home_screen.dart';
import 'package:electric_meter_app/screens/home/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metric_repository/metric_repository.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dagenergi metric app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          inputDecorationTheme:
              const InputDecorationTheme(border: InputBorder.none),
          textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.light(
            surface: Colors.grey.shade100,
            primary: Colors.blue,
          )),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return MultiBlocProvider(providers: [
              BlocProvider(
                create: (context) => SignInBloc(
                    context.read<AuthBloc>().userRepository,
                    context.read<AuthBloc>()),
              ),
              BlocProvider(
                create: (context) => MetricBloc(MetricRepository())
                  ..add(FetchMetricByUser(state.user!)),
                // child: const HomeScreen(),
              ),
              BlocProvider(
                create: (context) => SearchBloc(MetricRepository()),
                // child: const HomeScreen(),
              ),
              BlocProvider(create: (context) => MeterBloc(MetricRepository())),
              BlocProvider(create: (context) => DataListBloc())
            ], child: const MainScreen());
          } else {
            return const WelcomeScreen();
          }
        },
      ),
    );
  }
}
