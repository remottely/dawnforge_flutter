import 'package:darkness_dungeon/darkness_dungeon.dart';

class GameplayDialogConstants {
  static Say knightLeftDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
      ],
      person: DDAnimationWidget(
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
      person: DDAnimationWidget(
        animation: UISpriteAnimations.wizardNpcIdleLeft4(),
      ),
      personSayDirection: PersonSayDirection.RIGHT,
    );
  }

  static Say kidRightDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
      ],
      person: DDAnimationWidget(
        animation: UISpriteAnimations.kidNpcIdleLeft4(),
      ),
      personSayDirection: PersonSayDirection.RIGHT,
    );
  }

  static Say bossLeftDialog(String phraseKey) {
    return Say(
      text: [
        TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
      ],
      person: DDAnimationWidget(
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
      person: DDAnimationWidget(
        animation: UISpriteAnimations.dungeonBossEnemyIdleLeft4(),
      ),
      personSayDirection: PersonSayDirection.RIGHT,
    );
  }
}
