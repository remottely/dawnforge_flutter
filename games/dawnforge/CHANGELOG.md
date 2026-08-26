# Dawnforge (Flutter track) — Changelog

> One section per version, newest first — a complete record of versions (rule 34).
> Categories, used in this order, untouched ones omitted:
> `### 💥 Breaking Changes` · `### ✨ New` · `### 🔧 Changed` · `### ⚖️ Balance` ·
> `### 🐛 Fixed` · `### 🎨 Art & Audio` · `### 🧹 Internal`
>
> A new section is written as `## 0.0.0-NEXT` and stamped by the commit command
> (CLAUDE.md §Parallel sessions).

## 0.15.0

### 🧹 Internal

- The game's data files now say what every rock, tree and creature leaves
  behind when it breaks — and how the forest decides where its plants, ores
  and animals get to live. The game can read all of it now; making it happen
  on screen is the next step.

## 0.14.1

### 🧹 Internal

- The project's build diary now carries only the names of the people who build
  it. Every past entry was rewritten to drop a tool's signature, and a guard
  was added that refuses to write another one.

## 0.14.0

### 🧹 Internal

- A little counter panel appeared in the top corner: it shows how fast the
  game is drawing and how much work the world-building is doing each
  moment. It is a builder's tool for now — it will hide behind a setting
  later.

## 0.13.0

### ✨ New

- The world pushes back now: the sea's edge and mountain walls stop you
  instead of letting you walk through. Slide along a wall and you keep
  moving — only the blocked direction stops. (Manual page The World
  updated.)

## 0.12.0

### ✨ New

- The world does not end anymore. The little green field is gone — now
  every new game builds a whole world from a seed number: grass, sea and
  stepped mountains, different every time, the same every time you replant
  the same seed. Walk as far as you like; the ground ahead appears as you
  go. You start on a safe flat patch of grass. (New manual page: The World.)

## 0.11.0

### 🧹 Internal

- The world learned to build itself around you, piece by piece: as you
  walk, the ground ahead quietly appears and the ground far behind is put
  away — a little each frame, never all at once, so the game stays smooth.
  Walking along an edge never makes it flicker. Fourth of five steps toward
  the endless world; the last one puts it on screen.

## 0.10.1

### 🧹 Internal

- A self-check that sometimes cried wolf on busy computers learned to wait
  its turn: it now watches for the game to REALLY finish waking up instead
  of counting a fixed number of blinks.

## 0.10.0

### 🧹 Internal

- The game's map memory grew up: it now remembers which tile of ground sits
  on every spot, and how tall each mountain step is — without spending any
  extra memory on tiles nobody changed. Water and cliff learned to say what
  they are. Third of five steps toward the endless world.

## 0.9.0

### 🧹 Internal

- The world generator was born: give it a seed number and it decides, for
  any spot you ask, whether there is water, grass or mountain there — and it
  always gives the same answer for the same seed. Mountains rise in steps,
  like a pyramid, and the starting point is always flat ground. Still
  nothing on screen — second of five steps toward the endless world.

## 0.8.0

### 🧹 Internal

- The world learned its first recipe for making ground: the forest's terrain
  numbers (how much water, how much mountain) now travel from the pack into
  the game, together with the natural-ground tile they will paint. Nothing
  visible yet — first of five steps toward a world that goes on forever.

## 0.7.1

### 🐛 Fixed

- The game was invisible — a green field with nothing on it. Two bugs, both
  fixed: things were being placed outside where the camera looks, and every
  animated picture was being drawn 16 times too small to see.

## 0.7.0

### ✨ New

- The game opened its eyes: a boar you can walk with the keyboard (WASD or
  arrows), on a green field with a palm tree, rocks and plants around it. The
  camera follows you. It is small, but it is the first thing you can PLAY.

## 0.6.0

### 🎨 Art & Audio

- The pictures arrived: the game now cuts every sprite out of the same big
  art sheet the Godot version uses — 22 real sprites, and a colored
  placeholder for the 14 things that don't have final art yet.

## 0.5.0

### 🧹 Internal

- The game can now speak three languages: the names and descriptions written
  for the Godot version (English, Portuguese, Spanish) load here too — 228
  lines of text, with a build check that catches any language missing a line.

## 0.4.0

### 🧹 Internal

- Creatures learned to move, face left and right, get hurt, heal slowly and
  die — the same rules the Godot version uses, working here now. Still nothing
  on screen: the drawing part comes next.

## 0.3.0

### 🧹 Internal

- The game's content book started working: the same files that describe items,
  crops and creatures in the Godot version are now read here too. The first 38
  things — wheat, tomatoes, clover and friends — load correctly.

## 0.2.0

### 🧹 Internal

- The engine learned the shape of every world thing: actors, props, ground
  tiles and items now exist as data the game can read, and the factories that
  build them safely. Still nothing playable — this is foundation work.

## 0.1.0

### 🧹 Internal

- The project was restarted as the Tessera-Dart study track: the old game was archived
  and a new engine, ported from the Godot version of Dawnforge, began. Nothing is
  playable yet.
