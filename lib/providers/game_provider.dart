import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../data/word_pairs.dart';
import '../models/player.dart';
import '../models/word_pairs.dart';

enum GameState { setup, roleViewing, playing, voting, gameOver }

class GameProvider extends ChangeNotifier {
  final List<Player> _players = [];
  GameState _gameState = GameState.setup;
  WordPair? _currentWordPair;
  int _currentRound = 1;
  final Map<String, String> _votes = {}; // playerId -> votedForPlayerId
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  // Getters
  List<Player> get players => List.unmodifiable(_players);
  List<Player> get alivePlayers =>
      _players.where((p) => !p.isEliminated).toList();
  GameState get gameState => _gameState;
  WordPair? get currentWordPair => _currentWordPair;
  int get currentRound => _currentRound;
  Map<String, String> get votes => Map.unmodifiable(_votes);

  // Player management
  void addPlayer(String name) {
    if (name.trim().isEmpty || _players.length >= 12) return;

    final player = Player(id: _uuid.v4(), name: name.trim());
    _players.add(player);
    notifyListeners();
  }

  void removePlayer(String playerId) {
    _players.removeWhere((player) => player.id == playerId);
    notifyListeners();
  }

  bool canStartGame() {
    return _players.length >= 3 && _players.length <= 12;
  }

  // Game initialization
  void startGame() {
    if (!canStartGame()) return;

    _assignRoles();
    _assignWords();
    _gameState = GameState.roleViewing;
    notifyListeners();
  }

  void _assignRoles() {
    // Shuffle players
    _players.shuffle(_random);

    int randomPlayer = math.Random().nextInt(_players.length);
    _players[randomPlayer] = _players[randomPlayer].copyWith(
      role: PlayerRole.undercover,
    );
    notifyListeners();
  }

  void _assignWords() {
    _currentWordPair = WordPairsData
        .wordPairs[_random.nextInt(WordPairsData.wordPairs.length)];

    for (int i = 0; i < _players.length; i++) {
      final word = _players[i].role == PlayerRole.undercover
          ? _currentWordPair!.undercoverWord
          : _currentWordPair!.citizenWord;

      _players[i] = _players[i].copyWith(word: word);
    }
  }

  // Game flow
  void startPlayingPhase() {
    _gameState = GameState.playing;
    notifyListeners();
  }

  void startVotingPhase() {
    _gameState = GameState.voting;
    _votes.clear();
    // Reset hasVoted for all alive players
    for (int i = 0; i < _players.length; i++) {
      if (!_players[i].isEliminated) {
        _players[i] = _players[i].copyWith(hasVoted: false);
      }
    }
    notifyListeners();
  }

  void castVote(String voterId, String votedForId) {
    if (_gameState != GameState.voting) return;

    _votes[voterId] = votedForId;

    // Mark voter as having voted
    final voterIndex = _players.indexWhere((p) => p.id == voterId);
    if (voterIndex != -1) {
      _players[voterIndex] = _players[voterIndex].copyWith(hasVoted: true);
    }

    notifyListeners();
  }

  void processVotes() {
    if (_votes.isEmpty) return;

    final playersWithMaxVotes = playerWithMaxVotes();

    // Eliminate if no tie, otherwise continue to next round
    if (playersWithMaxVotes.length == 1) {
      final eliminatedId = playersWithMaxVotes.first;
      final playerIndex = _players.indexWhere((p) => p.id == eliminatedId);
      if (playerIndex != -1) {
        _players[playerIndex] = _players[playerIndex].copyWith(
          isEliminated: true,
        );
      }
    }

    _currentRound++;
    _checkWinConditions();
  }

  List<String> playerWithMaxVotes() {
    // Count votes
    final Map<String, int> voteCount = {};
    for (final votedForId in _votes.values) {
      voteCount[votedForId] = (voteCount[votedForId] ?? 0) + 1;
    }

    // Find player(s) with most votes
    final maxVotes = voteCount.values.reduce(math.max);
    return voteCount.entries
        .where((entry) => entry.value == maxVotes)
        .map((entry) => entry.key)
        .toList();
  }

  void eliminatePlayer(String playerId) {
    final playerIndex = _players.indexWhere((p) => p.id == playerId);
    if (playerIndex != -1) {
      _players[playerIndex] = _players[playerIndex].copyWith(
        isEliminated: true,
      );
      _checkWinConditions();
    }
    notifyListeners();
  }

  void _checkWinConditions() {
    final alive = alivePlayers;
    final undercoverAlive = alive.any((p) => p.role == PlayerRole.undercover);

    if (!undercoverAlive) {
      // Citizens win
      _gameState = GameState.gameOver;
    } else if (alive.length <= 2) {
      // Undercover wins
      _gameState = GameState.gameOver;
    } else {
      // Continue game
      _gameState = GameState.playing;
    }

    notifyListeners();
  }

  String getWinner() {
    final alive = alivePlayers;
    final undercoverAlive = alive.any((p) => p.role == PlayerRole.undercover);

    if (!undercoverAlive) {
      return "Citizens Win!";
    } else if (alive.length <= 2) {
      return "Undercover Wins!";
    }
    return "";
  }

  void resetGame() {
    _players.clear();
    _gameState = GameState.setup;
    _currentWordPair = null;
    _currentRound = 1;
    _votes.clear();
    notifyListeners();
  }
}
