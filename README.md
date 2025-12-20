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

cd assets/images/SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE\ CHARACTER/PNG/WITH_FX
magick spr_doing_till_strip8.png -crop 96x64 +repage -flop +append spr_doing_till_left_strip8.png

cd assets/images/new/Player
magick Player*Actions.png -crop 96x48 +repage -scene 1 Player_Actions_row*%d.png

eu possuo um arquivo chamado Player.png q contem todas as sprites do meu player. porem eu preciso transformar todos os frames em arquivos separados. o meu arquivo esta assim hoje:
cada frame ocupa 48x48. o arquivo é 192 x 320 e esta configurado assim:
seriam 10 rows e 6 colunas de 48x48. só que as 6 primeiras rows possuem os totais 6 frames, porem as ultimas 4 rows possuem apenas 4 frames cada. entao preciso cortar todo o arquivo em 10 novos arquivos, 6 primeiras rows em arquivos de 6 frames e as 4 ultimas em 4 frames. tudo utilizando um unico comando no temrinal utilizando magick no mac q ja possuo instalado.

magick Player.png -crop 32x32 +repage frame\_%03d.png && rm frame_006.png frame_007.png frame_013.png frame_014.png frame_015.png frame_020.png frame_021.png frame_022.png frame_023.png frame_027.png frame_028.png frame_029.png frame_030.png frame_031.png frame_034.png frame_035.png frame_036.png frame_037.png frame_038.png frame_039.png

magick Player.png -crop 192x32 +repage +adjoin row\_%02d.png

magick row_06.png -crop 128x32+0+0 +repage row_06.png && magick row_07.png -crop 128x32+0+0 +repage row_07.png && magick row_08.png -crop 128x32+0+0 +repage row_08.png && magick row_09.png -crop 128x32+0+0 +repage row_09.png
magick player_attack_east_4.png -crop 32x32 +repage -flop +append player_attack_west_4.png

magick player_walk_south_6.png -crop 32x32 \
 -gravity center -background transparent -extent 48x48 \
 +append player_walk_south_48x48_6.png

\_48x48

animations type:

- Directional
- right
- left
- up
- down
- right Up
- right Down
- left Up
- left Down

// TODO: put all maps background color to be the same as map ground