# Card Parser

Split out of `CLAUDE.md`. Read this before changing anything in
`lib/magic/card_parser/`, `lib/magic/card_parser.rb` or `lib/magic/card_generator.rb`.

## Usage

```bash
printf 'Name {cost}\nType — Sub\nrules\nP/T\n' | bundle exec rake parse_card
```

writes `lib/magic/cards/<name>.rb` from plain card text (`Magic::CardParser` →
`Magic::CardGenerator`). The task forces stdin to UTF-8 so the `—` in type lines and
chapters parses under a C locale. Unrecognised rules text raises `UnsupportedCard`.

Supported card kinds: creature (also Artifact/Enchantment Creature), instant,
sorcery, enchantment, artifact (incl. legendary), Equipment (needs an `Equip` line),
Aura (needs an `Enchant` line), Saga (needs chapter lines), land and basic land.
Instants and sorceries need effect lines or a modal block. Other type lines/subtypes
raise `UnsupportedCard`.

Parenthesised reminder text is stripped before parsing, and the card's own name in
rules text is replaced with `~`.

## Rules (one per rules-text pattern)

Header, type line and P/T live in `card_parser.rb`; each rules-text pattern is one
file in `lib/magic/card_parser/rules/`: a `Data.define` class that `include Rule`,
found by glob, no registration. Add a mechanic = one rule file +
`spec/card_parser/rules/<rule>_spec.rb`.

- Write rule classes as `class X < Data.define(...)`, not `X = Data.define do ... end`:
  constants in a `Data.define` block leak to the enclosing `Rules` module.
- A rule implements `.parse(line)` (instance or nil) and, for nested classes, `hook`
  (`:static_abilities`/`:activated_abilities`/`:etb_triggers`/`:ltb_triggers`/
  `:death_triggers`/`:event_handlers`), `class_base_name`, `class_source(name)` (plus
  `handled_event` for event handlers).
- A rule can instead supply `body_source` (raw Ruby for the class reopening, e.g.
  `enchant "Creature"`) or `dsl_lines` (lines for the DSL block, e.g. `equip [...]`).
- `kinds` limits a rule to some card kinds; `Rule::PERMANENT_KINDS` lists the kinds
  that become permanents.
- `.merge(rules)` combines every instance one card produced (several keyword lines,
  saga chapters, a modal block) or splits one (an anthem with both a buff and
  keywords becomes two static abilities).
- Several triggers on one event are fine: the generator emits
  `{ Event => [Trigger1, Trigger2] }` (`Permanent#dispatch_event_handlers` takes an
  array).

What the rules cover:

- `SpellEffect`: an instant's or sorcery's effect lines, merged into one `EffectList`.
- `Modal`: "Choose one —" plus "• <effects>" lines → a `ModeN < Mode` class per bullet
  and `modes Mode1, ...`. How many modes may be chosen ("one or both") isn't enforced.
- `Trigger`: "<trigger>, <effects>" from its `KINDS` table, one `Kind` row per
  trigger (pattern, class name, `TriggeredAbility` base, hook, event,
  `should_perform?` condition, allowed card kinds): When ~ enters, When ~ dies, When ~
  leaves the battlefield, a/another creature [you control / an opponent controls]
  dies, another creature you control enters, landfall, your upkeep, your end step,
  ~ attacks, and you cast a <type>[ or <type>] spell (`non<type>` → `!spell.type?`).
  A new trigger is one row. A leading ability word ("Landfall — ") is dropped.
- `Chapter`: saga chapters (`I — ...`, `II, III — ...`), merged into
  `ChapterN < Saga::ChapterAbility` classes and `def chapters`; chapters must be
  I, II, III... without gaps.
- `ActivatedAbility`: "<costs>: <effects>[ Activate only as a sorcery.]". Costs go to
  `Costs::Parser` as a `costs "..."` string (`~` → `{this}`; only mana, `{T}`,
  `Sacrifice ~`/`a creature`, `Exile ~`, `Discard a card`); the sorcery restriction
  becomes `requirements_met? = game.can_cast_sorcery?(controller)`. Mana abilities
  stay with the TapForMana rules, since "Add ..." isn't an effect.
- `Anthem`: "[Other] creatures you control get +N/+N[ and have <keywords>]." /
  "... have <keywords>." → `PowerAndToughnessModification` / `KeywordGrant` static
  abilities. `TribalLord` handles "Other <type>s you control get +N/+N."
- `EntersWithCounters`: "~ enters with N +1/+1 counters on it." → the
  `enters_with_counters "+1/+1", N` class macro (`Card#entering_counters`, added by
  `Permanent.resolve` before the permanent enters).
- Lands: `EntersTapped` (→ `enters_tapped`), `TapForMana`, `TapForManaPerPermanent`,
  `TapForManaChoice` ("{T}: Add {W} or {U}.", "{R}, {G}, or {W}", "one mana of any
  color" → `choices ...`).
- Also: `Keywords` (`Keywords.phrase` reads "flying, first strike, and haste"),
  `Equip`, `Enchant`.

## Effects

One-sentence game effects are reusable classes in `lib/magic/card_parser/effects/`
(`include Effect`; `.parse(text)`, `target_choices`, `resolve_call`; `definitions`
returns Ruby for a constant the call needs, e.g. `CreateToken`'s `Token.create`
class). Current effects: damage to a target or each opponent, draw, gain/lose life,
destroy/exile target (`PermanentTarget`: creature/artifact/enchantment/land, [you
control / an opponent controls]), discard, +1/+1 counters, until-end-of-turn pumps and
keyword grants for ~ / a target creature / [other] creatures you control (`Pump`),
return target [type] card from your graveyard to your hand, creature tokens, copy
tokens, scry.

- An effect refers to its own card/permanent as `Effect::THIS`, which `EffectList`
  expands per context (`self` in a spell, `source` in an activated ability, `card` in a
  mode, `actor` in a trigger or inside a Choice). Never write `self`/`actor`/`source` in
  an effect directly.
- Effect code runs inside a card, a `Mode`, an `ActivatedAbility`, a
  `TriggeredAbility`, a `Saga::ChapterAbility` or a `Choice`, all of which have
  `trigger_effect`, `controller`, `game` and `battlefield`; use only those
  (`game.opponents(controller)`, not `opponents`).
- `resolve_call` may be several lines (a `do ... end` block); `EffectList` indents them.

## EffectList

Turns effect text into Ruby: the whole text as one effect if that parses (`CopyTokens`
spans two sentences), else each sentence (also split on ", then" and ", and you"). A
"you may <effect>" sentence becomes an `OptionalEffect` (also tried with an implied
"You"), and following "If you do, <effect>" sentences join it.

Rendering (`render`) walks the effects to the first *choice point* (an
`OptionalEffect`, a choice effect with `choice_base`/`choice_class_name`/`choice_args`
such as `Scry`, or, where the target isn't already in scope, a targeted effect) and
emits a Choice class holding everything from there on, rendering the rest recursively
inside it, so choices nest (`MayChoice` > `TargetChoice`, `ScryChoice` >
`TargetChoice`).

- `MayChoice < Magic::Choice::May` runs the optional effects on `resolve!` (accept =
  `game.resolve_choice!`) and the effects after them in `finish`, called on accept and
  from `decline!` (`game.skip_choice!`). Effects after an optional effect that itself
  makes a choice raise (they'd run before it resolved).
- A choice effect with nothing after it uses its `choice_base` directly.
- `TargetChoice < Magic::Choice::Targeted` is added with `game.add_choice`, which
  auto-resolves a lone legal target and needs `choice_amount`.
- `spell_source(this:)` renders an instant/sorcery (`"self"`), mode (`"card"`) or
  activated ability (`"source"`): the target is chosen on cast, so `target_choices` +
  `resolve!(target:)`, and a targeted effect after a choice point raises.
- `trigger_source(entry:)` renders a triggered/chapter ability's `call`/`resolve!`; if
  it targets anywhere but its first effect, it starts with
  `return if (<targets>).none?`: an ability with no legal target does nothing.
- At most one targeted effect per spell, mode or ability.

## Testing

- Specs that eval generated cards use `spec/card_parser/card_parser_helpers.rb`
  (`generate`, `load_card`; evals at `TOPLEVEL_BINDING`, since `module Magic` inside a
  helper method would nest under the helper).
- String-only specs of generated code miss runtime errors (`battlefield.artifacts`
  didn't exist until a modal spec cast one), so give each new effect or rule an
  in-game spec in `spec/card_parser/generated_*_spec.rb`.
- `lib/magic/cards/opt.rb` is parser output: after changing `EffectList`, regenerate it
  and diff.
- To check a pattern against real behaviour, generate an existing hand-written card
  into `lib/magic/cards/`, run its spec, then restore the original. Cards checked this
  way: Temple of Mystery, Jungle Hollow, Dismal Backwater, Mind Stone, Enchantress's
  Presence, Phyrexian Arena, Beast Whisperer, Firebrand Archer, Kessig Flamebreather,
  Glorious Anthem, Titanic Growth. Generate from the card's exact text (cost, P/T):
  a mismatch there fails the card's spec for reasons unrelated to the parser.
