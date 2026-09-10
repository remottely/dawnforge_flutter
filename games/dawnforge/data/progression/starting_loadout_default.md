---
# What a brand-new player starts the world with, in EVERY game of the family. `StartingLoadoutRules`
# reads this one and grants it once, on a new world; a second
# file beside it becomes a second loadout.
#
# `entries` is a list of `- id: <item id>` + `amount: <n>`, granted through `ItemRegistry`, so
# every id must be a real item. `amount` must be positive: `ItemAmount` refuses
# anything else, and it refuses it at RUNTIME, in the player's first second.
# An EMPTY list is a real answer — starting with nothing is a game's own first lesson.
# `granted_xp: 0` grants none.
#
# Read by: scripts/pipeline/26_import_loadouts_to_json.py
entries:
  - id: t1_item_tool_melee_pickaxe_copper
    amount: 1
granted_xp: 0
---

# The starting loadout

What you are holding the first time you open your eyes in a new world: one copper
pickaxe. It breaks the rocks and the ore that everything else is made from.

DELTA from the Godot pack, and a VALUE on the shared shape rather than a shape of its
own: the spec's copy of this document authors `entries: []`. The authored content has a
cold-start deadlock — ore and coal want a pickaxe, the pickaxe wants a workshop, the
workshop wants ore and coal — and on the delivery track a commented-out debug loadout is
what opens it. Here the pack opens it in the open: one pickaxe, decided 2026-08-31 and
corrected onto the shared document 2026-09-10 (plan FP4.5(g)). The pack-drift guard
(FP0.11) lists this file as a known delta.
