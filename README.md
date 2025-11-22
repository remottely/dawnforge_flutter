[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=102)](https://github.com/RafaelBarbosatec/darkness_dungeon)
[![Demo](https://img.shields.io/badge/Download-APK-green)](https://github.com/RafaelBarbosatec/darkness_dungeon/raw/master/demo/demo.apk)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue.svg)](https://flutter.dev/)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)

# Darkness Dungeon

Game developed for the purpose of testing the use of the Bonfire package!

![](https://github.com/RafaelBarbosatec/darkness_dungeon/blob/master/media/print1.jpg)

![](https://github.com/RafaelBarbosatec/darkness_dungeon/blob/master/media/print2.jpg)

![](https://github.com/RafaelBarbosatec/darkness_dungeon/blob/master/media/print3.jpg)

[Play in Browser](https://rafaelbarbosatec.itch.io/darkness-dungeon)

[Donwload PlayStore](https://play.google.com/store/apps/details?id=com.rafaelbarbosatec.darkness_dungeon)

## 🏗️ Architecture

This project follows a clean architecture pattern with clear separation of concerns:

- **`/lib/gameplay/`** - Game logic, entities, managers, and core game systems
- **`/lib/presentation/`** - UI components, screens, and design system
- **`/documentation/`** - Architecture documentation and development guides

For detailed architecture information, see [ARCHITECTURE.md](documentation/ARCHITECTURE.md).

## 📋 Code Standards

This project follows the **CLAUDE.md** coding standards for consistency and maintainability:

### Naming Conventions

- **Constants**: Use `k` prefix (e.g., `kDefaultSize`, `kAnimationDuration`)
- **Private methods**: Use `_` prefix (e.g., `_initializeComponents()`)
- **Private variables**: Use `_` prefix (e.g., `_isGameActive`)
- **Classes**: PascalCase (e.g., `GameplayStateManager`)
- **Files**: snake_case (e.g., `gameplay_state_manager.dart`)

### Class Structure

```dart
class ExampleClass extends StatelessWidget {
  // 1. Constants (grouped by type)
  static const double kDefaultSize = 24.0;
  static const Color kDefaultColor = Colors.white;

  // 2. Properties
  final String title;
  final VoidCallback? onPressed;

  // 3. Constructor
  const ExampleClass({super.key, required this.title, this.onPressed});

  // 4. Factory constructors (if applicable)
  const ExampleClass.large({...});

  // 5. Build method
  @override
  Widget build(BuildContext context) { }

  // 6. Private helper methods
  Widget _createStyledWidget() { }
}
```

### Documentation Standards

- All public classes have comprehensive documentation
- Complex methods include inline comments
- Factory methods are documented with usage examples
- Code follows Flutter/Dart documentation conventions

## 🤝 Contributing

When contributing to this project, please follow these guidelines:

1. **Follow CLAUDE.md standards** - Ensure your code adheres to the established patterns
2. **Maintain consistency** - Use the same naming conventions and class structures
3. **Document your code** - Add clear comments and documentation for new features
4. **Test thoroughly** - Run `flutter test` before submitting changes
5. **Update documentation** - Keep ARCHITECTURE.md updated when adding new systems

### Code Review Checklist

- [ ] Constants use `k` prefix
- [ ] Private methods/variables use `_` prefix
- [ ] Classes follow established structure pattern
- [ ] Public methods are documented
- [ ] Tests pass without errors
- [ ] No breaking changes to existing functionality

## Used packages:

bonfire - [![pub package](https://img.shields.io/pub/v/bonfire.svg)](https://pub.dev/packages/bonfire)

flame_audio - [![pub package](https://img.shields.io/pub/v/flame_audio.svg)](https://pub.dev/packages/flame_audio)

flame_splash_screen - [![pub package](https://img.shields.io/pub/v/flame_splash_screen.svg)](https://pub.dev/packages/flame_splash_screen)

url_launcher - [![pub package](https://img.shields.io/pub/v/url_launcher.svg)](https://pub.dev/packages/url_launcher)

## Used sprites:

[Dungeontileset](https://0x72.itch.io/dungeontileset-ii)

[Simple Dungeon Crawler](https://o-lobster.itch.io/simple-dungeon-crawler-16x16-pixel-pack)

magick spr_idle_strip9.png -crop 96x64 +repage -flop +append spr_idle_left_strip9.png
