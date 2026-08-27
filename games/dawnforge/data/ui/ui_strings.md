---
type: ui_strings
strings:
  ui.menu.tab.inventory:
    en: Inventory
    pt_BR: Inventário
    es: Inventario
---

# Interface strings

The pack's SSOT for text the **interface** says, as opposed to text the **content**
says. An item's name lives in its own `.md` (`translations:` + `<field>_key`,
pipeline step 05's first source); the word on the button that opens the bag lives
here, because no authored world object owns it.

Rule 19 is what makes this file necessary: every human-readable string reaches the
screen through `tr()` with a key, in every locale. Rule 5 is what makes it strict:
step 05 reports a key translated in one locale and missing in another as a HOLE, and
`tr()` on a key that is not here CRASHES. There is no locale fallback anywhere in the
chain — a missing string is an unwired literal, and it should explode while it is
still cheap.

## Shape

Each entry is `key: {locale: text}`. The key IS the mapping key, which is the one
difference from an almanac document: an almanac field derives its key from
`<field>_key` because the same field name (`display_name`) repeats across hundreds
of files, while an interface string has nothing to derive from and names itself.

Keys are hierarchical and read as a path — `ui.<surface>.<thing>`. Reuse the
spelling the Godot repo already uses for the same string wherever one exists
(`tessera_project`'s `translations_static.csv`): the two engines drawing the same
interface should not disagree about what the string is called.

## Delta from the Godot repo

There, these live in `games/<game>/generated/locales/translations_static.csv` — a
hand-authored CSV inside a *generated* folder, merged by that repo's step 05. Here
that location is unavailable on purpose: rule 17 forbids hand-editing anything under
a generated root, and rule 31 makes `games/<game>/data/` the pack and therefore the
only place a human authors content. So the file moved into the pack and took the
pack's format (Markdown + YAML) with it. The keys are unchanged, which is the part
that has to match.

## Audience

Rule "7 and up" applies to every line here: short sentences, concrete words, and a
number always explained by what it does to the player. A label the child cannot read
is a label that does not work, whatever it says about the mechanic behind it.
