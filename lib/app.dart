import 'package:electric_meter_app/blocs/auth_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'app_view.dart';

class MyApp extends StatelessWidget {
  final ApiUserRepository userRepository;
  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthBloc>(
        create: (context) => AuthBloc(userRepository: userRepository),
        child: const MyAppView(),
    );
  }
}
