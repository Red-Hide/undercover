import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'role_viewing_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      context.read<GameProvider>().addPlayer(name);
      _nameController.clear();
    }
  }

  void _startGame() {
    final gameProvider = context.read<GameProvider>();
    if (gameProvider.canStartGame()) {
      gameProvider.startGame();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RoleViewingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Undercover Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Players (${gameProvider.players.length}/12)',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text('Minimum 3 players required to start'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Player Name',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _addPlayer(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: gameProvider.players.length < 12 ? _addPlayer : null,
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    child: gameProvider.players.isEmpty
                        ? const Center(
                      child: Text('No players added yet'),
                    )
                        : ListView.builder(
                      itemCount: gameProvider.players.length,
                      itemBuilder: (context, index) {
                        final player = gameProvider.players[index];
                        return ListTile(
                          title: Text(player.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => gameProvider.removePlayer(player.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: gameProvider.canStartGame() ? _startGame : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(
                    gameProvider.canStartGame()
                        ? 'Start Game'
                        : 'Need ${3 - gameProvider.players.length} more players',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
