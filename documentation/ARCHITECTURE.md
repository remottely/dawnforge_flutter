# 🏗️ Darkness Dungeon - Architecture Documentation

This document provides a comprehensive overview of the Darkness Dungeon architecture, following CLAUDE.md standards for Flutter game development.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Layer Structure](#layer-structure)
- [Core Systems](#core-systems)
- [Data Flow](#data-flow)
- [Design Patterns](#design-patterns)
- [Development Guidelines](#development-guidelines)

## 🎯 Architecture Overview

Darkness Dungeon follows a **layered architecture** pattern with clear separation of concerns, designed for maintainability and scalability in Flutter game development.

```
lib/
├── gameplay/           # Game Logic Layer
│   ├── core/          # Core game systems
│   ├── player/        # Player entities
│   ├── enemies/       # Enemy entities
│   ├── npc/           # Non-player characters
│   ├── decoration/    # Interactive objects
│   └── hud/           # Game UI components
├── presentation/       # Presentation Layer
│   ├── screens/       # Application screens
│   └── design_system/ # Reusable UI components
└── main.dart          # Application entry point
```

## 🏛️ Layer Structure

### 1. Gameplay Layer (`/lib/gameplay/`)

The core game logic layer, built on top of the Bonfire game engine.

#### Core Systems (`/lib/gameplay/core/`)

- **Constants**: Game configuration values
- **Managers**: Game state, UI, audio, and map management
- **Models**: Data structures and game entities
- **Utils**: Helper functions and utilities

#### Game Entities

- **Player** (`/lib/gameplay/player/`): PlayerCharacter character with combat and movement
- **Enemies** (`/lib/gameplay/enemies/`): AI-controlled opponents (Goblin, Imp, MiniBoss)
- **NPCs** (`/lib/gameplay/npc/`): Interactive characters (Wizard, Kid)
- **Decorations** (`/lib/gameplay/decoration/`): Interactive objects (Potions, Keys, Doors, Spikes, Torches)

#### HUD Components (`/lib/gameplay/hud/`)

- **GameplayHUD**: Main game interface
- **PlayerVitalStatsHUD**: Health and stamina bars

### 2. Presentation Layer (`/lib/presentation/`)

UI components and screens following Flutter best practices.

#### Screens (`/lib/presentation/screens/`)

- **MenuScreen**: Main menu with settings and navigation
- **Gameplay**: Main game screen wrapper

#### Design System (`/lib/presentation/design_system/`)

```
design_system/
└── components/
    └── atoms/
        ├── app_styled_text.dart      # Consistent text styling
        ├── app_styled_button.dart    # Button components
        ├── app_styled_dialog.dart    # Dialog components
        ├── app_radio_button.dart     # Radio button components
        └── app_animated_sprite_widget.dart # Animated sprites
```

## ⚙️ Core Systems

### Manager Pattern

All core systems follow the Manager pattern for centralized control:

#### GameplayStateManager

```dart
/// Responsible for managing overall game state and lifecycle
/// Following Flutter naming conventions for game state systems
///
/// This class handles:
/// - Game over detection and handling
/// - State transitions and validation
/// - Game restart and cleanup operations
class GameplayStateManager extends GameComponent {
  // Implementation follows CLAUDE.md patterns
}
```

#### GameplayAudioManager

```dart
/// Responsible for managing all game audio including background music and sound effects
/// Following Flutter naming conventions for audio management systems
///
/// This class handles:
/// - Background music playback and transitions
/// - Sound effect triggering and management
/// - Audio resource cleanup
class GameplayAudioManager {
  // Static methods for global audio control
}
```

#### GameplayMapManager

```dart
/// Responsible for managing map navigation and transitions between game areas
/// Following Flutter naming conventions for map management systems
///
/// This class handles:
/// - Map loading and caching
/// - Player position tracking across maps
/// - Map transition logic
class GameplayMapManager {
  // Static methods for map operations
}
```

#### GameplayUIManager

```dart
/// Responsible for managing game UI dialogs and overlays
/// Following Flutter naming conventions for UI management systems
///
/// This class handles:
/// - Game over dialog display
/// - Victory screen management
/// - Navigation to main menu
class GameplayUIManager {
  // Static methods for UI operations
}
```

## 🔄 Data Flow

### Game Initialization Flow

```
main.dart
    ↓
MenuScreen (Presentation Layer)
    ↓
Gameplay Screen (Presentation Layer)
    ↓
BonfireWidget (Gameplay Layer)
    ↓
GameplayStateManager + Entities + HUD
```

### State Management Flow

```
User Input
    ↓
Player/Controller
    ↓
Game Entity State Changes
    ↓
Manager Updates
    ↓
HUD/UI Updates
    ↓
Screen Rendering
```

### Audio Management Flow

```
Game Events
    ↓
GameplayAudioManager
    ↓
Audio Resource Management
    ↓
Background Music / SFX Playback
```

## 🎨 Design Patterns

### 1. Manager Pattern

- Centralized control for game systems
- Static methods for global access
- Clear separation of concerns

### 2. Factory Pattern

- Component creation through factory methods
- Consistent object instantiation
- Simplified configuration management

### 3. Component Pattern (Bonfire Integration)

- Entity-Component-System architecture
- Modular game entity behavior
- Reusable component composition

### 4. Atomic Design (UI Components)

- **Atoms**: Basic UI components (buttons, text, inputs)
- **Molecules**: Composed UI components (forms, cards)
- **Organisms**: Complex UI sections (headers, sidebars)

## 📊 Constants and Configuration

### Naming Convention

All constants follow the `k` prefix pattern:

```dart
// UI Constants
static const double kDefaultSize = 24.0;
static const Color kPrimaryColor = Colors.blue;
static const Duration kAnimationDuration = Duration(milliseconds: 300);

// Game Constants
static const double kPlayerSpeed = 80.0;
static const int kMaxEnemies = 10;
static const String kPlayerAssetPath = 'player/knight.png';
```

### Constant Organization

- **GameplayConstants**: Core game mechanics
- **GameplayUIConstants**: UI-specific values
- **GameplayMapConstants**: Map and world configuration
- **Component-specific constants**: Within each class

## 🔧 Development Guidelines

### Class Structure (CLAUDE.md Standard)

```dart
class ExampleManager extends GameComponent {
  // 1. Constants (grouped by type)
  static const String kEventName = 'example_event';
  static const int kDefaultValue = 100;

  // 2. Private instance variables
  bool _isActive = false;
  Timer? _updateTimer;

  // 3. Public methods
  @override
  void update(double dt) { }
  void triggerEvent() { }

  // 4. Private helper methods (grouped by functionality)
  void _processUpdates() { }
  void _handleEvents() { }
  void _cleanup() { }

  // 5. Utility methods
  bool _isValidState() { }
  void _logEvent(String event) { }
}
```

### Documentation Standards

````dart
/// [ClassName] responsible for [main responsibility]
/// Following Flutter naming conventions for [system type] systems
///
/// This class handles:
/// - [Responsibility 1]
/// - [Responsibility 2]
/// - [Responsibility 3]
///
/// Usage example:
/// ```dart
/// final manager = ExampleManager();
/// manager.initialize();
/// ```
class ExampleManager {
  // Implementation
}
````

### Factory Method Pattern

```dart
/// Creates a [ComponentName] with default configuration
static ComponentName createDefault() {
  return ComponentName(
    size: kDefaultSize,
    color: kDefaultColor,
  );
}

/// Creates a [ComponentName] with large size variant
static ComponentName createLarge() {
  return ComponentName(
    size: kLargeSize,
    color: kDefaultColor,
  );
}
```

## 🧪 Testing Strategy

### Unit Tests

- Manager functionality testing
- Component behavior validation
- Utility function verification

### Integration Tests

- Screen navigation flows
- Game state transitions
- Audio system integration

### Widget Tests

- UI component rendering
- User interaction handling
- Design system consistency

## 📈 Performance Considerations

### Asset Management

- Sprite caching and preloading
- Audio resource optimization
- Memory management for large maps

### Game Loop Optimization

- Efficient collision detection
- Optimized rendering pipelines
- Background processing for non-critical operations

### Mobile Performance

- Battery usage optimization
- Frame rate stability
- Memory footprint management

## 🚀 Future Architecture Improvements

### Scalability Enhancements

- Plugin-based entity system
- Modular map loading
- Dynamic content streaming

### Code Quality

- Automated code analysis
- Performance profiling integration
- Enhanced error handling and logging

### Developer Experience

- Hot reload optimization
- Debug tooling improvements
- Automated testing pipelines

---

## 📝 Maintenance Notes

This architecture documentation should be updated when:

- New managers or systems are added
- Major refactoring occurs
- Design patterns change
- Performance optimizations are implemented

For questions or clarifications about the architecture, refer to the CLAUDE.md standards or create an issue in the project repository.

**Last Updated**: October 2025
**Architecture Version**: 2.0 (Post-CLAUDE.md Refactoring)
