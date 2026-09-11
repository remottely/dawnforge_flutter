---
type: ui_strings
strings:
  ui.inventory.sort:
    en: Sort
    pt_BR: Organizar
    es: Ordenar
  ui.menu.tab.inventory:
    en: Inventory
    pt_BR: Inventário
    es: Inventario
  ui.workstation.select_recipe:
    en: Pick something to make
    pt_BR: Escolha uma coisa para fazer
    es: Elige algo para hacer
  ui.workstation.requires:
    en: 'You need:'
    pt_BR: 'Você precisa de:'
    es: 'Necesitas:'
  ui.workstation.ingredient_have_need:
    en: '{have} of {need} {item}'
    pt_BR: '{have} de {need} {item}'
    es: '{have} de {need} {item}'
  ui.workstation.output_format:
    en: 'Makes {amount} {item}'
    pt_BR: 'Faz {amount} {item}'
    es: 'Hace {amount} {item}'
  ui.workstation.time_seconds:
    en: 'Takes {seconds} seconds'
    pt_BR: 'Leva {seconds} segundos'
    es: 'Tarda {seconds} segundos'
  ui.workstation.quantity:
    en: 'How many:'
    pt_BR: 'Quantas:'
    es: 'Cuántas:'
  ui.workstation.max:
    en: All
    pt_BR: Tudo
    es: Todo
  ui.workstation.start_production:
    en: Make it
    pt_BR: Fazer
    es: Hacer
  ui.workstation.cancel:
    en: Stop
    pt_BR: Parar
    es: Parar
  ui.workstation.producing:
    en: 'Making {item}'
    pt_BR: 'Fazendo {item}'
    es: 'Haciendo {item}'
  ui.workstation.producing_progress:
    en: 'Making {item}: {current} of {total}'
    pt_BR: 'Fazendo {item}: {current} de {total}'
    es: 'Haciendo {item}: {current} de {total}'
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

## Holes in a string

A string with `{name}` in it is filled by `LocalizationSystem.trFormat`, which
replaces each named hole and CRASHES on one it was not given a value for. The Godot
repo writes the same strings with positional `%s`/`%d`; the keys still match, the
holes do not, and the reason is in `localization_system.dart`: a positional hole
cannot be moved, so a language that needs the count before the name has no way to
say so.

## Port deltas in the workstation block

Three, each deliberate. **No `ui.workstation.title`** — the spec builds the panel
with that word and then overwrites it with the station's own name the moment a
station is opened, so here the name is the title and the key has no reader.
**No glyphs** — the spec's buttons read `🔥 START PRODUCTION` and `❌ CANCEL`; rule
19 says a decorative glyph is an icon, not text, and a screen reader says "fire
emoji" out loud. **`ingredient_have_need` is new here**: the spec draws only the
amount a recipe needs and paints it green or red, which tells a colour-blind
seven-year-old nothing. The line says both numbers in words.

## Audience

Rule "7 and up" applies to every line here: short sentences, concrete words, and a
number always explained by what it does to the player. A label the child cannot read
is a label that does not work, whatever it says about the mechanic behind it.
