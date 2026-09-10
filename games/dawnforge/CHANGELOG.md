# Dawnforge (Flutter track) — Changelog

> One section per version, newest first — a complete record of versions (rule 34).
> Categories, used in this order, untouched ones omitted:
> `### 💥 Breaking Changes` · `### ✨ New` · `### 🔧 Changed` · `### ⚖️ Balance` ·
> `### 🐛 Fixed` · `### 🎨 Art & Audio` · `### 🧹 Internal`
>
> A new section is written as `## 0.0.0-NEXT` and stamped by the commit command
> (CLAUDE.md §Parallel sessions).

## 0.57.0

### 🧹 Internal

- Nothing in the game changed. There is a little watchman that reads every file
  right after it is written and complains if it spots one of the shapes we have
  promised never to use. It knew three of them. It now knows a fourth: a value
  whose type nobody wrote down. A fifth one we had promised is written off on
  purpose, with the reason in the watchman's own notes, because no way of
  spotting it could tell a real mistake from ordinary honest code.

## 0.56.0

### 🧹 Internal

- Nothing in the game changed. Every page of this game's recipe book was copied
  by hand from the bigger version of the game, one page at a time, and nobody
  ever went back to see whether a page had been rewritten over there afterwards.
  Now a checker compares all sixty-one pages at once. Anything the two books
  disagree about has to be written down with a reason, so a difference nobody
  chose can never sit there quietly again. The first run found sixty-seven of
  them, including one that had been noticed once and never followed up.

## 0.55.0

### 🧹 Internal

- Nothing in the game changed. Every part of the game is supposed to come with
  a little program that pokes it and checks it still behaves — that is how we
  notice when something we fixed breaks again later. Somebody counted for the
  first time: out of 109 parts, 88 are poked by something and 21 are never
  touched at all. The list of those 21 is now written down, in the order that
  matters most, with what each check has to prove. Four of them hold up almost
  everything else, including the one that makes the same world come back when
  you use the same seed.

## 0.54.0

### 🧹 Internal

- Nothing in the game changed. The bigger version of this game has a whole
  toolbox of little helper programs that check the game's own files for
  mistakes — one asks whether a picture really exists, another asks whether
  two notes about the same thing still agree. We have far fewer of those, and
  nobody had ever sat down and compared the two toolboxes. Now somebody has:
  every tool over there is written down here as either "we need this one",
  "we already have it" or "we will never need it, and here is why". Three
  things we could not check before are on the list, and each one already
  found a real problem while it was being written down.

## 0.53.0

### 🧹 Internal

- Nothing in the game changed. The folder holding the older, bigger version of
  this game was renamed a while ago, and our notes still pointed at the old
  name — so anyone looking something up there found an empty shelf and had to
  find the new one by hand. The address is now written down in exactly one
  place, and every note points at that place instead of spelling it out again.

## 0.52.1

### 🧹 Internal

- Nothing in the game changed. The word-checker from the previous version was
  counting the two places that DEFINE the word-lookup as if they were words
  it could not check, and the previous version's note said the count was
  zero when it was two. Both are fixed: the count is now truly zero.

## 0.52.0

### 🧹 Internal

- Nothing in the game changed. Every word the screen asks for by name is now
  checked against all three language tables before any work is filed. Until
  now a word nobody had translated would only be found when a player opened
  the screen that needed it, and the game would stop there.

## 0.51.0

### 🧹 Internal

- Nothing in the game changed. The history book now checks its own shape
  before any work is filed: newest page first, no page twice, the seven
  headings in their fixed order, and the English and Portuguese books telling
  the same pages with the same headings. Two pages sat out of order for three
  versions before a person noticed; from now on the checker notices first.

## 0.50.0

### ✨ New

- **You start with a copper pickaxe.** It sits in the first pocket of your bag
  and is already in your hand when a new world begins. It breaks rocks and
  ore, which are the first things everything else is made from. Until now you
  started with nothing, and nothing in the world could be mined at all.
- The copper pickaxe itself came in from the design pack. You cannot make one
  yet — that needs the workshop — but you own one.

### 🧹 Internal

- What a new player starts with is a page in the design pack, read by the
  game's tools the same way the original game reads its own, so a second
  page beside it would be a second way to start. The original's page grants
  nothing; ours grants the pickaxe, and the difference is written down on the
  page itself.
- A start page that names an item the pack does not have stops the tools
  before it can stop the game.

## 0.49.0

### ✨ New

- **Palm trees give logs.** A grown palm now leaves logs behind when it falls,
  and a young one gives seeds instead. Until now no tree in the world gave any
  wood at all — the logs were written in the design under "what a grown palm
  gives", and the game never read that page.
- **Forests have young and old trees.** Every wild plant now comes into the
  world at some point in its life, from a fresh sprout to fully grown, so a
  forest is no longer all the same age. Grown ones give the most.
- Seeds exist: palm, green-leaf, clover, wheat, apple, tomato and plum seeds
  came in from the design pack, because plants can drop them. You cannot plant
  them yet — that is the farming chapter.

### 🐛 Fixed

- Every palm drew as a seedling, whatever age it was. A plant now shows the
  picture for the age it actually is.

### 🧹 Internal

- Plants learned their life on paper: which age is grown, whether they can die
  of neglect, whether a hand may pick them, and what each age gives. Only the
  "what does it give" part is used so far; growing over days, watering and
  picking by hand wait for the farming chapter.
- A plant's loot is two lists that ADD — what it gives at any age, and what
  this age gives on top. They roll one after the other, never the same list
  twice.

## 0.48.2

### 🧹 Internal

- Nothing in the game changed. The folder where the project keeps its plans got
  its front page: which plan is the one being worked on, what the drawers are
  for, and what a new plan must contain before it counts as one.

## 0.48.1

### 🧹 Internal

- Nothing in the game changed. The project's to-do book got a lot longer and a lot
  more exact: every next step of the port — farming, the door to the bench, the
  screens, saving your world, and the big list of things after that — is now
  written as small numbered jobs, each with the page of the original game it
  copies and the test that proves it. One earlier note was wrong and is fixed:
  the original game already has a "what you start with" list, so this game will
  read that list instead of inventing a new one. The questions only the developer
  can answer are collected in one table, each with a suggested answer.

## 0.48.0

### 🧹 Internal

- **A bench can now work.** Give a smelter a recipe and the ore and coal it
  asks for, and it takes them all at once, works through the batch one bar at
  a time, and puts each finished bar on the ground in front of itself — never on
  top of itself. Nobody can ask a bench to do this yet: the way you talk to one
  (walking up and pressing a key) does not exist in this build. The engine is
  ready for it; the door is the next step.
- You pay for the whole batch up front, and the bench keeps what it has not used
  yet. Stop it halfway and everything it had not burned comes back onto the
  ground. Break a working bench and the same happens, before its own pieces
  fall.
- A bench refuses two things and quietly: a recipe it does not make, and a
  batch you cannot afford. Neither takes a single item from your bag.
- Fixed a mistake copied straight from the design: while making five bars the
  design counted "bar 1 of 1" five times, because it never wrote down how many
  were ordered. This game writes it down, so the count reads 1 of 5, 2 of 5, and
  so on.
- Whether a bench is busy is no longer a separate note that could disagree with
  what is on the bench — a bench is busy exactly when it holds a recipe.
- The history book had two pages out of order (0.45.4 and 0.45.3 sat above
  0.47.0); they are back in place.

## 0.47.0

### 🧹 Internal

- **A smelter knows it is a smelter.** The design pack has said so since the
  day it was imported, and the game had been reading it as an ordinary lump of
  furniture and throwing that word away. Nothing had noticed, because nothing
  had asked yet.
- A bench keeps no list of what it makes. It asks which recipes name it, so
  adding a recipe later means writing one file and touching nothing else.
- A better bench still makes the humble things: a tier 2 smelter melts tier 1
  bars as well as tier 2 ones. And the list you would be shown is built from
  exactly the same rule that allows the work — a list and a permission that
  disagree is how you end up making something you were never offered.
- Two things a bench cannot be: one that answers to "made by hand", which would
  offer the one list it must never own, and one that works infinitely fast. Both
  now stop the game at the moment the design is read rather than much later.

## 0.46.0

### 🧹 Internal

- The game can now work out whether you can afford a recipe, and how many you
  could make in one go. The scarcest ingredient decides: ore enough for five
  bars and coal enough for one makes one bar.
- One order stops at a hundred, however full your bag is — that ceiling comes
  straight from the design and is a number a player can actually reach.
- Two answers are written down on purpose because the obvious code gets them
  backwards. A thing with NO recipe cannot be made out of nothing, and it
  cannot be made a hundred times either. Both would have been the accidental
  answer, and both would have been silly rather than loud.
- Nothing asks these questions yet. The bench that will ask them is next.

## 0.45.4

### 🧹 Internal

- Nothing in the game changed. A snag in the project's own tools was written
  down: the safety catch that checks how finished work gets filed into the
  history book cannot see one particular way of filing, and the side door that
  gets around it goes right past the catch. Writing a snag down is not the same
  as fixing it — it means the next person meets it on a page instead of by
  surprise.

## 0.45.3

### 🧹 Internal

- Nothing in the game changed. This is tidying in the book where the project
  writes down everything it has ever done. The old version of the game and the
  one being built now were on two separate pages, so the new one looked like it
  was missing the last things the old one learned. It never was: all of that
  was safe the whole time. Now both are on the same page, in order, and the
  book stops pretending something went missing.

## 0.45.2

### 🧹 Internal

- The build diary for making things was corrected before any of it was built.
  It had said that crafting would be what finally lets you place a smelter; it
  turns out the game's own recipes cannot get you there from nothing.

## 0.45.1

### 🧹 Internal

- A note in the build diary about how crafting and building connect was wrong,
  and checking the design pack is what found it. To make a smelter you need
  copper and coal; to dig copper and coal you need a pickaxe; to make a pickaxe
  you need a smelter. Nothing in the game hands you the first one.
- The way out is written down now: you will begin the game holding something.
  Which thing, and the small menu for making things in your own hands, are the
  next pieces of work.

## 0.45.0

### 🧹 Internal

- **Items can have a recipe now.** A thing that is made says what it costs,
  where it is made, how long one takes and how many come out. All four of those
  were already written down in the design pack and had simply never been read.
- Six new things came in from that pack, all of them made at a smelter: a
  copper bar, a moss block, vine cloth, a copper coin, boar leather and palm
  planks. They are drawn as blank placeholders for now.
- A blueprint is now a thing you can make, not just a thing you can put down.
  That was written as a promise in the code months ago and is finally true — the
  smelter blueprint has always carried its price (5 logs, 5 copper ore, 5 coal,
  made in your own hands), and something can read it at last.
- Nothing can be made yet: the bench, the button and the fire come next.

## 0.44.0

### 🧹 Internal

- The build diary closed the placing work: six steps, from an item knowing what
  it builds to a see-through copy showing you where it would land. It also
  wrote down the step that was planned and then deliberately NOT written, and
  why writing it would have been code nothing could reach.
- Two debts are on the page now instead of in somebody's head: nothing in the
  game can put a blueprint in your bag yet, so the manual page about building
  waits for the workbench that will hand you one; and stacking ground on top of
  ground is refused whole rather than half-answered.
- A note inside the code that had gone stale was corrected — it named the wrong
  reason a piece of the design is still missing.

## 0.43.0

### ✨ New

- **The Sort button is here.** It sits at the top right of your backpack, and
  one press puts everything where it belongs: tools first, then the things you
  build, then everything else, with the empty pockets gathered at the back.
- Piles of the same thing join up when you press it. Four sticks and three
  sticks become seven, and a pile too big for one pocket spills into the next
  one rather than being left in bits all over the bag.
- Two of the same kind of tool come out best-first, so your good axe is never
  hiding behind your old one.
- Watch your hand after pressing: the item bar is the same pockets, so what you
  are holding usually changes. The manual page says so too.
- Food and arrows still sort in with the rest — the game does not know them as
  their own kind yet. Their places in the row are already saved, so nothing you
  sort today jumps somewhere strange when they arrive.

## 0.42.0

### 🧹 Internal

- The backpack can now put itself in order. Everything with a place in the
  drawers goes to the front in that order, and the empty pockets end up at the
  back — where empty pockets belong.
- Piles of the same thing join up on the way. Four berries in one pocket and
  three in another become seven in a single pocket; if seven is more than a
  pocket holds, what is left starts the next one, and the fuller pile comes
  first. Tidying is half of what a Sort button is for.
- It only tells the screen about the pockets that actually moved. A pocket that
  was already holding the right thing is left alone, so one press does not
  redraw all thirty. And if the thing in your hand was moved under you, the
  game says so — otherwise you would be holding one thing and swinging another.
- The button that presses it is next.

## 0.41.0

### 🧹 Internal

- The game now knows how to rank one thing against another: which drawer it
  belongs in (a tool, a thing you build, a material), which shelf inside that
  drawer, and how good it is. Nothing presses the button yet — this is the
  table the button will read.
- Seven drawers are written down, though only three have anything to put in
  them today. Food, armour, clothes and arrows keep their places in the row,
  empty, so that nothing shuffles when they arrive — an order that changes
  under the player later is worse than an order that waits.
- Every kind of tool has a place on its shelf, and a kind that does not have
  one stops the game rather than quietly sorting itself to the front.

## 0.40.0

### 🧹 Internal

- **You can see where it would go.** Hold a blueprint and a see-through copy of
  the thing follows your cursor, sitting exactly on the squares it would take —
  **green** where it may go, **red** where it may not. Until the game learns to
  say a refusal out loud, that colour is the whole explanation, which is what
  turns building from a thing that works into a thing you can use.
- The preview cannot lie about the press, because it does not work anything out
  for itself: both ask the same question in the same place and get the same
  answer. A ghost painted green over a square the press would refuse is the one
  bug that would make the whole feature worse than nothing, and it is now the
  kind of bug you would have to delete code to create.
- It goes quiet when it should: nothing in hand that builds, or a panel open in
  front of you, and there is nothing drawn. The world behind that panel keeps
  moving, as it always does — the game still never pauses.

## 0.39.0

### 🧹 Internal

- **Building works.** With a blueprint in your hand, a press puts the thing
  into the world: a smelter lands on the two squares it covers, a bridge turns
  the water you pointed at into planks you can walk on, and one blueprint
  leaves your bag. It is the mirror of chopping a tree down, and the second
  half of the loop this whole phase is about.
- Four things happen in one order, and the order is the promise. The game works
  out which squares the thing would cover; it asks whether it may go there; it
  takes one from your bag; it puts it down. Ask after taking and a refused
  build would cost you the smelter. Put it down before taking and you would end
  up with two.
- A thing you point at is placed where it LOOKS like it is: you aim at the
  square it stands on, and a tall thing reaches up from there rather than down
  from it. And something you build is now the world's, properly — when you walk
  far enough away that the game forgets that part of the world, your smelter
  goes with it instead of hanging around invisibly on ground nobody can use.
- Still nothing puts a blueprint in your bag: the only ones the game knows are
  made at a workbench, and workbenches are the next piece of work. So this
  entry is Internal, not New — the deed is finished and waiting for a way to
  reach it. The manual page comes with the step that makes it reachable.

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
