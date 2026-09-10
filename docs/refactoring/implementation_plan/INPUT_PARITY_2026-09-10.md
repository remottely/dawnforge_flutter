# Input parity — the 51 actions the spec binds, and the 22 this port answers

> **How to use this document.** `CLAUDE.md` rule 12 says every behaviour added for one
> input mode must be reflected in all the others, and rule 11 says the reading of a
> device happens in one file. Both are stated as law and neither has ever been measured.
> This is the measurement, plus one item per gap, each executable without asking anything.
>
> **Scope:** the action vocabulary, the device each action can be sent from, the context
> each is allowed to fire in, and the machinery that keeps those three honest.
>
> **Explicitly out:** what any verb DOES. `interact` reaching a workstation is FP4.5(e),
> `action_dodge` needing a movement state is FP7.7 — this document only says which
> presses exist, from which device, and who is allowed to answer them.
>
> **Measured at `0.67.0`** against `tessera 0.440.4`, suite green at **391 tests** — a
> count that includes FP4.5(e)'s three uncommitted test files, so the number to compare
> against is the next commit's, not this one's. Every `file:line`
> below was true at that version and must be re-grepped before editing. **FP4.5(e) is in
> flight in the working tree as this is written and moves exactly three rows of §1**, each
> marked *in flight* below: `interact` gains `E`, and the hotbar step gives `E` up for
> `[` / `]`. Those rows are written as they stand at `0.67.0` and the commit that lands
> the verb updates them — the table, not the git log, is this document's state (§10).
>
> Related: `FLUTTER_PORT_PLAN_2026-08-25.md` (FP4.3a's written omission (iii), FP5.1,
> FP5.2, FP7.7), `AUTOMATION_DEBT_2026-09-10.md` (the checker this owes is an AD-shaped
> script), `TEST_TRACEABILITY_2026-09-10.md` (`InputHelper` IS named in `test/`).

## Progress

| ID | Item | Gate | State |
|:--|:---|:---|:---|
| IP1 | The action catalog as a type | every press names an action, not a key | pending |
| IP2 | The context table and the guard at the source | a hotbar key does nothing with the bag open | pending |
| IP3 | `onKeyEvent` stops claiming every key | a text field can be typed into | pending |
| IP4 | The 26 owed actions, filed under the step that gives each a subject | each row leaves §1's owed column | pending, per-step |
| IP5 | The gamepad, the whole third device | one action arrives from a pad | pending, needs `IP-D1` |
| IP6 | Touch, the mode the spec does not have | every action reachable or declared unreachable | pending, needs `IP-D2` |
| IP7 | `check_input_action_contexts.py`, the Dart twin | a share with no arbiter fails the suite | pending |
| IP8 | The 42 action labels and the shortcut surface | the controls panel reads in both languages | pending, with FP5.2 |
| IP9 | `InputSettings` — rebinding and the four preferences | a binding changed at runtime survives a restart | pending, needs `IP-D3` |

`IP1` is §3, `IP2` §4, `IP3` §5, `IP6` §6, `IP7` §7, `IP8` and `IP9` §8. `IP4` has no
section of its own because §1 IS its body — one row leaves the owed column per commit, and
§2 names the three rows that are a disagreement rather than a gap. `IP5` has none either:
it is blocked on `IP-D1` and nothing can be written about it until that fork is answered.

---

## 1. The action table

The spec's `games/dawnforge/project.godot` `[input]` block declares **51 actions**.
`InputActionCatalog` (`tessera/src/core/shared/systems/input/input_action_catalog.gd`)
classifies all 51 into a context and labels 42 of them — the nine unlabelled are the
three extra `move_*` directions, the four `aim_*`, `ui_accept` and `jump`, each of which
reads under a label a sibling already carries.

**Device coverage, spec side:** 37 actions reachable from the keyboard, 2 from a mouse
button, 36 from a gamepad. **No action is bound to a touch event** — the `[input]` block
contains zero `InputEventScreenTouch` and zero `InputEventScreenDrag`. Touch is this
track's own mode and §6 is where that bill comes due.

**Device coverage, here:** 20 from the keyboard, 1 from a pointer-down, **0 from a
gamepad**, 1 from a finger. Everything reachable lives in `input_helper.dart` (209 lines
at `0.67.0`), which is rule 11 holding.

Legend: **K** keyboard · **M** mouse button · **P** pad · `—` no subject in this repo.

### 1.1 UI navigation

| Action | Spec | Here | Owed to |
|:---|:--|:---|:---|
| `ui_accept` | K P | — | FP5.1, with the first focusable surface |
| `ui_cancel` | K P | Escape → `cancelPressed` (`input_helper.dart:121`), routed once through `UIStateMachine.requestCancel` (rule 25) | pad binding only |

### 1.2 Movement and aim

| Action | Spec | Here | Owed to |
|:---|:--|:---|:---|
| `move_up` `move_down` `move_left` `move_right` | K P | WASD + arrows, POLLED once per fixed step (`input_helper.dart:192-208`, read at `dawnforge_game.dart:321-323` behind `isGameplayEnabled`) — rule 24 held: movement is a state, not an event | pad stick |
| `aim_up` `aim_down` `aim_left` `aim_right` | P | — | FP7.7 (iii), the gamepad's virtual cursor |

### 1.3 Gameplay verbs

| Action | Spec | Here | Owed to |
|:---|:--|:---|:---|
| `action_primary` | M P | a pointer-down anywhere in the world (`input_helper.dart:184-187`) — the tap both AIMS and ACTS, which is what makes touch structural rather than a second path | a mouse BUTTON code (left vs right is not distinguished today), pad |
| `action_secondary` | M P | — | FP7.7, with the second verb the hand can hold |
| `action_dodge` | K P | — | FP7.7, needs a movement state to dodge into |
| `interact` | K P | — | **FP4.5(e), *in flight*: gains `E`, and with it a second touch verb the spec has no equivalent for — one finger, two meanings, chosen by what is under the tap** |
| `pickup` | K P | — | FP4.4/FP7.12: pickups are contact-only here (`pickup.tick` at `dawnforge_game.dart:328-335`); the spec's `hold_to_pickup` preference has no subject |
| `tactical_focus` | K P | — | FP7.7 |

### 1.4 The voxel dimension — never crossing

| Action | Spec | Why not |
|:---|:--|:---|
| `jump` | K P | a flat world has no up. The spec's own arbiter entry says it: `jump` and `interact` share Space, and the DIMENSION decides which reader exists. This track builds one dimension, so the share cannot occur |
| `camera_rotate_left` `camera_rotate_right` | K P | the stepped turn a fixed eye needs to see behind a cliff. Study §3 cut the third dimension; the arbiter for `aim_*` vs `camera_rotate_*` is the view mode, and this track has one |

Three of the 51 are therefore **not debt**, exactly as three quarters of the automation
gap is not debt (`AUTOMATION_DEBT_2026-09-10.md` §6). **26 are owed; 22 have a subject.**

### 1.5 Hotbar

| Action | Spec | Here | Owed to |
|:---|:--|:---|:---|
| `hotbar_1` … `hotbar_10` | K | digits 1–9 and 0 → `hotbarSlotPressed` (`input_helper.dart:66-77, 96-100`), by position WITHIN the visible page | — |
| `hotbar_next` `hotbar_prev` | P | **Q / E → `hotbarStepped`** — a KEYBOARD binding the spec's map does not have. The verb agrees, the device does not. ***In flight*: `[` / `]`**, because FP4.5(e) needs `E` for the reach | see §2, `IP4` |
| `hotbar_swap_prev` `hotbar_swap_next` | K P | — | FP5.1, moving the selected stack rather than the selection |
| `hotbar_row_prev` `hotbar_row_next` | K P | **PageUp / PageDown → `hotbarPageFlipped`** (`input_helper.dart:101-108`). The spec binds Tab / Shift | a binding disagreement, not a missing verb |
| `hotbar_drop` | P | — (drag-to-world exists on the pointer, `inventory_panel_view.dart:145-190`) | FP5.1 with the pad |

### 1.6 Menu toggles and slot manipulation

| Action | Spec | Here | Owed to |
|:---|:--|:---|:---|
| `inventory` | K | **I or Tab** → `inventoryToggled` (`input_helper.dart:117-120`) | pad; and Tab collides with the spec's `hotbar_row_prev` (§2) |
| `toggle_config` | K P | — | FP5.2, the settings surface |
| `open_journal` | K P | — | FP7.6, the quest journal |
| `label_edit_tap` | K P | — | FP7.12, a chest that can be named |
| `inventory_split` `inventory_drag` `inventory_confirm` `inventory_qty_up` `inventory_qty_down` | P | — | FP5.1: the pad's whole way of using a bag. The pointer has drag-and-drop instead, which is why these five are pad-only in the spec too |
| `input_modifier` | K | **Shift**, polled at the instant of a drop (`input_helper.dart:60-64`) | the spec moved this OFF Shift onto C, because there `hotbar_row_next` owns Shift. Here PageDown owns the row, so Shift is free and the collision does not exist |
| `map_zoom_in` `map_zoom_out` | K P | — | no map exists here; unscheduled |

### 1.7 Debug

| Action | Spec | Here | Owed to |
|:---|:--|:---|:---|
| `debug_add_hour` `debug_skip_day` | K | — | FP4.4(a) / FP7.1, once a clock exists to advance |
| `debug_next_biome` | K | — | FP7.3, once there is a second biome to step to |

---

## 2. What the table shows that a rule alone could not

**Three bindings disagree with the spec and none of the three is a mistake.** `Q`/`E`
step the hotbar here (`[`/`]` once FP4.5(e) lands) and nothing there; `PageUp`/`PageDown` flip the row where the spec
uses `Tab`/`Shift`; `Shift` is the split modifier here and `C` there. Each divergence is
locally correct — and together they mean **`Tab` means "open the bag" on one track and
"previous hotbar row" on the other**. That is not a bug today. It becomes one the moment
a player moves between the two builds, and it is the kind of thing that is free to decide
now and expensive to decide after a manual page has printed it. `IP4` files it.

**The port's device story is inverted from the spec's.** There, 36 of 51 actions answer a
gamepad and none answers a finger. Here, one answers a finger and none answers a gamepad.
Rule 12 reads as broken in one direction only if you read it from one side.

---

## 3. IP1 — the action catalog as a type

The spec's catalog is three tables over a string key: `LABELS` (42), `CONTEXTS` (51) and
`ARBITRATED_SHARES` (6). Ported to Dart it becomes an **enum**, because rule 4 forbids the
string-keyed dictionary the GDScript version is forced into, and rule 18 forbids probing.

Two things get DELETED in the crossing, and both deletions are the point:

1. **The duplicated `Context` enum.** The spec redeclares `UIStateMachine.UIState` inside
   the catalog with a generator assert holding the copies identical, for one stated
   reason: *GDScript cannot reach another script's enum from a const expression.* Dart
   can. `UIState` (`ui_state_machine.dart:5`) already mirrors it value for value —
   `gameplay, menu, dialog, overlay, textEntry` — so the port uses that enum directly and
   the assert that guards the copy has nothing to guard.
2. **The `LABELS`/`CONTEXTS` split.** Two tables over the same key exist there because a
   GDScript const cannot hold a struct. An `enum InputAction` with a label key and a
   context set as members holds both, and an action that forgets one cannot compile.

The exhaustiveness the spec buys with a build failure — *an action absent from the table
is a build failure, not a default* — Dart gets from a switch over an enum with no default
arm. That is the same guarantee at zero runtime cost.

## 4. IP2 — the context table, and the guard that is in the wrong place

**Evidence.** `_raiseIntents` (`input_helper.dart:95-124`) emits every intent
unconditionally. `isGameplayEnabled` is asked in four scattered places instead
(`dawnforge_game.dart:321`, `actor_player.dart:60`, `actor_player.dart:80`,
`build_ghost_renderer.dart:71`) and `hotbar_view.dart:70-72` asks it nowhere. So with the
bag open, pressing `3` still changes what is in the player's hand, and `Tab` still toggles
a panel that a dialog may be standing on top of.

Nothing is visibly broken yet, because the two intents that would DO something —
the swing and the movement — are each guarded at their own end. That is precisely the
shape the spec's catalog exists to prevent: **the context of a press decided at the
subscriber is one decision per subscriber, and a new subscriber starts by forgetting it.**

The item: `InputHelper` asks `InputActionCatalog.isActive(action)` before it emits, once,
at the source. The four scattered reads collapse into it, except the movement poll, which
is a state and not an intent and stays where it is.

## 5. IP3 — the key that is always claimed

`onKeyEvent` (`dawnforge_game.dart:339-345`) forwards the event and returns
`KeyEventResult.handled` for **every key, always**. Today that costs nothing, because
nothing else in the tree wants a key. It stops being free at the first text field — the
world-name entry FP6.4 needs — which is exactly why the spec's context enum has a
`TEXT_ENTRY` member and ours has `textEntry` with no subject.

The item: return `handled` only when the catalog claims that key in the active context,
and `ignored` otherwise. It is three lines, and it must land before the first text field
rather than as the bug report that text field files.

## 6. IP6 — touch, the mode with no spec

The spec binds nothing to touch. Every touch behaviour this track has, it invented:
a tap that both aims and acts (`input_helper.dart:184-187`). That single gesture answers
one of 51 actions.

This is the one section of this document that **cannot be closed by copying**, and it is
also the section that decides whether this port runs on a phone at all. The 26 owed
actions each need a gesture or a declared "unreachable by finger", and a mode that answers
some actions and silently ignores others is rule 12 broken in the direction nobody checks.
`IP-D2` is the fork; the recommendation is a declared subset with an on-screen surface for
the rest, because a phone has no room for 51 gestures and pretending otherwise produces a
map nobody can hold.

## 7. IP7 — the checker

`tessera/scripts/project/check_input_action_contexts.py` fails on four inconsistencies:
the context enum drifting from the UI state enum, an action present in one file and not
the other, two actions sharing a binding inside one context without a named arbiter, and
a listed arbiter whose actions no longer collide.

Failure 1 disappears with the duplicated enum (§3). Failures 2–4 still apply, and 4 is the
one worth naming: **a stale exemption hides the next real collision on that button.** The
Dart twin reads the binding table out of `InputActionCatalog` itself rather than a
`project.godot`, so it is a pure-Dart test rather than a Python script — which puts it in
`test/`, not `scripts/`, and rule 23 does not apply to it.

## 8. IP8 and IP9 — the labels and the settings

**IP8.** The 42 `ui.input.action.*` keys and the 5 `ui.input.context.*` keys are authored
in NEITHER pack — they live in the GDScript table and are translated at read time. Zero
`ui.input.` keys exist in `games/dawnforge/data/ui/` on either track. So the shortcut
panel's strings are not an import (`PACK_IMPORT_MAP_2026-09-10.md` has no batch for them);
they are 47 new keys authored here, in three locales, with FP5.2's controls surface.

The spec's own note is worth carrying: those labels *used to be English sentences doubling
as their own key*, so every one missed the table and the panel read English in every
locale — and the failure is silent, because a missing key renders as itself.
`check_translation_keys.py` (FP0.17) is the guard that already exists here.

**IP9.** `InputSettings.cs` is 89 lines and holds two unrelated things: a rebinding store,
and four player preferences that are not about input at all (`music_volume`,
`ui_sfx_volume`, `sfx_volume`, `show_floating_notifications`, `show_ui_notifications`,
`smart_stack_to_storages`, `hold_to_pickup`). The volumes are FP7.9's, the notification
flags are FP5.1's, and the two behaviour flags belong to the systems they name. Only
rebinding is this document's, and rebinding has no engine to lean on: Godot has an
`InputMap` that persists; Flutter has none, so a rebind table is ours to build or to
refuse. `IP-D3`.

---

## 9. What never crosses

| What | Why |
|:---|:---|
| `project.godot`'s `[input]` block | there is no InputMap in Flutter. The binding table IS the Dart enum, which is why `IP7`'s checker is a test and not a script |
| `input_icons.gd`'s glyph lookup | it reads `InputMap.action_get_events` for names; the Dart twin reads the enum. The spec's own header records that its predecessor kept a second hand-written table which disagreed with the bindings in four places — the lesson crosses, the code does not |
| `jump`, `camera_rotate_left`, `camera_rotate_right` | §1.4 |
| `state_input_dodge/idle/move.gd` | player movement states are FP7.7's, not this document's; they read actions, they do not define them |

## 10. What an item owes

Every item here lands with, in the same commit:

1. its row in §Progress moved, with the version it landed at;
2. a test — the catalog's exhaustiveness and any arbiter it adds (`IP7`);
3. both changelogs (rule 34), `### 🧹 Internal` while the verb is unreachable;
4. a manual line ONLY when the player can perform the press — a controls page that lists
   a binding nothing answers is the lie rule 34 exists to prevent;
5. the `tr()` keys in all three locales when the action gains a label (rule 19);
6. §1's row updated in this document — the table, not the git log, is the state.

---

## Decision register

Each fork blocks the item named, carries a recommendation, and is **not decided by this
pass**. IDs are prefixed `IP-D` so they cannot be confused with the port plan's `D-n`
(`L-013`).

### `IP-D1` — how a gamepad reaches this repo at all

Blocks `IP5`, and through it 36 of the spec's 51 actions and FP7.7 (iii)'s virtual cursor.
Flutter ships no gamepad API. The options are a package (`gamepads` is the maintained
one and binds the platform HID layers), Flame's own raw key path plus a platform channel,
or declaring the pad out of scope for the study track.

**Recommendation:** decide it before FP5.1 builds a surface, not after. A bag designed for
a pointer gets `inventory_split`/`inventory_drag`/`inventory_confirm` retrofitted into it;
a bag that knows those five actions are coming is the same amount of work once. If the
answer is "out of scope", say so in the study's scope cuts and rule 12 stops reading as
broken — an undecided pad is worse than a declined one.

### `IP-D2` — what touch answers

Blocks `IP6`. Either every action gets a gesture, or a declared subset does and the rest
are unreachable by finger with that stated in writing.

**Recommendation:** the subset. Name it in this document, and let the checker of `IP7`
fail on an action that is neither reachable nor declared unreachable — the same shape as
`AUTOMATION_DEBT`'s N/A-with-a-reason, which is what makes a gap stop being re-derived.

### `IP-D3` — whether bindings can be changed at all

Blocks `IP9`. Godot persists an InputMap for free; Flutter does not, so runtime rebinding
is a table, a surface, a serializer and a conflict-checker this repo would own outright.

**Recommendation:** refuse it for now and say why in the study's scope cuts. Rebinding is
an accessibility feature with real weight, but it is weight against a game whose keyboard
layout is not yet settled — §2's three disagreements are still open. Revisit when the
bindings stop moving, which is FP5.2 at the earliest.
