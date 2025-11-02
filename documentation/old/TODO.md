fix:

- fix: execute player.idle even in victory and game over dialogs

- emote bug, displaying outside gameplayscreen area

- win e die do not show in same time. how to resolve this issue? do to every enemy "enemy.idle"?

- organize all project exports in one file

- forest_1.json:

  - colission behavior

- farmable tile:

  - priority
  - render not showing

- enemies:

  - run in direction of the player when receive player ranged attack

- Dungeon Boss:

  - boss die explosion not in the same size as boss sprite

- Dungeon Mini Boss:

  - fix collision size

- characters:

  - create a helper hitbox size calculation based on spriteSize/textureSize/componentSize

- fireball attack:

  - fix collision size and position

- UI dialogues:

  - force player to stop in every dialogue start

- Audio:

  - put music_gameplay_background.mp3 back

- Create documentation that explains that config layer represents "constants, factories, builders, etc." in the same class.

- prompt:

  - Preciso que você finalize o planejamento da logica inicial de meu farmable. Levando em conta que quero fazer o clone do stardew valley... TODO(Kevin): finalizar esse prompt

- Preciso que você percorra todo o meu código fazendo melhorias onde necessário para deixar tudo bem implementado e padronizado. use como referência o módulo de "lib/gameplay/characters/player/knight", utilizando o MVC e camada de config.
