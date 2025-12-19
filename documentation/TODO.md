# IMPORTANT BEFORE LAUNCH:
- [PRIORITY] criar uma maneira do jogo nunca quebrar todo por conta de um exception. trata-los!! principalmente pq um asset nao existe.

- [PRIORITY] change snake_case names "strawberry_seed_bag" to camelCase "strawberrySeedBag"

- [PRIORITY] Configurar os items de seed em items_icons_database

- [PRIORITY] Refact crops_database to be like items_icons_database structure

- [DONE] **Nota**: Ajuste os índices de row/column conforme a posição real dos sprites no atlas.

- [PRIORITY?] fazer o load da hand do player carregar oq ja possuimos salvo do player funcionando?

- [PRIORITY] fazer o load e save como estado do jogo como um todo

- [DONE] render in all conversations the actual player sprite animation dynamically

- [PRIORITY] enhance: create a logic that we dont need to declare each crop asset path to pubspec.yaml like: "assets/images/gameplay/farm/crops/strawberry/"

- [DONE] farm crops need to have 3D behavior, fix it

- [PRIORITY] seeds planted cant have 3D behavior, fix it

- [PRIORITY] fix die multiple times in the same second bug the game, handle cannot die more than once.

- [PRIORITY] refactor all tiled decoration nomenclatures

- [PRIORITY] verify if need the \_activeAnimationLockCount logic

- [PRIORITY] remove EquipmentToCustomPlayerAdapter from codebase??

- [PRIORITY] Change background musics

---

# Enhance:

- [DONE] add torch ON/OFF interaction

- [NOT_PRIORITY] save torch state

- [NOT_PRIORITY] Create a way to config game view size dynamically, small, medium, large by changed user.

- [NOT_PRIORITY] continuous attack with continuous press attack (space bar)

- [NOT_PROPRITY?] Future action: Refact all assets???

- [NOT_PRIORITY] Add dynamic crop icons render when harvest action

---

# Fix:

- [DONE] move map player spawn location to player center component and not top left of the component

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
