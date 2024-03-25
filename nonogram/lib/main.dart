import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nonogram/bloc/app_bloc.dart';
import 'package:nonogram/pages/main_menu.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nonogram',
        home: MainMenu(),
      ),
    );
  }
}
