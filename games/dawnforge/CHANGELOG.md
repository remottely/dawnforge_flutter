# Dawnforge (Flutter track) — Changelog

> One section per version, newest first — a complete record of versions (rule 34).
> Categories, used in this order, untouched ones omitted:
> `### 💥 Breaking Changes` · `### ✨ New` · `### 🔧 Changed` · `### ⚖️ Balance` ·
> `### 🐛 Fixed` · `### 🎨 Art & Audio` · `### 🧹 Internal`
>
> A new section is written as `## 0.0.0-NEXT` and stamped by the commit command
> (CLAUDE.md §Parallel sessions).

## 0.26.1

### 🧹 Internal

- The build diary wrote down the order the tool work has to happen in, and the
  two traps hidden in it, while they were still fresh from reading.

## 0.26.0

### 🧹 Internal

- The game learned to answer one question properly, before anything can build
  or break: **is somebody standing there?** It checks the space a person's feet
  actually cover, not the square they are nearest to, and it checks every
  square a thing would cover, not just its corner. And whether a thing is even
  allowed to appear or vanish under you is written in that thing's own data — a
  bush may be planted at your feet and broken there; a staircase may not,
  because taking it away changes the ground you are standing on. Nothing uses
  the answer yet; the tools that will are next.

## 0.25.1

### 🧹 Internal

- The build diary marked the backpack work finished, and wrote down the two
  things left out of it on purpose, so nobody starts them by accident.

## 0.25.0

### ✨ New

- Your backpack opens. Press **I** or **Tab** and all thirty pockets are there;
  press **Esc** to close it. Drag a thing onto another pocket and the right
  thing happens by itself: an empty pocket takes the pile, a pocket with the
  same thing joins the piles, and a pocket with something else swaps them.
  Hold **Shift** while dragging to carry only half. Drag a thing out of the
  backpack and drop it on the world to put it on the ground at your feet.

  And look behind it while it is open: the trees are still there, blurred, and
  the world is still moving. **The game never stops.** You cannot act while the
  backpack is open, but time does not wait for you — so it is not a place to
  hide. (New manual page: The Backpack.)

## 0.24.2

### 🐛 Fixed

- A thing you drop can now stay dropped. Every item already said, in its own
  data, how long it should rest on the ground before anyone may scoop it up —
  half a second — and the game was not reading that line. So anything landing
  at your feet was yanked straight back into your backpack on the very next
  moment, which would have made putting something down impossible. Now it lies
  there, waits its half second, and only then comes to you.

## 0.24.1

### 🧹 Internal

- The build diary's own index caught up with the work: the notes that say what
  is done and what is next were still describing the backpack screens as
  untouched.

## 0.24.0

### ✨ New

- Your backpack has a face now. A bar of ten pockets sits at the bottom of the
  screen, and one of them always has a bright yellow edge — that is the pocket
  you are holding from. Press a number key, press `Q` or `E`, or just tap a
  pocket to choose a different one. Your backpack is thirty pockets deep, so
  the bar shows ten at a time and **Page Up** / **Page Down** turn the page;
  the dots underneath say which page you are on. Things you pick up show up in
  it straight away, with a little number when you have more than one. (New
  manual page: The Item Bar.)

## 0.23.0

### 🔧 Changed

- You are not a boar anymore. Until now the character you walked around was
  literally one of the forest animals, borrowed because nobody had made a
  player yet — and a boar has no pockets, so every single thing the world
  dropped bounced off you and stayed on the grass. Now you are you, with a
  backpack of thirty pockets. Two honest warnings: you are drawn as a plain
  coloured square for the moment, because the art for a person is not in the
  game yet, and you still cannot open the backpack — the screen for it is the
  very next thing.

## 0.22.0

### 🧹 Internal

- The game now has one place that knows what is on your screen. Only one big
  window can hold the screen at a time, so opening your bag over the map puts
  the map away by itself instead of leaving two things stacked on top of each
  other. The little corner things — your item bar, your hearts — come back the
  moment the last window closes, always, because one rule decides it rather
  than every window remembering to. And the Back button now goes to exactly
  one place: whatever is on top answers it, so a single press can never close
  one thing and open another at the same time.

## 0.21.0

### 🧹 Internal

- Backpacks learned the moves your hands make. Until now the bag could only
  decide for itself where a new thing went. Now a thing can be put in the
  pocket you choose, taken out of the pocket you point at, poured into the
  pocket next door until it is full, or handed over to a different bag
  entirely — and when two different things meet, they simply trade pockets.
  Nothing on screen yet: this is the machinery under the dragging that comes
  next.

## 0.20.0

### 🧹 Internal

- The game can now be taught how to say things about itself. Until today only
  the names of things in the world — a boar, a plum, a pickaxe — had words in
  every language. The words the screen itself needs, like the title over your
  bag, had nowhere to be written. Now they do, in English, Portuguese and
  Spanish at once, and a word missing from one language stops the build instead
  of surprising you later.

## 0.19.1

### 🧹 Internal

- The endless world passed its speed test: walking without stopping, the
  game stayed at 120 drawings a second — twice as smooth as the target it
  had to hit. The world-building keeps up with you.

## 0.19.0

### ✨ New

- The forest came alive: wild grass, palm trees, bushes, flowers, rocks,
  coal and copper now grow across the whole world, in little natural
  groups — and copper hides in rich pockets worth hunting for. Every
  world grows its own forest from its seed, the same forest every time
  you replant the same seed. Solid things are really solid: you walk
  around a tree, not through it. (Manual page The World updated.)

## 0.18.0

### 🧹 Internal

- Dropped things became real: an item can now lie on the ground, bob
  gently, and fly into your backpack when you come close — and it is smart
  about where it lands, never inside a wall or out at sea, always on
  ground at your own height. If the backpack is full, it waits on the
  ground. Nothing in the world drops items YET — the tools that break
  things come next.

## 0.17.0

### 🧹 Internal

- Backpacks exist now, on the inside: a place with numbered pockets where
  things can be kept, stacked and counted, with fair rules — same things
  pile together, a full pocket says no, and a tool always keeps a pocket
  to itself. You cannot see it yet; the screen part comes later.

## 0.16.0

### 🧹 Internal

- The game learned the math of loot: how a chance decides if something
  drops, and how a "more loot" bonus always means MORE — even a small bonus
  now pays out its fair share over time instead of quietly rounding away to
  nothing.

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
