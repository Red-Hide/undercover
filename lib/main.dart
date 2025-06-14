import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/player_setup_screen.dart';
import 'providers/game_provider.dart';

void main() {
  runApp(const UndercoverApp());
}

class UndercoverApp extends StatelessWidget {
  const UndercoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'Undercover Game',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const PlayerSetupScreen(),
      ),
    );
  }
}