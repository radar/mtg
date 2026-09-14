---
name: implement-card
description: Implement a Magic: The Gathering card in this repo — look up its full Oracle text, write the CardBuilder DSL implementation and RSpec test, run the suite, and commit. Use whenever asked to implement, add, port, or fix a card.
---

# Implementing a card

Read `CLAUDE.md` first (project root) — it documents the architecture, DSL, and
testing helpers this skill assumes. Then read `docs/card_patterns.md` — a short index
into `docs/patterns/{triggers,choices,static_abilities,costs,zones_and_state,mechanics}.md`,
each covering one slice of common ability patterns with a concrete example file for
most mechanics. Read only the topic file(s) that match what the card's Oracle text
needs (step 2 below) — no need to load all six for a simple card. This skill is the
step-by-step process for turning a card name into a merged commit; those files are the
reference for _how_ to express any given ability once you know what it needs to do.

## 1. Get the FULL Oracle text — every line

Never guess or half-remember a card's text. Look it up, and read all of it. Expand `oracle.rb` with whatever additional information you need.

```bash
bundle exec rake 'find_card[Card Name]'
```

`Magic::Oracle` (`lib/magic/oracle.rb`) is the only interface to card data — never read
`data/*.jsonl` directly, and never use `python` or Scryfall's API to look anything up.

- Names with a comma (e.g. `Dwynen, Gilt-Leaf Daen`) need the comma escaped or rake
  splits it into a second task arg: `bundle exec rake 'find_card[Dwynen\, Gilt-Leaf Daen]'`.
- The task prints a Ruby hash via `.inspect`: `name`, `mana_cost`, `type_line`,
  `oracle_text`, `colors`, `color_identity`, `power`, `toughness`. `oracle_text` is the
  whole rules text with `\n` between lines — **read every line**, not just the first
  ability. Cards routinely pack in a keyword line, an ETB trigger, an attack trigger,
  and a static ability all in one `oracle_text` string; stopping after the first `\n`
  is the most common way to ship a card that's missing half its abilities.
- If `rake find_card` raises `Magic::Oracle::CardNotFound`, the name doesn't match
  exactly (check punctuation/capitalization/hyphenation, e.g. a hyphen the actual card
  name doesn't have, or a missing apostrophe). Use `Oracle#search_cards` to find the
  exact spelling, then retry `find_card` with it:

  ```bash
  bundle exec rake 'search_cards[Soul Jar]'
  ```

  This does a case-insensitive substring match over card names and returns the exact
  names it found — pick the right one and pass it back to `find_card`.
- If you need a field `find_card` doesn't return, add it to `Oracle#find_card`'s
  `slice(...)` call (it already includes `power`/`toughness`) — extend the Ruby class,
  don't work around it.
- Implementing several cards at once: use `find_cards`, not repeated `find_card`
  calls. It reads names from stdin, one per line, and prints each result under
  `=== Name ===` (or `NOT FOUND`):

  ```bash
  printf 'Card One\nCard Two\n' | bundle exec rake find_cards
  ```

State back (to yourself, in the implementation) every line of oracle_text as a
distinct piece of behavior before writing code. If a card has N sentences of rules
text, expect roughly N things to implement — a keyword grant, a static ability, one
or more triggers, an activated ability, etc.

## 2. Survey existing patterns before writing new code

Grep `lib/magic/cards/` for a card with a similar effect (same keyword, same trigger
shape, same kind of choice) and crib its structure. The relevant `docs/patterns/*.md`
file names a concrete example for most mechanics — read the named example, don't
reimplement from scratch. In particular:

- A static, always-on effect (keyword grant, P/T buff, type change) → a
  `Abilities::Static::*` subclass returned from `static_abilities`, not a hand-rolled
  event handler.
- A one-shot trigger (ETB, attack, death, upkeep, etc.) → check for a
  `TriggeredAbility::*` base class first (`EnterTheBattlefield`, `BeginningOfYourUpkeep`,
  `Landfall`, `Death`, `LeaveTheBattlefield`, `CounterAdded`, ...) before subclassing
  `TriggeredAbility` directly.
- Any targeting, modality, or "may" wording → `Magic::Choice::Targeted` /
  `Magic::Choice` / `Magic::Choice::May` / `Magic::Choice::SearchLibrary` /
  `Magic::Choice::Scry` per `docs/patterns/choices.md`, not ad hoc prompting.

Never add card-name checks to shared layers (`ContinuousEffects`, `ActivateAbility`,
etc.) to special-case a card — the static/triggered ability subclasses exist so those
layers stay generic.

## 3. Write the card file

`lib/magic/cards/<snake_case_name>.rb`. No `# frozen_string_literal: true` pragma in
this directory (CLAUDE.md code style — card files are the one exception).

- Keep the `CardBuilder` DSL block (`Creature("Name") do ... end`) to type, cost,
  creature type, P/T, and keywords only.
- If the card needs triggers, choices, static abilities, or `event_handlers`, reopen
  the class afterwards (`class CardName < Creature; ...; end`) — the DSL block runs in
  `Magic::Cards` lexical scope, so a `class Foo` written _inside_ the DSL block lands
  as `Magic::Cards::Foo`, a sibling, not nested inside the card. This is the single
  most common structural mistake; see CLAUDE.md's "DSL block vs class reopening" note.
- Match mana cost format to the card (hash for 1-2 colors, string `cost "{2}{R}{G}"`
  for 3+ colors or hybrid/generic mixes).
- Legendary creatures use `legendary_creature_type "..."`, not `creature_type` plus a
  separate legendary flag.

## 4. Write the spec

`spec/cards/<snake_case_name>_spec.rb`. This directory _does_ use
`# frozen_string_literal: true` (top of file) plus `require "spec_helper"`.

- `include_context "two player game"` for `game`, `p1`, `p2`, `current_turn`.
- `ResolvePermanent("Card Name", owner: p1)` to put it straight on the battlefield;
  `cast_and_resolve(card:, player:)` when you need to go through the stack (e.g. to
  test a `SpellCast`-triggered ability like ward).
- `Card(name)` / `ResolvePermanent(name)` strip non-letters and constantize what's
  left — **every word must be capitalized**, including "of"/"the"/"a" — or the lookup
  raises `NameError`. `"Terror Of The Peaks"`, not `"Terror of the Peaks"`.
- One `it` per line of Oracle text you identified in step 1: base stats/keywords, then
  each triggered/static/activated ability, then any "doesn't affect X" edge case the
  wording implies (e.g. "other creatures" → assert the source itself isn't buffed;
  "you control" → assert an opponent's copy isn't affected).
- `game.tick!` after resolving permanents when a static ability needs a beat to apply,
  matching existing specs for the same ability shape.
- Multi-color costs: `pay_mana(generic: { green: 1 }, green: 1)` for `{1}{G}` paid with
  two green — a bare integer for `generic:` raises `NoMethodError`. `add_mana` just
  wants a flat total: `add_mana(green: 2)`.
- To assert a trigger fired: `game.current_turn.events.find { |e| e.is_a?(Magic::Events::SomeEvent) }`
  — there's no `game.on` subscription hook.

## 5. Run it

```bash
bundle exec rspec spec/cards/<snake_case_name>_spec.rb   # the new spec, iterate here
bundle exec rspec                                        # full suite before committing — catch regressions
```

Don't consider the card done on a green new spec alone; a shared static-ability or
event-handler change can silently break an unrelated card.

## 6. Note anything new in docs/patterns/

If you used or discovered a pattern not already documented, add a bullet to the
relevant `docs/patterns/*.md` file (or `docs/card_patterns.md` for a new subclass base
under `TriggeredAbility`/`Abilities::Static`) in the same commit — that's what keeps
this skill (and those docs) accurate for the next card. Small, additive edits only —
don't restructure a file for one new bullet, and don't merge topic files back together.

## 7. Commit

One commit per card: the card file, the spec file, and any docs/patterns/ addition
together. Message style, from recent history (`git log --oneline`):

```
Implement <Card Name>

<One or two sentences: what it is (type/creature type/keywords) and what its
abilities do, in plain English — not a restatement of the Ruby.>
```

CLAUDE.md's Workflow section describes a branch-per-card + PR flow; in practice,
local sessions in this repo commit each finished card directly to the current branch
(`git log --oneline` shows a linear run of "Implement X" commits on `master`, no merge
commits) — the branch/PR flow shows up on `origin/copilot/*` branches from the GitHub
Copilot cloud agent instead. Default to committing directly to the current branch;
only create a feature branch/PR if the user asks for one.

Stage only the files for this card (plus any docs/patterns/ file touched) — never
`git add -A`, since stray in-progress files from other work may be sitting in the tree.
