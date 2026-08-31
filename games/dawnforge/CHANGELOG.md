# Dawnforge (Flutter track) — Changelog

> One section per version, newest first — a complete record of versions (rule 34).
> Categories, used in this order, untouched ones omitted:
> `### 💥 Breaking Changes` · `### ✨ New` · `### 🔧 Changed` · `### ⚖️ Balance` ·
> `### 🐛 Fixed` · `### 🎨 Art & Audio` · `### 🧹 Internal`
>
> A new section is written as `## 0.0.0-NEXT` and stamped by the commit command
> (CLAUDE.md §Parallel sessions).

## 0.38.0

### 🔧 Changed

- Clicking with something that is not a tool — a log, a lump of ore — no longer
  costs you a swing. It was never going to do anything, and you had to wait the
  full two seconds anyway. Pressing with a log in your hand is not a failed
  swing; it is no swing, and now the game agrees.

### 🧹 Internal

- What an item DOES when you press is now the item's own business instead of
  the player's. Swinging a tool and putting a thing down are not two settings
  of one action — they look for different targets, ask different questions, and
  spend different things — so each kind of item gets its own small piece of code
  that knows its own deed. Nothing you can see changed except the line above;
  this is the shape the next step needs to exist at all.
- A press now comes back with three answers rather than two: nothing happened,
  something happened and achieved nothing, something happened and landed. Only
  the middle one costs you the wait, and only the item can tell them apart.

## 0.37.0

### 🧹 Internal

- **Ground can become other ground.** Lay a bridge over water, or a floor over
  a hole, and the square stops being water: you can walk on it, and the picture
  on the screen redraws to show it. Both halves matter — the square changing and
  the screen changing are two separate facts here, because the ground is
  painted a whole chunk at a time, and this is the wire between them.
- The same rule about people applies, and it is the ground's own choice.
  A bridge is a thing you step **onto**, so it may appear under a foot already
  hanging over the water's edge. Solid ground is not, so it may not — that
  would be closing the ground over somebody standing in it.
- Two honest limits. One square of ground does not go **on top of** another
  yet; raising the land into hills is a much bigger job and comes later. And a
  bridge you build and then walk far away from is gone when you come back: the
  world forgets everything it is not currently showing, which is the same
  bargain a chopped-down tree already makes. The game learning to remember is
  its own step.
- Nobody can build any of this yet — the button that spends the item is next.

## 0.36.0

### 🧹 Internal

- The game can now say whether a thing may be built on a particular square,
  and — this is the part that matters — **which rule said no**. There are three
  so far. Somebody is standing there and the thing would take their ground away
  (a torch would not, so a torch is fine at your feet; a hole in the ground very
  much would). Another thing is already on that square. Or there is nothing to
  build on: the empty beyond the edge of the world, or water, which refuses
  things itself rather than being refused by a rule about water.
- Every one of those asks about **all** the squares a thing covers, not just
  the one under your finger. A smelter is two squares wide, and a smelter built
  around you traps you exactly as well as one built on top of you.
- Nobody can build yet — this is the part that decides, not the part that does.

## 0.35.0

### 🧹 Internal

- Some items are now **blueprints**: instead of being a thing you hold, they
  are a thing you put down. An item like that carries the name of what it
  builds, and the game looks that up the same way it looks up everything else,
  so a blueprint naming something nobody drew is caught the moment it is read
  instead of the moment you try to build it.
- The first four of them came in from the design pack: a copper smelter (the
  workshop you melt rock in), a palm bridge and two kinds of ground. Nothing
  puts them in your bag yet and nothing places them yet — that is the next
  couple of steps. This one is the item knowing what it is.

## 0.34.1

### 🧹 Internal

- The build diary closed the tool work: nine steps, from "is somebody standing
  there" all the way to a tree that falls when you click it. It also wrote down
  the four things left out on purpose, so nobody has to guess whether they were
  forgotten.

## 0.34.0

### ✨ New

- **You can gather.** Point at a tree with an axe in your hand and click — or
  tap it with your finger — and it takes the hit. Keep going and it falls
  apart, and what it was made of lands on the ground where it stood and comes
  to you when you walk near. This is the first thing in the game that is
  properly a game: you do something, and the world is different afterwards.

  Four things worth knowing. You hit **exactly what you point at**, never the
  square beside it. Each thing says what may break it — a watering can does
  nothing to a tree, and a weak axe does nothing to a strong rock, which are
  two different problems. **Empty hands still count**: your own two hands are
  a real tool, weak and slow and enough for grass and weeds, so you are never
  unable to touch the world. And you must be close — your reach is your
  tool's, about one square for most of them.

  Your hand does not swing on the screen yet; the tree takes the hit and
  falls, but nobody has drawn the motion. (New manual page: Gathering.)

## 0.33.0

### 🧹 Internal

- An action now remembers what it was aimed at, measured once, at the moment
  the button went down. It sounds like nothing, but it is the difference
  between an arrow going where you pointed and an arrow going backwards: if the
  game works out the direction later, after you have walked past the thing you
  aimed at, the direction comes out reversed. So the aim is taken once and
  carried whole.

## 0.32.0

### 🧹 Internal

- The game knows where you are pointing now. It is one answer for everybody:
  a mouse moving across the window and a finger touching the screen set the
  same cursor, and anything that needs to know asks that one place. The answer
  is worked out fresh every time it is asked, because you can walk while your
  mouse sits still — and then the square you are pointing at changes even
  though your hand did not. Nothing aims with it yet; that is the next step.

## 0.31.1

### 🧹 Internal

- The build diary caught up with the swing, and wrote down what the last step
  needs before anyone starts it: the game still has no idea where your mouse
  is pointing, and there is exactly one place that is allowed to know.

## 0.31.0

### 🧹 Internal

- The swing exists. Point at a tree with an axe in your hand and it takes two
  hits and falls, and the logs land where it stood — the first time in this
  project that anything a player does changes the world. How hard a hit is
  comes from the tool itself, written in its own data: bare hands take a
  breath, an axe takes a bite. The hoe still does nothing to a tree, and a
  hand that holds nothing is never empty, so there is always something to
  swing. Nothing has connected this to your mouse yet — that is the last step
  of this piece of work.

## 0.30.0

### 🧹 Internal

- Things in the world can be broken now, and breaking one is what leaves its
  loot on the ground. A tree with four points of life takes two hits from an
  axe and falls; the logs it was authored to give land where it stood, because
  the stump lets go of its square the moment it dies instead of standing in the
  way of its own logs. The wrong tool still does nothing at all, and neither
  does the right tool on something a person is standing on. Nobody can swing
  yet — that is the last piece.

## 0.29.1

### 🧹 Internal

- The build diary's index caught up again: the gate that decides whether a
  swing is allowed is built and tested, so the notes no longer list it as the
  next thing to do.

## 0.29.0

### 🧹 Internal

- One place in the game now decides whether you are allowed to hit something,
  and it decides in one order. It asks whether your tool is the right kind and
  good enough, and it refuses to let anything be taken out from under a person
  standing on it — unless that thing says it does not mind, which a bush does
  and a staircase does not. Farming is deliberately let through first: hoeing,
  watering and planting do not take the ground away from anyone, so you can
  still work the square you are standing on. Nothing swings yet; the swing is
  next, and it will ask this.

## 0.28.1

### 🧹 Internal

- The build diary's index caught up with the tool work: it still said only the
  first of the six steps was done, when three are.

## 0.28.0

### 🧹 Internal

- The game now knows what you are holding. The slot marked on your bar is the
  thing in your hand, and if what is in that slot changes while it is marked —
  you use the last one, or you drop it — your hand changes with it. An empty
  slot does not mean empty hands: you are holding your own two hands, and those
  count as a real tool, so there is never a moment when you cannot touch the
  world at all. Animals hold what they were born with instead — a boar's tusks
  are its weapon, and no bag of theirs can change that. Nothing swings yet; the
  swing is next.

## 0.27.1

### 🧹 Internal

- The toolbox that turns this project into an Android app was getting old, and
  it said so out loud every single time the game was launched: three warnings
  about parts Flutter is about to stop supporting. All three parts are new now
  — Gradle, the Android plugin, Kotlin — and the three warnings are gone. The
  game itself was not touched; only the machine that packs it. One warning
  stays and cannot leave yet: Kotlin still has to be fetched by hand, because
  the copy that comes inside the new Android plugin is older than the one
  Flutter insists on.

## 0.27.0

### 🧹 Internal

- Tools and the things they break can finally see each other. Every rock, tree
  and crate in the game already said which tools may touch it and how good they
  have to be; every tool already said which one it is and how good it is. The
  game just was not reading any of it. Now it does, and it knows the two
  questions apart: "you need an axe" is not the same as "you need a better
  axe". Nothing swings yet — the swing is next.

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
