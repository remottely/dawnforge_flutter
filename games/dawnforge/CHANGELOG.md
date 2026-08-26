# Dawnforge (Flutter track) — Changelog

> One section per version, newest first — a complete record of versions (rule 34).
> Categories, used in this order, untouched ones omitted:
> `### 💥 Breaking Changes` · `### ✨ New` · `### 🔧 Changed` · `### ⚖️ Balance` ·
> `### 🐛 Fixed` · `### 🎨 Art & Audio` · `### 🧹 Internal`
>
> A new section is written as `## 0.0.0-NEXT` and stamped by the commit command
> (CLAUDE.md §Parallel sessions).

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
