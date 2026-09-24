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
  trigger and an attacks trigger with the same effects), ~ becomes tapped (`Events::PermanentTapped`), ~ dies, ~ leaves the
  battlefield, a/another creature [you control / an opponent controls] dies, a/another
  creature is exiled from the battlefield (`Events::LeftTheBattlefield` to exile), another
  creature you control enters, landfall, your upkeep, beginning of combat on your turn
  (`Events::BeginningOfCombat`), your end step, each end step, ~ attacks, you attack
  (`event.active_player == controller && event.attacks.any?`), ~ deals combat damage
  to a player (`Events::CombatDamageDealt`), the last <type> counter is removed from ~
  (`Events::CounterRemoved`; the type must be one `Magic::Counters[]` knows), and you
  cast a <type>[ or <type>] spell (`non<type>` → `!spell.type?`), you gain life
  (`Events::LifeGain`), you draw a card (`Events::CardDraw`), and you sacrifice / a player
  sacrifices a/another <type or permanent> (`Events::PermanentSacrificed`). A new trigger is one
  row. A leading ability word ("Landfall — ") is dropped. "When ~ enters, if it was
  kicked, ..." adds `actor.kicked?` to the enters trigger's `should_perform?` (a
  spell's version is in EffectList). "When ~ is turned face up"
  isn't supported: the engine has no face-down permanents (morph, disguise,
  manifest).
- `Chapter`: saga chapters (`I — ...`, `II, III — ...`), merged into
  `ChapterN < Saga::ChapterAbility` classes and `def chapters`; chapters must be
  I, II, III... without gaps.
- `ActivatedAbility`: "<costs>: <effects>[ Activate only as a sorcery.]". Costs go to
  `Costs::Parser` as a `costs "..."` string (`~` → `{this}`; only mana, `{T}`,
  `Sacrifice ~`/`a creature`, `Exile ~`, `Discard a card`); the sorcery restriction
  becomes `requirements_met? = game.can_cast_sorcery?(controller)`, and "Activate only
  once each turn." becomes `once_each_turn`. Mana abilities
  stay with the TapForMana rules, since "Add ..." isn't an effect.
- `StaticBuff`: "[Other] creatures you control get +N/+N[ and have <keywords>]." /
  "... have <keywords>.", and the same for "Equipped creature" (Equipment only) and
  "Enchanted creature" (Auras only) and "~" (a creature buffing itself) →
  `PowerAndToughnessModification` / `KeywordGrant` static abilities
  (`applicable_targets { ... }`, or `applies_to_target` for the attached creature). A
  line with both becomes two abilities. "... as long as <condition>" adds `conditions { }`
  from `Condition` (`lib/magic/card_parser/condition.rb`: you control a/another <type>,
  N or more <types>, no [other] <types>; it's [not] your turn; you have no cards in hand;
  you have / an opponent has N or more/less life; N or more cards in your graveyard;
  ~ is tapped/untapped/equipped/enchanted). "gets +N/+N for each <thing>" uses `Count`
  (`lib/magic/card_parser/count.rb`: "[other] <type> you control", "card in your hand",
  "[<type>] card in your graveyard") and renders `def power_modification = N * <count>`,
  recomputed with continuous effects. `TribalLord` handles
  "Other <type>s you control get +N/+N."
- `AttachedRestriction`: "Enchanted/Equipped creature can't attack [or block] / can't
  block / can't become untapped / doesn't untap during its controller's untap step /
  can't have counters put on it / its activated abilities can't be activated", clauses
  joined by "and" or commas → methods on the Attachment card (`can_attack?`,
  `prevents_untapping?`, `prevents_counters?`, ...), which `Permanent` checks.
- `CostReduction`: "[<type>[ and <type>] / non<type>] spells you cast cost {N} less to
  cast." → a `ManaCostAdjustment` static ability.
- `BlockingRestriction`: "~ can't block." / "~ can't be blocked." → `can_block?` /
  `can_be_blocked?` returning false, which `CombatPhase#can_block?` checks.
- `EntersWithCounters`: "~ enters with N <type> counters on it." (+1/+1 on creatures,
  or any type `Magic::Counters[]` knows, e.g. time) → the
  `enters_with_counters "+1/+1", N` class macro (`Card#entering_counters`, added by
  `Permanent.resolve` before the permanent enters).
- Lands: `EntersTapped` (→ `enters_tapped`), `TapForMana`, `TapForManaPerPermanent`,
  `TapForManaChoice` ("{T}: Add {W} or {U}.", "{R}, {G}, or {W}", "one mana of any
  color" → `choices ...`).
- `Keywords`: a line of comma-separated keywords → `keywords :flying, ...`. Keywords
  with a value: toxic N and hexproof from <colour> go into the same `keywords` call as
  objects (`Keywords.list` takes `Keyword` instances as well as symbols); ward {N} /
  ward—pay N life → `ward generic:`/`ward life:`; protection from <colour>[ and from
  <colour>], multicolored or a card type (plural) → `protections [...]`; kicker,
  flashback and cycling with a mana cost → `kicker_cost`, `flashback Costs::Mana.new(...)`,
  `cycling`. Ward, protection, kicker, flashback and cycling each allow only one per
  card; other costs (ward—discard, kicker—sacrifice, landcycling) are unsupported.
  `Keywords.phrase` (used by pumps and static buffs) still reads only the plain keywords
  in `KNOWN` ("flying, first strike, and haste").
  Hexproof and hexproof from don't stop targeting yet (roadmap E2), so their specs only
  check that the keyword is there.
- `changeling` is a plain keyword (`Types#type?` treats it as every creature type).
  `StaticBuff` also reads "Equipped/Enchanted creature gets +N/+N and is all creature
  types." (`merge` splits off `def grants_all_creature_types? = true` as a body).
- Also: `Equip`, `Enchant`.

## Effects

One-sentence game effects are reusable classes in `lib/magic/card_parser/effects/`
(`include Effect`; `.parse(text)`, `target_choices`, `resolve_call`; `definitions`
returns Ruby for a constant the call needs, e.g. `CreateToken`'s `Token.create`
class). Current effects: damage to a target or each opponent, draw, gain/lose life,
destroy/exile/tap/untap/bounce target (`PermanentTarget`: [another] target
creature/artifact/enchantment/land/[nonland] permanent [you control / an opponent
controls]; "another" leaves out `Effect::THIS`), counter target [<type>/non<type>] spell
(targets `game.stack.spells`), mill, search your library for a basic land/land/creature
card (onto the battlefield [tapped] or into your hand; a `Choice::SearchLibrary` choice
point), flicker ("exile <target>, then return that card to the
battlefield under its owner's control"), discard, +1/+1 counters on a target, each
creature you control or ~, until-end-of-turn pumps and
keyword grants for ~ / a target creature / [other] creatures you control, optionally
"for each <thing>" before or after "until end of turn", counted once as it resolves
(`Pump`, with `Count.parse(text, this: Effect::THIS)`),
return target [type] card from your graveyard to your hand, create Treasure/Food/Clue
tokens (the engine's `Magic::Tokens::Treasure`/`Food`/`Clue`), remove N <type> counters
from ~ (skipped if it has too few), sacrifice ~ / it, creature tokens, copy tokens,
scry, surveil (`Choice::Surveil`, a choice point like scry), gain control of a target
[until end of turn] (`Permanent#gain_control_until_eot!`, undone at cleanup), and "If
that creature is a <type>, it [also] <effect on it>" (`IfTargetIsType`), and "~ /
enchanted creature / equipped creature fights [up to one] target creature ..." (`Fight`,
`Permanents::Creature#fights!`). Together, `EntersWithCounters`, an upkeep "remove a time counter" and a
last-counter "sacrifice it" generate vanishing-style creatures; suspend (cards in exile)
isn't supported.

- "It" / "that creature" ("Untap it.", "It gains haste until end of turn.") is
  `PermanentTarget::PRONOUN`: the effect's `earlier_target?` is true and it acts on
  `target`, the target of an earlier effect in the same ability. `EffectList.parse`
  rejects one with no targeted effect before it; in a multi-target spell it uses the
  `targets[i]` of the last targeted effect before it; in a trigger it runs inside that
  effect's `TargetChoice`. Tap, untap and pumps also take "enchanted creature" /
  "equipped creature" (`PermanentTarget::ATTACHED`, `Effect::THIS.attached_to`).
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
spans two sentences), else each sentence, and a sentence that isn't one effect as a
whole is split into clauses on ", then" and ", and you" ("exile it, then return it"
stays one effect; "draw a card, then discard a card" is two). A
"you may <effect>" sentence becomes an `OptionalEffect` (also tried with an implied
"You"), and following "If you do, <effect>" sentences join it.
An "If this spell was kicked, <effects>." sentence (`~` too, since "this spell" becomes
`~`) becomes a `KickedEffect`: its effects render inside `if kicker_cost.paid? ... end`
(`card.kicker_cost` in a mode). It works only on instants, sorceries and modes; a
triggered or activated ability raises `UnsupportedCard`. Kicked effects can't target
(targets are chosen on casting), and a kicked effect that makes a choice (scry, "you
may") must come last, or the effects after it would run before the choice resolved.
"… instead" sentences ("it deals 4 damage instead") aren't supported.

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
  `resolve!(target:)`, and a targeted effect after a choice point raises. Several
  targeted effects make it `multi_target?` with one list of choices per target and
  `resolve!(targets:)`, each effect's `target` rewritten to its `targets[i]`
  (`ActivatedAbility#valid_targets?` checks each target against its own list).
- "up to one target ..." (`PermanentTarget` `up_to`, an effect's `optional_target?`) is
  only supported in triggered abilities (`spell_source` raises). Its `TargetChoice` has
  `choice_amount = 0..1` (so `Stack#add_choice` doesn't pick a lone target for you),
  and effects after it run in `finish`, from `resolve!`, from `decline!`
  (`game.skip_choice!`) or straight away when there is nothing to target.
- `trigger_source(entry:)` renders a triggered/chapter ability's `call`/`resolve!`. Each
  targeted effect is its own choice, nested in turn (`TargetChoice`, `TargetChoice2`,
  ...). Unless its only target is its first effect, it starts with
  `return if <targets>.none? || ...`: an ability missing a legal target does nothing.

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
  Glorious Anthem, Titanic Growth, Short Sword, Swiftfoot Boots, Setessan Training,
  Cancel, Lorescale Coatl, Herald of the Pantheon, Rampant Growth (its spec names the
  hand-written choice class; the rest passes).
  Soulherder is covered by
  `spec/card_parser/generated_soulherder_spec.rb` instead: its hand-written spec names
  its own choice classes and expects a lone target to be offered rather than chosen
  automatically (`game.add_choice`). Generate from the card's exact text (cost, P/T):
  a mismatch there fails the card's spec for reasons unrelated to the parser.
