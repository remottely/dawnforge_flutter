# IMPORTANT BEFORE LAUNCH:

- [PRIORITY] enhance: create a logic that we dont need to declare each crop asset path to pubspec.yaml like: "assets/images/gameplay/farm/crops/strawberry/"
- [PRIORITY] farm crops need to have 3D behavior, fix it
- [PRIORITY] fix die multiple times in the same second bug the game, handle cannot die more than once.
- refactor all tiled decoration nomenclatures
- save torch state
- [PRIORITY] verify if need the \_activeAnimationLockCount logic
- [PRIORITY] remove EquipmentToCustomPlayerAdapter from codebase??
- [PRIORITY] Change background musics

---

# Enhance:

- [DONE] add torch ON/OFF interaction

---

# Fix:

- [DONE] move map player spawn location to player center component and not top left of the component

- [NOT_PRIORITY] continuous attack with continuous press attack (space bar)

- [DONE] Player walk/run then attack, after attack steel previous attack walk/run animation

- [PRIORITY] attacks particles animations

- [PRIORITY] add "X" to display keyboard configuration. And change all keyboard display layout.

- [PRIORITY] emote bug, displaying outside gameplayscreen area

- [PRIORITY] win and die do not show in same time. how to resolve this issue? do to every enemy "enemy.idle"?

- [PRIORITY] organize all project exports in one file

- forest_1.json:

  - [PRIORITY] colission behavior

- farm tile:

  - [DONE] priority
  - [DONE] render not showing

- enemies:

  - [PRIORITY] run in direction of the player when receive player ranged attack

- characters:

  - [DONE] boss die explosion not in the same size as boss sprite
  - [DONE] mini boss collision size
  - [DONE] create a helper hitbox size calculation based on spriteSize/textureSize/componentSize

- fireball attack:

  - [DONE] collision size and position

- UI dialogues:

  - [DONE] force player to stop in every conversation
  - [PRIORITY] force "game pause" in every UI display
  - [PRIORITY] execute player.idle even in victory and game over dialogs

- Audio:

  - [DONE] put music_gameplay_background.mp3 back

---

# Documentation:

- [PRIORITY] Create documentation that explains that config layer represents "constants, factories, builders, etc." in the same class.

---

- AI Prompts:

  - Preciso que você finalize o planejamento da logica inicial de meu farmable. Levando em conta que quero fazer o clone do stardew valley... TODO(Kevin): finalizar esse prompt

  - Preciso que você percorra todo o meu código fazendo melhorias onde necessário para deixar tudo bem implementado e padronizado. use como referência o módulo de "lib/gameplay/characters/player/knight", utilizando o MVC e camada de config.

---
