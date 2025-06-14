import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:undercover/screens/player_setup_screen.dart';

import '../models/player.dart';
import '../providers/game_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  void _startVotingPhase() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.startVotingPhase();
  }

  void _castVote(String playerId) {
    final gameProvider = context.read<GameProvider>();
    gameProvider.castVote(
      gameProvider.alivePlayers[gameProvider.votes.length].id,
      playerId,
    );
  }

  Future<void> _showVoteConfirmationDialog(Player player) async {
    final gameProvider = context.read<GameProvider>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm vote'),
          content: Text(
            'Are you sure you want to vote to eliminate ${player.name}?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                _castVote(player.id);
                Navigator.of(context).pop();
                if (gameProvider.votes.length >=
                    gameProvider.alivePlayers.length) {
                  context.read<GameProvider>().processVotes();
                  if (context.read<GameProvider>().gameState ==
                      GameState.gameOver) {
                    _showWinnerDialog();
                  } else if (gameProvider.playerWithMaxVotes().length > 1) {
                    _showTieDialog();
                  } else {
                    _showVotedDialog();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWinnerDialog() async {
    final gameProvider = context.read<GameProvider>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text(gameProvider.getWinner())],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Play Again'),
              onPressed: () {
                final gameProvider = context.read<GameProvider>();
                gameProvider.resetGame();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const PlayerSetupScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTieDialog() async {
    final gameProvider = context.read<GameProvider>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Its a tie!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "There is a tie between the players "),
                    ...(() {
                      final maxVotesPlayerIds = gameProvider
                          .playerWithMaxVotes();
                      return List.generate(maxVotesPlayerIds.length, (index) {
                        final playerId = maxVotesPlayerIds[index];
                        final player = gameProvider.players.firstWhere(
                          (p) => p.id == playerId,
                        );
                        final isLast = index == maxVotesPlayerIds.length - 1;

                        return TextSpan(
                          text: "${player.name}${isLast ? "" : ", "}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        );
                      });
                    })(),
                    TextSpan(text: ". The game will continue."),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showVotedDialog() async {
    final gameProvider = context.read<GameProvider>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Vote Result"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "The player "),
                    TextSpan(
                      text: gameProvider.players
                          .where((player) => !player.isEliminated)
                          .last
                          .name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    TextSpan(text: " was not the undercover!"),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Phase'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Current round : ${gameProvider.currentRound}",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: gameProvider.gameState == GameState.voting
                        ? Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "Discuss and vote for a player to eliminate. Player ",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                TextSpan(
                                  text: gameProvider
                                      .alivePlayers[gameProvider.votes.length]
                                      .name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.fontSize,
                                  ),
                                ),
                                TextSpan(
                                  text: " is voting.",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          )
                        : Text(
                            "Discuss your word in the order displayed with the other players.",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Card(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        itemCount: gameProvider.alivePlayers.length,
                        itemBuilder: (context, index) {
                          final player = gameProvider.alivePlayers[index];
                          return ListTile(
                            title: Text(
                              player.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            trailing: gameProvider.gameState == GameState.voting
                                ? IconButton(
                                    onPressed: () =>
                                        _showVoteConfirmationDialog(player),
                                    icon: Icon(Icons.close),
                                  )
                                : Text(
                                    (index + 1).toString(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (gameProvider.gameState != GameState.voting) ...[
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startVotingPhase,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Text(
                      "Start Voting Phase",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
