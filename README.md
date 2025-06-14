# Undercover

A Flutter-based party game where players try to identify the undercover player among them.

## How to Run the App

### Prerequisites
- Flutter SDK (latest stable version recommended)
- Android Studio or VS Code with Flutter plugins
- An emulator or physical device for testing

### Setup Instructions
1. Clone this repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Connect a device or start an emulator
5. Run `flutter run` to launch the app

## App Structure

The app follows a standard Flutter project structure:

```
lib/
├── main.dart          # Entry point of the application
├── models/            # Data models for players and game logic
├── providers/         # State management using providers
└── screens/           # Different game screens (home, game, results)
```

### Key Components

- **Game Provider**: Manages the game state, player information, and voting logic
- **Player Model**: Contains player data including name and elimination status
- **Game Screens**: Different views for various game stages (setup, gameplay, voting)

The app uses the Provider pattern for state management and follows Flutter's widget composition approach for UI construction.