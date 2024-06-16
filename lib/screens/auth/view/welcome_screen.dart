import 'package:electric_meter_app/blocs/auth_bloc.dart';
import 'package:electric_meter_app/screens/auth/view/signi_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/sign_in_bloc/sign_in_bloc.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocProvider<SignInBloc>(
                create: (context) => SignInBloc(
                    context.read<AuthBloc>().userRepository,
                    context.read<AuthBloc>()),
                child: const SignInScreen(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
