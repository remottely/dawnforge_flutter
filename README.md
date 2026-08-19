# Dawnforge

Jogo 2D top-down estilo *Stardew Valley / Forager*, feito em Flutter + [Bonfire](https://pub.dev/packages/bonfire).

Single-player, offline, com persistência local. Roda em Android, iOS, macOS, Linux, Windows e Web.

---

## Rodando

```bash
flutter pub get

# desenvolvimento (logs ativos, hitboxes visíveis, dia começa 1h)
flutter run --dart-define=GAME_ENVIRONMENT=DEVELOPMENT

# produção
flutter run --release
```

`GAME_ENVIRONMENT` aceita `DEVELOPMENT`, `STAGING` ou `PRODUCTION` (padrão). As flags derivadas ficam em [`lib/core/utils/app_environment.dart`](lib/core/utils/app_environment.dart) e são `const` — o compilador elimina o código de debug em release.

## Testes

```bash
flutter test                # suíte
./tool/coverage.sh          # cobertura + gate por camada
flutter analyze             # linter
dart format .               # formatação
```

---

## Estrutura

```
lib/
├── main.dart      # bootstrap
├── core/          # utilitários sem dependência de jogo
├── shared/        # design system + classes-base de entidades Bonfire
├── pre_game/      # menu
└── game/
    ├── features/  # domínio: farm, inventory, time, market, world
    ├── systems/   # save, audio, map, combat, overlay, input, localization
    ├── modules/   # players, enemies, npcs, decorations
    ├── database/  # catálogo de conteúdo (constantes tipadas)
    └── global/    # state machine e input globais
```

## Documentação

| Arquivo | Conteúdo |
|---|---|
| [CLAUDE.md](CLAUDE.md) | **comece aqui** — convenções, padrão de commit, regras de contribuição |
| [documentation/ARCHITECTURE.md](documentation/ARCHITECTURE.md) | arquitetura detalhada, fluxos, regras de domínio |
| [documentation/TESTING.md](documentation/TESTING.md) | estratégia de testes e metas de cobertura |
| [documentation/refactoring/](documentation/refactoring/) | plano de evolução em fases + ADRs |
| [documentation/gdd_mvp.md](documentation/gdd_mvp.md) | game design do MVP |

## Commits

```
<version>; <type>: <description>
```

Exemplo: `1.110.14+1; feat: add seed bag stacking`

`<version>` é o valor de `version:` no `pubspec.yaml` após o bump deste commit. Tipos: `feat`, `fix`, `refactor`, `chore`, `config`, `test`, `docs`. Detalhes em [CLAUDE.md §5](CLAUDE.md#5-padrão-de-commit--obrigatório).

---

## Créditos

**Packages:** [bonfire](https://pub.dev/packages/bonfire) · [flame_audio](https://pub.dev/packages/flame_audio) · [flame_splash_screen](https://pub.dev/packages/flame_splash_screen) · [get_it](https://pub.dev/packages/get_it) · [url_launcher](https://pub.dev/packages/url_launcher)

**Sprites:** [Dungeontileset II](https://0x72.itch.io/dungeontileset-ii) · [Simple Dungeon Crawler](https://o-lobster.itch.io/simple-dungeon-crawler-16x16-pixel-pack) · SmallBurg Village/Farm/Dungeon Packs · SunnysideWorld · Modern Farm

**Música:** Scott Buckley (CC-BY 4.0) · Savfk (CC-BY 3.0) · Justin Allan Arnold (CC-BY 3.0) · Glitch (CC-BY 3.0) · Pixverses

## Licença

MIT — ver [LICENSE](LICENSE).
