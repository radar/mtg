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
rules text is replaced with `~`, as is "this creature" / "this artifact" / "this
permanent" etc., which current card text uses instead of the name.

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
  saga chapters, a modal block) or splits one (a static buff with both a P/T change and
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
  `should_perform?` condition, allowed card kinds). "When" and "Whenever" are
  interchangeable. Rows: ~ enters, ~ enters or attacks (`merge` splits it into an enters
  trigger and an attacks trigger with the same effects), ~ enters or dies (same, with a dies trigger), ~ dies, ~ leaves the
  battlefield, a/another creature [you control / an opponent controls] dies, a/another
  creature is exiled from the battlefield (`Events::LeftTheBattlefield` to exile), another
  creature you control enters, landfall, you / an opponent / a player gain(s) life
  (`Events::LifeGain`), your upkeep, beginning of combat on your turn
  (`Events::BeginningOfCombat`), your end step [`, if another creature entered the battlefield under your control this turn`], each end step [`, if you put a counter on a creature this turn`], ~ attacks, you attack
  (`event.active_player == controller && event.attacks.any?`), ~ deals combat damage
  to a player (`Events::CombatDamageDealt`), the last <type> counter is removed from ~
  (`Events::CounterRemoved`; the type must be one `Magic::Counters[]` knows), and you
  cast a <type>[ or <type>] spell (`non<type>` → `!spell.type?`), you cast a spell during an opponent's turn (`you? && !controllers_turn?`), your first main phase
  (`Events::FirstMainPhase`), ~ becomes tapped (`Events::PermanentTapped`), and the
  creature-type-qualified forms: another <Type> [or <Type>] you control dies, a <Type>
  creature you control dies, [~ or] another <Type> [or <Type>] you control enters (the
  types are any in `Magic::Types::Creatures`; `TYPE_CHECK` renders
  `event.permanent.type?("Goblin")`). A new trigger is one row. A leading ability word ("Landfall — ") is dropped. "When ~ is turned face up"
  isn't supported: the engine has no face-down permanents (morph, disguise,
  manifest).
- `Chapter`: saga chapters (`I — ...`, `II, III — ...`), merged into
  `ChapterN < Saga::ChapterAbility` classes and `def chapters`; chapters must be
  I, II, III... without gaps.
- `ActivatedAbility`: "<costs>: <effects>[ Activate only as a sorcery.]". Costs go to
  `Costs::Parser` as a `costs "..."` string (`~` → `{this}`; only mana, `{T}`,
  `Sacrifice ~`/`a creature`, `Exile ~`, `Discard a card`, `Remove N <type> counters from ~` [`and sacrifice it`,
  as a second cost; the type must be one `Magic::Counters[]` knows]); the sorcery restriction
  becomes `requirements_met? = game.can_cast_sorcery?(controller)`. Mana abilities
  stay with the TapForMana rules, since "Add ..." isn't an effect.
- `StaticBuff`: "[Other] creatures you control get +N/+N[ and have <keywords>]." /
  "... have <keywords>.", and the same for "Equipped creature" (Equipment only) and
  "Enchanted creature" (Auras only) and "~" (a creature buffing itself) →
  `PowerAndToughnessModification` / `KeywordGrant` static abilities
  (`applicable_targets { ... }`, or `applies_to_target` for the attached creature). A
  line with both becomes two abilities. "gets +N/+N for each <thing>" uses `Count`
  (`lib/magic/card_parser/count.rb`: "[other] <type> you control", "card in your hand",
  "[<type>] card in your graveyard") and renders `def power_modification = N * <count>`,
  recomputed with continuous effects. `TribalLord` handles
  "Other <type>s you control get +N/+N."
- `EntersWithCounters`: "~ enters with N <type> counters on it." (+1/+1 on creatures,
  or any type `Magic::Counters[]` knows, e.g. time) → the
  `enters_with_counters "+1/+1", N` class macro (`Card#entering_counters`, added by
  `Permanent.resolve` before the permanent enters).
- Lands: `EntersTapped` (→ `enters_tapped`), `TapForMana`, `TapForManaPerPermanent`,
  `TapForManaChoice` ("{T}: Add {W} or {U}.", "{R}, {G}, or {W}", "one mana of any
  color" → `choices ...`; "any color in your commander's color identity" →
  `def choices = controller.commander.color_identity`).
- `TokenDoubler`: "If an effect would create one or more tokens under your control, it
  creates twice that many of those tokens instead." → a `ReplacementEffect` on
  `Effects::CreateToken` (see `AnointedProcession`).
- `Changeling`: the keyword line lists `Abilities::Static::Changeling` itself in
  `static_abilities`. A rule does that by returning `class_reference` (an existing class
  name) instead of a nested class from `class_source`.
- Also: `Keywords` (`Keywords.phrase` reads "flying, first strike, and haste"),
  `Equip`, `Enchant`.

## Effects

One-sentence game effects are reusable classes in `lib/magic/card_parser/effects/`
(`include Effect`; `.parse(text)`, `target_choices`, `resolve_call`; `definitions`
returns Ruby for a constant the call needs, e.g. `CreateToken`'s `Token.create`
class). Current effects: damage to a target or each opponent, draw, gain/lose life,
destroy/exile target (`PermanentTarget`: [another] target
creature/artifact/enchantment/land/nonland permanent [you control / an opponent controls]; "another"
leaves out `Effect::THIS`), flicker ("exile <target>, then return that card to the
battlefield under its owner's control"), discard, +1/+1 counters on a target, each
creature you control or ~, until-end-of-turn pumps and
keyword grants for ~ / a target creature / [other] creatures you control, optionally
"for each <thing>" before or after "until end of turn", counted once as it resolves
(`Pump`, with `Count.parse(text, this: Effect::THIS)`),
return target [type] card from your graveyard to your hand, put target [type or type] card
from a/your graveyard onto the battlefield under your control (`Reanimate`), each opponent
sacrifices a [type or type] (`EachOpponentSacrifices`; its `SacrificeChoice` class comes from
`definitions`), search your library for a basic land / <Type> card(s) onto the battlefield
[tapped], then shuffle (`SearchLibrary`, a choice effect), put a <type> counter on ~
(`AddCounters`; named counter types only on ~), remove N <type> counters
from ~ (skipped if it has too few), sacrifice ~ / it, creature tokens ("with changeling" gives the token `Abilities::Static::Changeling`), copy tokens,
scry, look at the top N cards and take a <Type>, <Type>, or <Type> card into your hand with the rest on the bottom (`LookAtTopCards`, `Choice::LookAtTopCards`), mill (`Mill`: you, each opponent, target player/opponent), mill then may return a <type>/permanent card from among them (`MillThenReturn`, `Choice::ReturnFromAmong`), discard N cards unless you discard a <type> card (`DiscardUnless`, `Choice::DiscardUnless`), "If that creature would die this turn, exile it instead" after a targeted effect (`ExileInsteadIfDies`, `Permanent#register_turn_replacement`), two-target damage "~ deals N damage to any target and M damage to any other target" (`DealDamageTwoTargets`: `multi_target?`, `distinct_targets?`, `resolve!(targets:)`; instants and sorceries only), counter target [creature/noncreature] spell [with mana value N] (`CounterSpell`), "choose up to one [other] target creature. Until end of turn, that creature has base power and toughness N/M [and gains all creature types]" (`BaseStatsUntilEndOfTurn`; `up_to_one?` makes its `TargetChoice` skippable and never auto-resolved), surveil (`Surveil`, a `Choice::Surveil`, like scry), untap (`Untap`: target, ~, "each other <Type> you control"), blight (`Blight`: you
(a `Choice::Blight`, and "If you do" effects run only if a creature was there to blight), each
opponent or a target opponent; `Costs::Blight` is paid with `pay_blight(creature)`). A creature
type is also a target: "target Elf you control", "target attacking Goblin you control",
"another target Merfolk you control" (`PermanentTarget`). Together, `EntersWithCounters`, an upkeep "remove a time counter" and a
last-counter "sacrifice it" generate vanishing-style creatures; suspend (cards in exile)
isn't supported.

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

`ConditionalEffect` (`lib/magic/card_parser/conditional_effect.rb`, not an `Effects::` class) wraps "[Then] if there is a <Type> card in your graveyard, <effects>": the effects must be plain (no choice or target) and render inside an `if` on the graveyard. `EffectList.parse_sentence` tries it first.

Turns effect text into Ruby: the whole text as one effect if that parses (`CopyTokens`
spans two sentences), else each sentence, and a sentence that isn't one effect as a
whole is split into clauses on ", then" and ", and you" ("exile it, then return it"
stays one effect; "draw a card, then discard a card" is two). A
"you may <effect>" sentence becomes an `OptionalEffect` (also tried with an implied
"You"), and following "If you do, <effect>" / "When you do, <effect>" sentences join it;
"If you don't, <effect>" runs when it is declined (`OptionalEffect#if_you_dont`). Every
clause of an "If you do" sentence stays conditional ("you draw a card and lose 1 life").

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
- Returning a card to the battlefield from another zone: `Permanent.resolve` moves the
  card itself too (out of exile, graveyard, ...), unless the entry was replaced or it's
  a token/copy, so generated code just calls `Permanent.resolve` (`Effects::Flicker`).
- `lib/magic/cards/opt.rb` is parser output: after changing `EffectList`, regenerate it
  and diff.
- To check a pattern against real behaviour, generate an existing hand-written card
  into `lib/magic/cards/`, run its spec, then restore the original. Cards checked this
  way: Temple of Mystery, Jungle Hollow, Dismal Backwater, Mind Stone, Enchantress's
  Presence, Phyrexian Arena, Beast Whisperer, Firebrand Archer, Kessig Flamebreather,
  Glorious Anthem, Titanic Growth, Short Sword, Swiftfoot Boots, Setessan Training.
  Soulherder is covered by
  `spec/card_parser/generated_soulherder_spec.rb` instead: its hand-written spec names
  its own choice classes and expects a lone target to be offered rather than chosen
  automatically (`game.add_choice`). Generate from the card's exact text (cost, P/T):
  a mismatch there fails the card's spec for reasons unrelated to the parser.
