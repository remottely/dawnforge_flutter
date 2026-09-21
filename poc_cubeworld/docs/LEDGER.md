# Architecture Ledger — poc_cubeworld

> Where rule 21 writes. One entry per structural observation found mid-task that was
> **not** the task. Four mandatory fields: `Lens`, `Evidence` (`file:line`), `Cost of
> leaving it`, `Found while`. An entry is recorded here and **not fixed in the commit
> that found it**.
>
> **IDs are `CL-nnn`, sequential, never reused.** The prefix is deliberate: the 2D track's
> ledger (`../docs/refactoring/LEDGER.md`) owns `L-nnn`, and its own `L-013` records what
> happens when two ID spaces sit one hyphen apart — "D-4" and "D4" naming unrelated
> things. This project is a different product under a different rule set (`CLAUDE.md`),
> so it gets a different space rather than a shared counter that neither repo can hand
> out. A citation of `CL-001` is unambiguous from either side.

## Open

### CL-001 · The socket layout was shared, the socket was not

- **Lens:** packages / duplicated engine layer
- **Evidence:** `voxel_engine` ships a TCP layer — `packages/voxel_engine/lib/src/net/net_host.dart` (`NetHost.bind`, peer numbering from 2, `onJoin`/`onMessage`/`onLeave`) and `connection.dart` (newline-delimited JSON) — and `grep 'voxel_engine/net' lib/` returns nothing. The POC keeps its own: `lib/src/game/net.dart:93-97` (`ServerSocket? _server`, `Socket? _client`, `Map<int,_Peer> _peers`, `int _nextPeer = 2`, `StringBuffer _clientBuf`), `:173` `host()`, `:194` `join()`, `:213` `_feed`, `:230` `_sendTo`, `:238` `_broadcast` — the same shape, peer 2 included. The contrast is inside one subject: the *save* layout was shared correctly, `lib/src/world/voxel_world.dart:279-285` taking `EditDeltaCodec` from the engine with the comment "the byte layout lives in voxel_core's `EditDeltaCodec`". The same reasoning was available for the wire and was not applied.
- **Cost of leaving it:** roughly 80 of `net.dart`'s 1,312 lines are the duplicate — the other 1,200 are Dawnforge's protocol (mounts, boats, carts, chests, bobbers) and belong in the app. But the 80 are the framing and reconnect layer, the part where a bug is a hung session rather than a wrong number, and it is now debugged twice from two sets of symptoms. It is also the entry that is cheapest to close: the protocol does not move, only the transport under it, and the engine's version is already covered by `packages/voxel_engine/test/net/net_test.dart` where the POC's is covered by nothing.
- **Found while:** 2026-09-21 — answering why `lib/` imports `voxel_game` in only two files.

### CL-002 · The fixed-step loop is six lines, written twice, to the same constants

- **Lens:** packages / duplicated kit layer
- **Evidence:** `lib/src/game/game.dart:701-706` banks the frame and spends it — `_acc += math.min(dt, 0.1)`, `while (_acc >= fixedStep && steps < 4)`. `packages/voxel_game/lib/src/loop/fixed_step_loop.dart:23` is the same algorithm with the same numbers (`maxFrame` 0.1, `maxSteps` 4, `step` 1/60), plus `:37` `alpha`, the sub-step fraction for smoothing a pose between two ticks, which the app does not have.
- **Cost of leaving it:** small in lines and large in what it signals — this is the one piece of `voxel_game` that carries no Dawnforge flavour at all, so if even this is not shared, nothing above `CharacterMotor` ever will be, and `voxel_game`'s top half stays a package validated only by its own example (`CL-005`). The concrete loss is `alpha`: the app cannot interpolate a pose between steps without reimplementing a third copy of the bank.
- **Found while:** 2026-09-21 — answering why `lib/` imports `voxel_game` in only two files.

### CL-003 · Touch input landed in the POC and never rose; the kit's input is desktop-only by omission

- **Lens:** kit API / rule 13
- **Evidence:** `grep -rn touch packages/voxel_game/lib` finds only `net.touch` and `flow.touch` — no finger anywhere in the kit. Stage 44 (`51b3e7b6`, HEAD) put a full touch scheme in the app instead: `lib/src/game/input.dart:85` `_tapSlop`, `:91` `touchMineDelay`, `:220` `touchTapAttacks`, `:240` `touchMove`, `:248` `setTouchHeld`, `:257` `touchHotbar`, `:265` `_beginTouchMining`, `:271` `_forgetTouch`, `:374` `onPointerCancel`. The two classes are otherwise twins: `lib/src/game/input.dart` and `packages/voxel_game/lib/src/input/input_map.dart` open with the same seven imports and expose the same API (`down`, `justPressed`, `takeWheel`, `takeLook*`, `endTick`, `capture`, `release`, `onKey`, `onPointer{Down,Up,Move,Signal}`, `releaseKeys`, `dispose`) over the same private state (`_wheel`, the drag, `wantCapture`, `captureLost`); the only structural difference is that the kit is `InputMap<A>` and the app is `GameInput` fixed to `GameAction`. The kit's `VoxelGameWidget` has no `onPointerCancel` either, so it cannot even drop a lost pointer.
- **Cost of leaving it:** rule 13 (input parity) is satisfied in the POC and broken in the product, which is the wrong way round — a game written on `voxel_game` today cannot be played on a phone, on a kit whose stated target is every platform Flutter supports. And the longer the app's `GameInput` grows apart, the less the kit's version is a generalisation of it and the more it is a competing implementation that happens to share an API; the touch scheme was designed against a real device once, and doing it a second time from the kit's side will produce different slop, a different mine delay and a different tap rule.
- **Found while:** 2026-09-21 — answering why `lib/` imports `voxel_game` in only two files.

### CL-004 · `Worlds` and `WorldSaves` are homonyms, not a duplicate pair

- **Lens:** naming / false duplicate
- **Evidence:** `packages/voxel_game/lib/src/world/world_save.dart:29` `WorldSaves` writes and reads one `VoxelGame` (its `edits.bin` and `game.json`). `lib/src/game/worlds.dart:44` `Worlds` is the slot *catalogue* — `WorldEntry`, display name, seed text, mode, class, playground flag, play time, `slugOf`, `validateFilename`, `rename`, `delete`, `lastPlayedLabel`. Different subjects that read the same folder; the part they genuinely share (the byte layout) is already single-sourced in the engine's `EditDeltaCodec`.
- **Cost of leaving it:** nothing is wrong today, and that is exactly why this is written down — the pair looks like `CL-001` and `CL-002` from a file listing, and the obvious "consolidation" merges a save codec with a save-slot browser, dragging the app's display metadata into a published package that has no business knowing what a playground is. The cost of leaving it is the refactor somebody eventually proposes; one entry here is cheaper than reverting it.
- **Found while:** 2026-09-21 — answering why `lib/` imports `voxel_game` in only two files.

### CL-005 · The kit's whole top half is exercised only by an example nothing runs

- **Lens:** testing / kit surface
- **Evidence:** `DefaultHud` (108 lines), the kit's `InventoryScreen` (181) and `VoxelGameWidget` (`packages/voxel_game/lib/src/ui/voxel_game_widget.dart:256,260`, which wires both) are reachable from exactly one place: `packages/voxel_game/example/lib/main.dart:4`, a one-line app. `packages/voxel_game/test/` holds three files (`game_test.dart`, `goal_test.dart`, `net_game_test.dart`) and none of them mounts a widget. The POC never touches them — `lib/src/ui/game_view.dart:128` builds its own `InventoryScreen` (352 lines) and its own HUD (809).
- **Cost of leaving it:** the split itself is right (rule 7 — the kit ships a default, the game ships Dawnforge's), but the default has no witness. Rule 18 says a stage is done when it was seen running, and this surface has been seen running once, by whoever last opened the example by hand. A `flutter_scene` upgrade, a shader bundle rebuild or an `InputMap` change can break the kit's only out-of-the-box screen and every one of the 381 tests still passes, because the app that would have noticed draws its own.
- **Found while:** 2026-09-21 — answering why `lib/` imports `voxel_game` in only two files.

### CL-006 · `ScreenKind` exists twice, and the project's own rule 12 names it as one

- **Lens:** rules / two concepts under one name
- **Evidence:** `CLAUDE.md` rule 12 reads "`ScreenKind` + `Game.gameplay` gate *input*", stated as a single mechanism. There are two: `lib/src/game/game.dart:50` declares `enum ScreenKind { none, inventory, pause, death, journal, trade }` and `:303` `bool get gameplay => screen == ScreenKind.none && !player.isDead && started`, read across `lib/src/ui/game_view.dart:127-191`; `voxel_game` has its own screen state behind `VoxelGame.openScreen`, which `voxel_game_widget.dart:260` reads. A rule cites one name and two implementations answer to it.
- **Cost of leaving it:** this is the one on the list that cannot be closed by delegation — the app's gate is entangled with its 6,379-line `Game`, and `VKD5` decided on purpose that the POC moves onto the kit only after the kit exists, not during. So the cost is not the duplication but the rule text: a session that reads rule 12 and goes looking for *the* `ScreenKind` finds whichever it greps first, and can satisfy the rule in the kit while breaking it in the app or the reverse. Until the two converge, the rule should say which one it is talking about.
- **Found while:** 2026-09-21 — answering why `lib/` imports `voxel_game` in only two files.

### CL-007 · Nothing in the suite compares the app's copy with the kit's, and the divergence is already in HEAD

- **Lens:** testing / drift between the two codebases
- **Evidence:** the suite is 179 + 168 + 10 + 4 + 20 = 381 tests (`CLAUDE.md` §Execution Workflow, green at `b0b94ebd`). None of them puts `lib/src/game/game.dart:701-706` next to `FixedStepLoop.advance`, `lib/src/game/input.dart` next to `InputMap`, or `lib/src/game/net.dart` next to `NetHost`. `CL-003` is the proof this matters: stage 44 added a whole input mode to one of a twinned pair and the suite stayed green, at the commit that is HEAD.
- **Cost of leaving it:** the repository's answer to "are the app and the kit still the same thing underneath?" is currently a human reading two files side by side, which is how `CL-001`, `CL-002` and `CL-003` were found in the first place — by hand, three days after the last one landed. Every extraction step (`VK`, `VC`) was gated on probes precisely because a test could not see it; the pairs that were *not* extracted have neither a probe nor a test. A `flutter test` that fails when the app's loop constants stop matching the kit's is cheap and would have caught the input drift the day it happened.
- **Found while:** 2026-09-21 — answering why `lib/` imports `voxel_game` in only two files.

### CL-008 · The decision register still answers questions about packages that no longer exist

- **Lens:** docs / stale SSOT
- **Evidence:** `docs/VOXEL_KIT_PLAN_2026-09-18.md:415` (`VKD1`) records the decision as "**Five packages**, the kit on top" and justifies it with "a game that only wants the world takes `voxel_worldgen` + `voxel_scene`"; `:418` (`VKD4`) says the noise is copied "into `voxel_worldgen`". `VC1` (`8a2b9853`) folded `voxel_worldgen` and four others into `voxel_engine` and `VC2` (`e349d46e`) renamed `voxel_audio`, so both decisions cite packages that were deleted two days later. `docs/VOXEL_CONSOLIDATION_PLAN_2026-09-19.md` records the new answer but does not mark the old one superseded, and `VKD1` is the entry a reader reaches first, since it is the register's first row.
- **Cost of leaving it:** a decision register is consulted precisely when somebody is about to re-litigate a settled question — `CLAUDE.md` rule 4 ("a new package earns its place by an optional heavy dependency, never by being a different subject") is the *current* answer and it contradicts `VKD1` as written. The failure mode is a future session splitting a subject back out on the authority of the register, which is doing exactly what it was built to prevent.
- **Found while:** 2026-09-21 — answering why `lib/` imports `voxel_game` in only two files.
