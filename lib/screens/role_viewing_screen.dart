import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import 'game_screen.dart';

class RoleViewingScreen extends StatefulWidget {
  const RoleViewingScreen({super.key});

  @override
  State<RoleViewingScreen> createState() => _RoleViewingScreenState();
}

class _RoleViewingScreenState extends State<RoleViewingScreen> {
  int _currentPlayerIndex = 0;
  bool _showRole = false;

  void _nextPlayer() {
    final gameProvider = context.read<GameProvider>();

    if (_currentPlayerIndex < gameProvider.players.length - 1) {
      setState(() {
        _currentPlayerIndex++;
        _showRole = false;
      });
    } else {
      // All players have seen their roles, start the game
      gameProvider.startPlayingPhase();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GameScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Your Role'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final currentPlayer = gameProvider.players[_currentPlayerIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'Player ${_currentPlayerIndex + 1} of ${gameProvider.players.length}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentPlayer.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        if (!_showRole) ...[
                          const Text(
                            'Tap the button below to see your word.\nMake sure other players are not looking!',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => setState(() => _showRole = true),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Text('Reveal My Word', style: TextStyle(fontSize: 18)),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  'Your word:',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentPlayer.word ?? '',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _nextPlayer,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                            child: Text(
                              _currentPlayerIndex < gameProvider.players.length - 1
                                  ? 'Next Player'
                                  : 'Start Game',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}