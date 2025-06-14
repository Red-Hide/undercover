enum PlayerRole { citizen, undercover }

class Player {
  final String id;
  final String name;
  PlayerRole? role;
  String? word;
  bool isEliminated;
  bool hasVoted;

  Player({
    required this.id,
    required this.name,
    this.role,
    this.word,
    this.isEliminated = false,
    this.hasVoted = false,
  });

  Player copyWith({
    String? id,
    String? name,
    PlayerRole? role,
    String? word,
    bool? isEliminated,
    bool? hasVoted,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      word: word ?? this.word,
      isEliminated: isEliminated ?? this.isEliminated,
      hasVoted: hasVoted ?? this.hasVoted,
    );
  }
}
