import 'package:darkness_dungeon/darkness_dungeon.dart';

class GameplayDialogConstants {
  static Say knightLeftDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
      ],
      person: DFAnimatedSpriteWidget(
        animation: UISpriteAnimations.knightPlayerIdleRight6(),
      ),
      personSayDirection: PersonSayDirection.LEFT,
    );
  }

  static Say wizardRightDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
      ],
      person: DFAnimatedSpriteWidget(
        animation: UISpriteAnimations.wizardIdleLeft(),
      ),
      personSayDirection: PersonSayDirection.RIGHT,
    );
  }

  static Say kidRightDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
      ],
      person: DFAnimatedSpriteWidget(
        animation: UISpriteAnimations.kidIdleLeft(),
      ),
      personSayDirection: PersonSayDirection.RIGHT,
    );
  }

  static Say bossLeftDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
      ],
      person: DFAnimatedSpriteWidget(
        animation: UISpriteAnimations.dungeonBossEnemyIdleRight4(),
      ),
      personSayDirection: PersonSayDirection.LEFT,
    );
  }

  static Say bossRightDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(
          text: GameplayStringsLocation.instance.getString('talk_boss_2'),
        ),
      ],
      person: DFAnimatedSpriteWidget(
        animation: UISpriteAnimations.dungeonBossEnemyIdleLeft4(),
      ),
      personSayDirection: PersonSayDirection.RIGHT,
    );
  }
}
