# 🎨 Design System - Usage Examples

This document provides comprehensive usage examples for all design system components following CLAUDE.md patterns.

## 📋 Table of Contents

- [AppStyledText](#appstyledtext)
- [AppStyledButton](#appstyledbutton)
- [AppStyledDialog](#appstyleddialog)
- [AppRadioButton](#appradiobutton)
- [DFAnimatedSpriteWidget](#appanimatedspritewidget)

## 📝 AppStyledText

Consistent text styling throughout the application with multiple size variants.

### Basic Usage

```dart
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_styled_text.dart';

// Default text
AppStyledText(text: 'Welcome to Darkness Dungeon')

// Custom styling
AppStyledText(
  text: 'Custom Text',
  fontSize: 24.0,
  color: Colors.yellow,
  textAlign: TextAlign.center,
)
```

### Factory Constructors

```dart
// Large text for headings
AppStyledText.large(
  text: 'Game Title',
  textAlign: TextAlign.center,
)

// Small text for secondary content
AppStyledText.small(
  text: 'Subtitle or description',
  color: Colors.grey,
)
```

### Constants Available

```dart
// Font sizes
AppStyledText.kNormalFontSize = 20.0
AppStyledText.kLargeFontSize = 32.0
AppStyledText.kSmallFontSize = 18.0

// Colors and fonts
AppStyledText.kDefaultColor = Colors.white
AppStyledText.kFontFamily = 'Normal'
```

## 🔘 AppStyledButton

Styled buttons with consistent theming and multiple variants.

### Basic Usage

```dart
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_styled_button.dart';

// Default button
AppStyledButton(
  text: 'Click Me',
  onPressed: () {
    print('Button pressed!');
  },
)

// Custom styling
AppStyledButton(
  text: 'Custom Button',
  onPressed: () => Navigator.pop(context),
  backgroundColor: Colors.red,
  fontSize: 18.0,
)
```

### Factory Constructors

```dart
// Primary button with game theme colors
AppStyledButton.primary(
  text: 'Start Game',
  onPressed: () => Navigator.pushNamed(context, '/gameplay'),
)

// Transparent button for secondary actions
AppStyledButton.transparent(
  text: 'Settings',
  onPressed: () => Navigator.pushNamed(context, '/settings'),
)
```

### Real-world Examples

```dart
// Menu screen navigation
Column(
  children: [
    AppStyledButton.primary(
      text: 'Play',
      onPressed: _navigateToGameplay,
    ),
    SizedBox(height: 16),
    AppStyledButton.transparent(
      text: 'Controls',
      onPressed: _navigateToControls,
    ),
  ],
)

// Dialog actions
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    AppStyledButton.transparent(
      text: 'Cancel',
      onPressed: () => Navigator.pop(context),
    ),
    AppStyledButton.primary(
      text: 'Retry',
      onPressed: _restartGame,
    ),
  ],
)
```

### Constants Available

```dart
AppStyledButton.kFontFamily = 'Normal'
AppStyledButton.kNormalFontSize = 20.0
AppStyledButton.kButtonFontSize = 16.0
AppStyledButton.kDefaultTextColor = Colors.white
AppStyledButton.kPrimaryBackgroundColor = Color.fromARGB(255, 118, 82, 78)
AppStyledButton.kButtonBorderRadius = 4.0
```

## 📋 AppStyledDialog

Consistent dialog styling with customizable backgrounds.

### Basic Usage

```dart
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_styled_dialog.dart';

// Default transparent dialog
AppStyledDialog(
  children: [
    AppStyledText.large(text: 'Game Over'),
    SizedBox(height: 20),
    AppStyledButton.primary(
      text: 'Try Again',
      onPressed: () => Navigator.pop(context),
    ),
  ],
)
```

### Factory Constructors

```dart
// Dialog with custom background
AppStyledDialog.withBackground(
  backgroundColor: Colors.black54,
  children: [
    Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.brown.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          AppStyledText.large(text: 'Victory!'),
          AppStyledText(text: 'You completed the dungeon!'),
        ],
      ),
    ),
  ],
)
```

### Complete Dialog Examples

```dart
// Game Over Dialog
void showGameOverDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AppStyledDialog.withBackground(
      backgroundColor: Colors.black87,
      children: [
        Container(
          padding: EdgeInsets.all(24),
          margin: EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.brown.shade900,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.brown.shade700, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppStyledText.large(text: 'Game Over'),
              SizedBox(height: 16),
              AppStyledText(
                text: 'The darkness has consumed you...',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppStyledButton.transparent(
                    text: 'Main Menu',
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  ),
                  AppStyledButton.primary(
                    text: 'Try Again',
                    onPressed: () {
                      Navigator.pop(context);
                      _restartGame();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

## 🔘 AppRadioButton

Generic radio button component with label support.

### Basic Usage

```dart
import 'package:darkness_dungeon/presentation/design_system/components/atoms/app_radio_button.dart';

String selectedControl = 'joystick';

AppRadioButton<String>(
  value: 'joystick',
  group: selectedControl,
  label: 'Touch Controls',
  onChange: (value) {
    setState(() {
      selectedControl = value;
    });
  },
)
```

### Complete Form Example

```dart
class ControlsSettingsWidget extends StatefulWidget {
  @override
  _ControlsSettingsWidgetState createState() => _ControlsSettingsWidgetState();
}

class _ControlsSettingsWidgetState extends State<ControlsSettingsWidget> {
  String _selectedControl = 'joystick';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppStyledText.large(text: 'Control Settings'),
        SizedBox(height: 20),

        AppRadioButton<String>(
          value: 'joystick',
          group: _selectedControl,
          label: 'Touch Controls (Mobile)',
          onChange: (value) {
            setState(() {
              _selectedControl = value;
              Gameplay.useJoystickControls = true;
            });
          },
        ),

        SizedBox(height: 12),

        AppRadioButton<String>(
          value: 'keyboard',
          group: _selectedControl,
          label: 'Keyboard Controls (Desktop)',
          onChange: (value) {
            setState(() {
              _selectedControl = value;
              Gameplay.useJoystickControls = false;
            });
          },
        ),
      ],
    );
  }
}
```

### Generic Type Usage

```dart
// Enum-based radio buttons
enum GameDifficulty { easy, normal, hard }

GameDifficulty selectedDifficulty = GameDifficulty.normal;

Column(
  children: GameDifficulty.values.map((difficulty) {
    return AppRadioButton<GameDifficulty>(
      value: difficulty,
      group: selectedDifficulty,
      label: difficulty.toString().split('.').last.toUpperCase(),
      onChange: (value) {
        setState(() {
          selectedDifficulty = value;
        });
      },
    );
  }).toList(),
)
```

### Constants Available

```dart
AppRadioButton.kBorderColor = Colors.white
AppRadioButton.kTextColor = Colors.white
AppRadioButton.kBorderWidth = 2.0
AppRadioButton.kIndicatorSize = 8.0
AppRadioButton.kIndicatorMargin = 2.0
AppRadioButton.kLabelSpacing = 10.0
```

## 🎮 DFAnimatedSpriteWidget

Display animated sprites with size variants for game integration.

### Basic Usage

```dart
import 'package:darkness_dungeon/presentation/design_system/components/atoms/df_animated_sprite_widget.dart';

// Load sprite animation
Future<SpriteAnimation> knightAnimation = SpriteAnimation.load(
  'player/knight_idle.png',
  SpriteAnimationData.sequenced(
    amount: 4,
    stepTime: 0.2,
    textureSize:
    GameplayConstants.kDefaultVectorSize,
  ),
);

// Display with default size
DFAnimatedSpriteWidget(animation: knightAnimation)
```

### Factory Constructors

```dart
// Large sprite for detailed display
DFAnimatedSpriteWidget.large(
  animation: knightAnimation,
)

// Small sprite for UI elements
DFAnimatedSpriteWidget.small(
  animation: knightAnimation,
)

// Custom size
DFAnimatedSpriteWidget(
  animation: knightAnimation,
  width: 80,
  height: 80,
)
```

### Real-world Examples

```dart
// Character selection carousel
class CharacterCarousel extends StatefulWidget {
  @override
  _CharacterCarouselState createState() => _CharacterCarouselState();
}

class _CharacterCarouselState extends State<CharacterCarousel> {
  int currentIndex = 0;

  final List<Future<SpriteAnimation>> characterAnimations = [
    PlayerSpriteSheet.knightIdleRight(),
    PlayerSpriteSheet.knightIdleDown(),
    PlayerSpriteSheet.knightIdleLeft(),
    PlayerSpriteSheet.knightIdleUp(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        children: [
          AppStyledText.large(text: 'Choose Your Character'),
          SizedBox(height: 20),

          // Animated character display
          DFAnimatedSpriteWidget.large(
            animation: characterAnimations[currentIndex],
          ),

          SizedBox(height: 20),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppStyledButton.transparent(
                text: 'Previous',
                onPressed: () {
                  setState(() {
                    currentIndex = (currentIndex - 1) % characterAnimations.length;
                  });
                },
              ),
              AppStyledButton.transparent(
                text: 'Next',
                onPressed: () {
                  setState(() {
                    currentIndex = (currentIndex + 1) % characterAnimations.length;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Menu screen background animation
class MenuBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background elements
        Positioned(
          top: 50,
          right: 30,
          child: DFAnimatedSpriteWidget.small(
            animation: EffectsSpriteSheet.smokeExplosion(),
          ),
        ),

        Positioned(
          bottom: 100,
          left: 50,
          child: DFAnimatedSpriteWidget(
            animation: PlayerSpriteSheet.knightRunRight(),
            width: 64,
            height: 64,
          ),
        ),
      ],
    );
  }
}
```

### Integration with Game Systems

```dart
// HUD element with animated status indicators
class StatusIndicatorWidget extends StatelessWidget {
  final bool isActive;

  const StatusIndicatorWidget({Key? key, required this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppStyledText.small(text: 'Magic: '),
        if (isActive)
          DFAnimatedSpriteWidget.small(
            animation: EffectsSpriteSheet.magicSparkle(),
          )
        else
          Container(
            width: DFAnimatedSpriteWidget.kSmallSize,
            height: DFAnimatedSpriteWidget.kSmallSize,
            color: Colors.grey.shade600,
          ),
      ],
    );
  }
}
```

### Constants Available

```dart
DFAnimatedSpriteWidget.kDefaultSize = 100.0
DFAnimatedSpriteWidget.kLargeSize = 150.0
DFAnimatedSpriteWidget.kSmallSize = 50.0
```

---

## 🎨 Design System Best Practices

### Consistency Guidelines

1. **Always use design system components** instead of creating custom UI elements
2. **Stick to factory constructors** when available (`.large`, `.small`, `.primary`)
3. **Use constants for sizing** rather than hardcoded values
4. **Maintain visual hierarchy** with appropriate text sizes and button styles

### Theming Integration

```dart
// Good: Using design system
AppStyledText.large(text: 'Title')
AppStyledButton.primary(text: 'Action', onPressed: callback)

// Avoid: Custom styling that breaks consistency
Text('Title', style: TextStyle(fontSize: 32, color: Colors.white))
ElevatedButton(child: Text('Action'), onPressed: callback)
```

### Accessibility Considerations

```dart
// Ensure proper semantics
Semantics(
  label: 'Game start button',
  child: AppStyledButton.primary(
    text: 'Play',
    onPressed: _startGame,
  ),
)

// Use appropriate contrast ratios
AppStyledText(
  text: 'Important message',
  color: Colors.yellow, // High contrast against dark background
)
```

### Performance Optimization

```dart
// Cache sprite animations for reuse
class SpriteCache {
  static final Map<String, Future<SpriteAnimation>> _cache = {};

  static Future<SpriteAnimation> getAnimation(String key, Future<SpriteAnimation> animation) {
    return _cache.putIfAbsent(key, () => animation);
  }
}

// Use in widgets
DFAnimatedSpriteWidget(
  animation: SpriteCache.getAnimation('knight_idle', PlayerSpriteSheet.knightIdleRight()),
)
```

---

**Last Updated**: October 2025
**Design System Version**: 2.0 (Post-CLAUDE.md Refactoring)

For more information about the design system architecture, see [ARCHITECTURE.md](ARCHITECTURE.md).
