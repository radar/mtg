# CLAUDE.md

Guidance for Claude Code when working in this repo.

## Quick Reference

### Build & Dependencies
```bash
bundle install              # Install Ruby gems and dependencies
```

> **Note for Copilot cloud agent**: `bundle` is not on PATH. Use this pattern instead:
> ```bash
> # First, install gems (only needed once per session):
> HOME=/tmp ruby /usr/lib/ruby/gems/3.2.0/gems/bundler-2.4.19/libexec/bundle install --path /tmp/vendor/bundle
>
> # Then run commands via:
> HOME=/tmp ruby /usr/lib/ruby/gems/3.2.0/gems/bundler-2.4.19/libexec/bundle exec rspec
> ```

### Testing
```bash
bundle exec rspec           # Run all tests
bundle exec rspec spec/cards/island_spec.rb           # Run a single test file
bundle exec rspec spec/cards/island_spec.rb:10        # Run a specific test at line 10
bundle exec rspec -k "taps for"                       # Run tests matching a pattern
```

RSpec integration tests. See `spec/spec_helper.rb` for helpers/shared contexts.

### Code Style
- `# frozen_string_literal: true` at top of `lib/magic/*.rb` and `spec/**/*_spec.rb`
- Card files in `lib/magic/cards/` do **not** use the frozen_string_literal pragma
- Follow Ruby conventions

### Workflow
- Each card: own commit, branch, PR.
- Branch name: kebab-case card name (e.g. `terror-of-the-peaks`).
- After implementing, note new patterns/gotchas in CLAUDE.md in the same commit.

## High-Level Architecture

MTG simulation engine, Ruby, no UI. Event-driven architecture with state machines.

### Core Game Flow

1. **Game** (`lib/magic/game.rb`): Central coordinator, two-player games
   - **Turn** state machine (`lib/magic/game/turn.rb`): untap → upkeep → draw → main → combat → end
   - Delegates to **Stack** for spell resolution, **Permanent** management on **Battlefield**
   - Manages **Players** with libraries, hands, graveyards, exile zones
   - Notifies interested parties of game **Events** that trigger abilities

2. **Cards & Permanents**: Two-part model
   - **Card** (`lib/magic/card.rb`): Card in any zone (hand, graveyard, library, exile, stack)
   - **Permanent** (`lib/magic/permanent.rb`): Card on battlefield with state (tapped, damage counters, attachments, etc.)
   - `Permanent.resolve()` moves card from stack to battlefield

3. **Card Implementation**: CardBuilder DSL (`lib/magic/card_builder.rb`)
   - All cards in `lib/magic/cards/` use DSL
   - Base types: `Creature`, `Instant`, `Sorcery`, `Enchantment`, `Aura`, `Saga`, `Artifact`, `Equipment`
   - Simple cards: cost + stats only (e.g. `StorySeeker`)
   - Complex cards: extend base class with triggered/activated abilities and event handlers (e.g. `AcademyElite`)
   - **DSL block vs class reopening**: DSL block (`Enchantment("Name") do ... end`) runs in `Magic::Cards` lexical scope — any `class Foo` inside lands in `Magic::Cards::Foo`, not nested in the card class. Keep DSL block to type/cost only; define trigger classes, choice classes, `event_handlers` in a class reopening (`class CardName < Enchantment; ...; end`). Example: `SanctumOfCalmWaters`, `SanctumOfFruitfulHarvest`.

### Events & Abilities

Event-driven architecture for triggered and state-based abilities:

- **Events** (`lib/magic/events/`): 47+ types (e.g. `CardDraw`, `CreatureAttacked`, `BeginningOfUpkeep`)
- **TriggeredAbility** (`lib/magic/triggered_ability.rb`): `should_perform?` condition + `call` execution
- **Saga** (`lib/magic/cards/saga.rb`): Adds lore counter on ETB and again at controller's first main phase each turn (`FirstMainPhaseTrigger`). Lore counter fires `Events::CounterAddedToPermanent` → chapter ability via `CounterAdded`. Final chapter → saga sacrifices itself.
- **ActivatedAbility** (`lib/magic/activated_ability.rb`): Player-triggered, with costs and effects
- **Event Handlers**: Cards define `event_handlers` hash mapping event class → ability class

### Actions & Spell Resolution

**Actions** (`lib/magic/actions/`): Player decisions and game operations:
- `Cast`: Places spell on stack with optional targeting/flashback
- `PlayLand`: Land from hand to battlefield
- `ActivateAbility`: Activates card abilities with cost payment
- `DeclareAttacker` / combat mechanics

**Stack** (`lib/magic/stack.rb`): LIFO spell resolution
- **Choices**: Modal effects and decisions during resolution
- **Effects**: Side effects of resolution (draw cards, deal damage, move permanents)

### Effects System

**Effects** (`lib/magic/effects/`): State changes during resolution:
- `DrawCards`, `DealDamage`, `DestroyTarget`, `CreateToken`, `MoveCardZone`, `AddCounter`, etc.
- Modified by **Replacement Effects** before applying (redirect damage, replace draw)
- **ReplacementEffectResolver** (`lib/magic/game/replacement_effect_resolver.rb`): if/then logic before effect executes

### Zones & Player State

- **Battlefield** (`lib/magic/zones/battlefield.rb`): Permanents with combat tracking
- **Hand** (`lib/magic/zones/hand.rb`)
- **Library** (`lib/magic/zones/library.rb`): Deck with draw mechanics
- **Graveyard** (`lib/magic/zones/graveyard.rb`)
- **Exile** (`lib/magic/zones/exile.rb`)

**Player** (`lib/magic/player.rb`): Owns zones, tracks life, mana pool, counters
- Methods: `draw!`, `play_land()`, `cast()`, `activate_ability()`, `take_action()`

### Mana & Costs

- **Mana** (`lib/magic/mana.rb`): white, blue, black, red, green, generic, colorless
- **Costs** (`lib/magic/costs/`): Mana, tap, sacrifice, counter removal
- **ManaAbility** & **TapManaAbility**: Land activation
- DSL: `cost generic: 1, white: 1`

### Permanents: Creatures, Planeswalkers, Enchantments

- **Creature** (`lib/magic/permanents/creature.rb`): Power/toughness, combat, damage tracking
- **Planeswalker** (`lib/magic/permanents/planeswalker.rb`): Loyalty counters, loyalty abilities
- **Enchantment** (`lib/magic/permanents/enchantment.rb`): Static abilities
- **Modifications**: Attachments (equipment, auras), keyword grants, power/toughness mods

### Types & Keywords

- **Types** (`lib/magic/types.rb`): Creature, Instant, Artifact, etc.
- **Keywords** (`lib/magic/cards/keywords.rb`): lifelink, flying, haste, etc.
- **Keyword Handlers** (`lib/magic/cards/keyword_handlers/`): Rules implementation

### Autoloading

Zeitwerk (`lib/magic.rb`): auto-loads from `lib/magic/**/*.rb`. Define class → auto-loaded.

### Dependencies

- `state_machines`: Turn structure/phase transitions
- `zeitwerk`: Auto-loading
- `dry-types`: Mana type definitions
- `rspec`: Testing
- `pry`: Debugging

## Testing Patterns

**Shared Context** (`spec/spec_helper.rb`): `include_context "two player game"` gives:
- `game`: Two-player game (p1, p2), 7-card libraries
- `current_turn`: Turn state and phase transitions
- Helpers: `go_to_main_phase!`, `skip_to_combat!`, `go_to_combat_damage!`
- `ResolvePermanent(name, owner: p1)`: Create and resolve a permanent
- `cast_and_resolve(card:, player:)`: Cast and resolve immediately

**Card Helper**: `Card(name)` and `ResolvePermanent(name)` strip non-letter chars and look up constant. Every word must be capitalised — `"Terror Of The Peaks"` not `"Terror of the Peaks"`. Lowercase words (of, the, a) must be uppercased or lookup fails.

**Testing Sagas**: Turns alternate, so controller's next main phase needs two `game.next_turn` calls + `go_to_main_phase!`. Each chapter in nested `context`. Example:
```ruby
before { 2.times { game.next_turn }; go_to_main_phase!; game.stack.resolve!; game.tick! }
```

**Integration Tests**: Test game mechanics and card interactions, not unit methods. Example: `spec/cards/island_spec.rb`

**Paying multi-color mana costs in specs**: `pay_mana` for generic costs requires a hash specifying which color fills the generic slot — `pay_mana(generic: { green: 1 }, green: 1)` for a `{1}{G}` cost paid with two green. `add_mana` just needs the total pool — `add_mana(green: 2)`. Passing a plain integer for generic (e.g. `generic: 1`) raises `NoMethodError: undefined method 'values' for 1:Integer`.

**Checking for fired events in tests**: Use `game.current_turn.events.find { |e| e.is_a?(Magic::Events::SomeEvent) }` — there is no `game.on` subscription method.

**Testing a `SpellCast`-triggered ability (e.g. "whenever you cast a creature spell")**: Use `player.cast(card:) { |a| a.pay_mana(...) }` (calls `game.take_action`), not the `cast_and_resolve` spec helper — `cast_and_resolve` does a raw `game.stack.add(action)` and skips `Actions::Cast#perform`, which is where `Events::SpellCast` actually gets notified. A spec built on `cast_and_resolve` for a spell-cast trigger will silently see the trigger never fire.

**Putting a specific card on top of the library in a spec**: Use `player.library.add(card)` (default `placement: 0`, so it lands on top), not `player.library.unshift(card)`. `Zone#add` sets `card.zone = self`; `unshift` is a raw delegated Array method that skips it. A card with an unset `zone` silently fails to be removed from its zone when later moved (`move_to_hand!`/`resolve!` no-op on `from.remove` because `from` is nil), so it ends up duplicated instead of moved.

## Common Card Ability Patterns

**Ward (additional life cost)**: Use `ward life: N` DSL in the card definition block. Automatically registers a `SpellCast` trigger that checks `opponents.include?(event.player) && event.targets.include?(actor)` and calls `trigger_effect(:lose_life, target: event.player, life: N)`. If the card also defines `event_handlers` in a class reopening, call `super.merge(...)` to preserve the ward trigger. Example: `TerrorOfThePeaks`.

**Targeted ETB trigger ("deals damage to any target")**: Add `Magic::Choice::Targeted` subclass to card's class reopening. Define `choices` (e.g. `game.any_target`) and `resolve!(target:)`. In trigger's `call`, push instance onto `game.choices`. Pass data needed at resolution (e.g. entering creature's power) via constructor. Example: `TerrorOfThePeaks::DamageChoice`.

**Simple ETB effect (no targeting/choice)**: Use the `enters_the_battlefield` DSL block inside the card definition — no class reopening needed. Example: `SetessanTraining` draws a card on ETB with `actor.trigger_effect(:draw_cards, number_to_draw: 1)`.

**Modal ETB choice (pick one of N effects)**: Subclass `Magic::Choice` directly. Define `resolve!(mode:)` with a `case mode` switch. Use symbol constants (e.g. `COUNTER = :counter`). In the ETB trigger's `call`, push an instance onto `game.choices`. Example: `Trufflesnout`.

**Optional ETB (may do X)**: Wrap the real choice in a `Magic::Choice::May` subclass — override `resolve!` to push the inner choice onto `game.choices`. Example: `AlpineHoundmaster::MaySearchChoice`.

**"Check land" (as this land enters, you may reveal a [type] card from hand; if you don't, it enters tapped)**: `Card#resolve!`/`Permanent.resolve` read `enters_tapped?` synchronously *before* the permanent exists, so there's no window there for a player choice — don't try to gate `enters_tapped?` on a `revealed` flag set elsewhere (nothing will ever set it, and the land silently always enters tapped). Instead, make `enters_tapped? = true` unconditionally, then handle the reveal as a normal `etb_triggers` + `Magic::Choice::May`-wrapped `Magic::Choice::Targeted` (same "may" ETB pattern as above) whose `resolve!(target:)` calls `controller.reveal(target)` and `actor.untap!` — untapping just after entry is functionally identical to never having been tapped, since nothing gets priority in between. Guard the ETB trigger with the inner choice's `choices.any?` (the "if you can't" pattern) so no choice is offered — and the land stays tapped — when hand has no matching land. Example: `NecroblossomSnarl`, `ShineshadowSnarl`.

**Library search with specific card filter**: Subclass `Magic::Choice::SearchLibrary` and override `choices` to return a filtered `CardList` (e.g. `controller.library.by_name("Alpine Watchdog")`). Pass `upto:`, `reveal:` to `super`. Example: `AlpineHoundmaster::SearchChoice`.

**ETB triggers**: Use `def etb_triggers = [TriggerClass]` (shorthand) instead of wiring via `event_handlers`. Both work, but `etb_triggers` is more explicit. Example: `AlpineHoundmaster`, `Trufflesnout`.

**Attack trigger (boost based on attacker count)**: Handle `Events::FinalAttackersDeclared` in `event_handlers`. Check `event.attacks.any? { |a| a.attacker == actor }` in `should_perform?`. Count other attackers with `event.attacks.reject { |a| a.attacker == actor }.count`. Apply via `trigger_effect(:modify_power_toughness, power: n, target: actor, until_eot: true)`. Example: `AlpineHoundmaster`.

**Activated ability with sacrifice cost**: Use `costs "{1}, Sacrifice {this}"` string. Define `single_target? = true`, `target_choices`, and `resolve!(target:)`. Example: `ThrashingBrontodon`.

**Targeting artifacts/enchantments**: Use `game.battlefield.by_any_type("Artifact", "Enchantment")` — string type names work alongside `T::` constants.

**Conditional keyword (only on your turn)**: Subclass `Abilities::Static::KeywordGrant`, override `applicable_targets` to return `[source]` when `game.current_turn.active_player == controller`, else `[]`. Example: `RadhaHeartOfKeld::FirstStrikeGrant`.

**Legendary creature DSL**: Use `legendary_creature_type "Elf Warrior"` in the DSL block instead of `creature_type`.

**String mana cost format**: `cost "{2}{R}{G}"` is valid alongside the hash format `cost generic: 2, red: 1, green: 1`. Use string format when mixing more than two colors or for readability.

**Counting lands**: `controller.lands.count` returns the number of land permanents the controller controls (uses `CardList`).

**Aura static abilities on the attached creature**: Use `applies_to_target` (no arguments) as a class-level declaration inside the static ability subclass — targets the attached permanent automatically. Example: `SetessanTraining::PowerModification`, `SetessanTraining::KeywordGrantTrample`.

**Aura target restriction**: Override `target_choices` on the Aura card class to restrict which permanents can be targeted. Example: `SetessanTraining` restricts to `battlefield.controlled_by(controller).creatures`.

**Scry then reveal top card (conditional draw)**: Subclass `Magic::Choice::Scry`, call `super(**args)` to perform the scry, then inspect `controller.library.first` and fire `game.notify!(Events::CardsRevealed.new(cards: [top_card]))` directly (no Effect needed — `notify!` is the right tool for a plain reveal). Check `top_card.creature? || top_card.land?` — these methods work on Card objects via `lib/magic/types.rb`. Example: `TrackDown::ScryChoice`.

**`card.creature?` and `card.land?` work on cards in any zone** (not just permanents) — defined in `lib/magic/types.rb` and available on all card objects.

**"Nth event each turn" trigger (e.g. "second card drawn each turn")**: In a `TriggeredAbility#should_perform?`, count matching events from `game.current_turn.events` — events are tracked BEFORE listeners receive them, so the current event is included in the count. Example: `JolraelMwonvuliRecluse::SecondCardDrawTrigger` checks `current_turn.events.select { |e| e.is_a?(Events::CardDraw) && e.player == controller }.count == 2`. Caveat: `game.start!` draws 7 cards into the existing turn 1 event log, so testing fresh-turn triggers requires `2.times { game.next_turn }` to reach a clean turn.

**"Enter the battlefield as a copy of [a creature]"**: `Magic::Permanent#copied_card` is a generic `attr_accessor` on `Permanent` (mirrors the `chosen_creature_type` pattern) that names the `Card` object whose characteristics this permanent should present. `Permanent#copiable_card` (`copied_card || card`) is what everything else reads from: `name`, `cmc`, `mana_value`, `colors`, `colorless?` are defined on `Permanent` as explicit methods delegating to `copiable_card` (rather than `def_delegators :@card`), and `Permanents::ContinuousEffects` (`lib/magic/permanents/continuous_effects.rb`) reads `copiable_card.types` / `.base_power` / `.base_toughness` / `.keywords` / `.activated_abilities` each time it recalculates a permanent's live characteristics — so setting `copied_card` is enough; no explicit refresh call is needed; the next `game.tick!` (which re-runs `apply_continuous_effects!`) picks it up. In the ETB choice's `resolve!(target:)`, just do `actor.copied_card = target.card`. Don't reach for `Permanent#transform!` or `Permanent.resolve(copy: true, ...)` for this — those exist for token copies (`ReflectionOfKikiJiki`, `SublimeEpiphany`) that share the *literal* `Card` object of the thing being copied and rely on `copy: true` to stop `destroy!` from moving that shared card to the graveyard; a non-token copy (e.g. `Clone`) must keep its own `Card` identity so its own zone transitions (death, bounce, exile) stay correct — `copied_card` only overrides how its characteristics are *reported*, it never swaps `@card`. Not yet covered by this mechanism: copying triggered abilities (`etb_triggers`/`death_triggers`/`event_handlers`) or `static_abilities` — only the CDA-style characteristics listed above are live-copied so far. Example: `Clone`.

**Setting base power/toughness ("base power and toughness X/X")**: Use `permanent.modify_base_power(n)` and `permanent.modify_base_toughness(n)` (defined in `lib/magic/permanents/modifications.rb`). Adds `Modifications::BasePower` / `BaseToughness` modifiers; `ContinuousEffects` uses the LAST one as the base value (typesetter effect). Modifiers default to `until_eot: true` and are removed in cleanup. To affect all controlled creatures, iterate `controller.creatures.each { _1.modify_base_power(x); _1.modify_base_toughness(x) }`. Example: `JolraelMwonvuliRecluse::ActivatedAbility`.

**Kindred (formerly Tribal)**: Use `type T::Kindred, T::Enchantment, T::Creatures["Elf"]` (or Instant/Sorcery). `T::Kindred` is `"Kindred"`. Example: `ProwessOfTheFair`.

**"Another nontoken Elf is put into your graveyard from the battlefield"**: Listen for `Events::LeftTheBattlefield`, not only `Events::CreatureDied` — Kindred Elves that are not creatures still count. Check `event.to.graveyard?`, `!event.permanent.token?`, `event.permanent.type?("Elf")`, and `event.permanent.controller == controller`. Wrap the token creation in `Magic::Choice::May`. Example: `ProwessOfTheFair`.

**"Whenever an Elf you control dies" (plain "dies" wording, unlike the "put into your graveyard" wording above)**: `Events::CreatureDied` is the right event here — "dies" means a *creature* going to the graveyard from the battlefield, so there's no non-creature-Kindred case to worry about (contrast with the `LeftTheBattlefield` case just above, which exists specifically because that wording also covers non-creature permanents). `event.controller` is already the dying permanent's controller (no `.permanent.controller` needed), so check `event.controller == controller && event.permanent.type?("Elf")` in `should_perform?`, wired via `event_handlers` (not `death_triggers` — the source enchantment itself never dies as an Elf, so the same-permanent restriction on lifecycle triggers would never fire). Example: `ElderfangVenom`, mirroring the unfiltered "any creature you control dies" trigger in `BastionOfRemembrance`.

**Keyword granted only to a filtered subset of creatures (e.g. "Attacking Elves you control have deathtouch")**: Use the `applicable_targets { ... }` block macro (from `Magic::StaticAbility`) rather than overriding the method, combining `your.creatures` with `CardList` filters like `.attacking` and a `.select { |c| c.type?("Elf") }` for a subtype not covered by a built-in `CardList` filter. Contrast with the single-target "conditional keyword" pattern below, which returns `[source]` or `[]`. Example: `ElderfangVenom::DeathtouchGrant`.

**"As ~ enters, choose a creature type"** (e.g. banners/tribal lands): No shared "choose type" infra beyond a bare `Magic::Choice::CreatureType < Magic::Choice` (mirrors `Magic::Choice::Color`, lives at `lib/magic/choice/creature_type.rb`). `chosen_creature_type` is a generic `attr_accessor` on `Magic::Permanent` itself (`lib/magic/permanent.rb`) — push a card-specific `CreatureTypeChoice` subclass (`resolve!(creature_type:)` sets `actor.chosen_creature_type = creature_type`) from an `EnterTheBattlefield` trigger; later abilities read it via `source.chosen_creature_type`. This works directly on the permanent (no `.card` indirection needed) because `actor`/`source` inside trigger and static-ability instances is always the same long-lived `Permanent` object for as long as the card stays on the battlefield. Example: `PatchworkBanner`, `ThreeTreeCity`, `VanquishersBanner`. (Older cards like `UtopiaSprawl` still route a similar `chosen_color` through `Card`'s own pre-existing `attr_accessor :chosen_color` via `actor.card.chosen_color` — both approaches exist in the codebase; prefer storing directly on the `Permanent` for new "chosen X" state unless matching an existing sibling card's convention.)

**"Choose a color other than black" (or similar restricted color choice)**: Subclass `Magic::Choice::Color`, define the allowed list as a `COLORS` constant on the subclass and validate inside `resolve!(color:)` (`raise` if not included) — there's no shared enforcement of the restriction elsewhere in the choice/target pipeline. Example: `ThrivingMoor`, `UtopiaSprawl`.

**Dynamic/characteristic-defining power and toughness ("power and toughness are each equal to X")**: Don't call `power`/`toughness` in the DSL block (defaults to 0/0). Subclass `Abilities::Static::PowerAndToughnessModification`, override `applicable_targets = [source]` and `power_modification` (compute the count directly; `alias_method :toughness_modification, :power_modification` if they're equal) instead of using the `modify(power:, toughness:)` class-level DSL — the modification is added as a delta over the 0/0 base, so returning the full count reproduces the correct total. Example: `MultaniYavimayasAvatar`, `AbominationOfLlanowar`.

**"Tap N untapped [creatures matching X] you control" as an activated ability cost**: Use `Costs::MultiTap.new(predicate_lambda, n)` (`lib/magic/costs/multi_tap.rb`) — note the class does **not** itself enforce the count or the predicate (its `pay` just taps whatever permanents it's given, and its `can_pay?` references an undefined `permanent` method — don't call `can_be_activated?`/`can_pay?` on an ability with this cost). The predicate is documentation of intent for callers/specs, not validation. Pay it via `Actions::ActivateAbility#pay_multi_tap(permanents)` in specs. Example: `Shacklegeist`, `LathrilBladeOfTheElves`, `VoiceOfTheWoods`.

**"Do X, then Y; if you can't, do Z instead" (fallback when a choice has no valid targets)**: Don't rely on `Stack#add_choice`'s auto-resolve (it only fires when there's exactly *one* valid choice, not zero). Instead, build the choice object first, check `choice.choices.any?` yourself, and only `game.choices.add(choice)` when there's at least one option — otherwise trigger the fallback effect directly. Example: `RootsOfWisdom` (mills 3, returns a land-or-Elf card from the graveyard via a `Magic::Choice::SearchGraveyard` subclass, or draws a card if none exists).

**"Elves you control have '...'" (granting a triggered ability to a filtered set of permanents, including the source itself)**: There's no `Abilities::Static::GrantTriggeredAbilities` class yet — use `event_handlers` on the granting card (same as the "another Elf you control enters" pattern), since it dispatches for every permanent on the battlefield rather than only the source. Don't exclude `event.permanent == actor` — unlike "another Elf" wording, the source is itself one of the matching permanents and should be included. Example: `DionusElvishArchdruid` (`Events::PermanentTapped`, filtered to `event.permanent.type?("Elf") && event.permanent.controller == controller`).

**"Whenever this creature becomes tapped, untap it" (reacting to a permanent's own tap by immediately untapping it)**: `Permanent#tap!`/`#untap!` now flip `@tapped` *before* calling `game.notify!`, matching this codebase's general convention that a "such-and-such happened" event fires only after the state change is already applied (mirrors `Effects::MovePermanentZone` firing `PermanentEnteredZoneTransition` only after the zone move). This matters because triggered abilities in this engine run synchronously inside `notify!`, not via a queued/stack-based resolution — with the old tap-then-notify order, a handler calling `event.permanent.untap!` during `PermanentTapped` would have its change immediately clobbered when `tap!` unconditionally set `@tapped = true` right after `notify!` returned. If you ever see a trigger's state change to the event's own permanent seem to silently no-op, check this ordering first.

**"This ability triggers only once each turn" (per-permanent, not a global count)**: Don't reach for `game.current_turn.events` counting (that's for "Nth event each turn" triggers scoped to a player/controller, not to a specific permanent instance) and don't repurpose `mode_chosen_this_turn?`/`choose_mode_this_turn!` (that pair is specifically for Gala-Greeters-style modal "hasn't been chosen this turn" restrictions). Use the generic `permanent.triggered_once_this_turn?(key)` / `permanent.trigger_once_this_turn!(key)` pair on `Magic::Permanent` (reset in `cleanup!` alongside `modes_chosen_this_turn`) — key it on the triggered-ability class (`self.class`) so multiple distinct once-per-turn abilities on the same permanent don't collide. Example: `DionusElvishArchdruid::UntapAndGrowTrigger`.

**Lifecycle triggers (`etb_triggers`/`death_triggers`/`ltb_triggers`) only fire for the permanent's OWN entry/death/exit** — `Permanent#dispatch_lifecycle_triggers` early-returns unless `event.permanent == self`. For "whenever **another** Elf you control enters" (or any creature-enters/dies watching a *different* permanent), you must use `event_handlers` mapping `Events::EnteredTheBattlefield` (or `Events::LeftTheBattlefield`) to a `TriggeredAbility::EnterTheBattlefield` subclass instead — `dispatch_event_handlers` has no such same-permanent restriction and runs for every permanent on the battlefield. Mixing this up silently no-ops the trigger (no error, counters/tokens just never appear). Examples: `WatcherOfTheSpheres`, `DwynenGiltLeafDaen`, `MarwynTheNurturer`, `ElvishWarmaster`.

**Kicker paid with a non-mana cost (e.g. "Kicker—Sacrifice a creature")**: `kicker_cost` normally returns a `Costs::Kicker < Costs::Mana`, set via the `kicker_cost(cost)` DSL macro — mana-only. For a non-mana kicker, skip that macro and override the `kicker_cost` reader in the card's class reopening to lazily build a small duck-typed cost object instead (`.pay(player:, payment:)` + `.paid?`) — e.g. `Costs::SacrificeKicker`, which sacrifices `payment` and flips a `paid?` flag. `Actions::Cast#pay_kicker`/`#resolve!` (`kicked: kicker_cost.paid?`) don't care which class it is. Spec calls it the same way as a mana kicker: `a.pay_kicker(creature_permanent)`. Example: `PrimalGrowth`.

**"This spell can't be countered" / "[Spells matching X] can't be countered"**: `Card#can_be_countered?` (`lib/magic/card.rb`) is the generic hook — its default implementation checks battlefield static abilities for a `prevents_countering?(card)` method and denies countering if any match; `Effects::CounterSpell#resolve!` checks it before calling `game.stack.counter!`. For a spell that can't be countered by rule text on itself (not conditionally), just override `can_be_countered?` on the card's class reopening to return `false` unconditionally — no need to touch the static-ability hook. For "[color/type] spells you control can't be countered" as an ongoing effect from a permanent, add a `StaticAbility` subclass implementing `prevents_countering?(card)` (check `card.colors`/`card.controller`, etc.) and return it from `static_abilities` — the default `can_be_countered?` on every other card already queries it, no per-card wiring needed elsewhere. Example: `AllosaurusShepherd`.

**"Becomes a [type] in addition to its other types" (until end of turn or otherwise)**: Use `permanent.add_types("TypeName")` (`lib/magic/permanents/modifications.rb`) — adds an `until_eot: true` modifier by default; `ContinuousEffects` merges it additively with the permanent's existing types (unlike `Abilities::Static::TypeGrant`/`TypeRemoval`, which are for a continuous *static* ability on a permanent rather than a one-shot/until-eot grant from a trigger or activated ability). Combine with `modify_base_power`/`modify_base_toughness` for "has base power and toughness N/N and becomes a [type] in addition to its other types". Example: `AllosaurusShepherd`.

**"You may pay {X}{X}. When you do, [effect] distributed/scaled by X"**: There's no built-in "optional variable mana cost paid mid-trigger" cost type — implement it as a `Magic::Choice::May` subclass whose `resolve!(x:, payment: {})` calls `controller.pay_mana(payment)` directly (a plain color-hash payment, not a `Costs::Mana` object — this is a trigger resolving, not a cast/activation going through the normal cost-payment pipeline) and, only then, pushes the follow-up effect/choice; declining is just `game.skip_choice!`. For "distribute N counters among any number of targets," a plain `Magic::Choice` subclass takes an `amount:` in its constructor, exposes the valid target list via `choices`, and resolves with a `resolve!(distribution:)` taking a `{permanent => count}` hash (nothing validates the counts sum to `amount` — trust the caller, matching this codebase's general looseness around cost/payment validation). Example: `NumaJoragaChieftain`.

**Modal spells ("Choose one —" / "Choose one or more —")**: There's a full, working, but easy-to-miss modal system: subclass `Magic::Cards::Mode` (`lib/magic/cards/mode.rb`, `source`/`controller`/`trigger_effect` all delegate to the card) once per mode, each with its own `target_choices`/`resolve!(target:)` (or a no-target `resolve!` for a mode with no target), then declare `modes Mode1, Mode2, ...` on the card. The card class itself is written as a raw `class CardName < Sorcery; card_name "..."; cost ...; end` (**not** the `Sorcery("Name") do ... end` block form) — `card_name`/`cost` are plain class-body DSL calls. At cast time, `action.choose_mode(SomeMode) { |mode| mode.targeting(target) }` — call it once per chosen mode; nothing enforces "choose one" vs "choose one or more" vs "not the same mode twice", so a "choose one" charm's spec just calls `choose_mode` once and a "choose one or more" spell's spec calls it multiple times. Examples: `RakdosCharm` ("choose one"), `SublimeEpiphany` (up to five modes at once), `CasualtiesOfWar` (all five destroy modes).

**"At the beginning of each upkeep" (not just yours)**: Don't use `TriggeredAbility::BeginningOfYourUpkeep` (that bakes in `you?`). Use a plain `TriggeredAbility` with no `should_perform?` override (or one that doesn't check the event's player) wired via `event_handlers` on `Events::BeginningOfUpkeep` — it fires for both players' upkeeps. Example: `WolverineRiders`.

**"That player sacrifices a [filtered] creature of their choice" (edict targeting whoever the trigger names, not the source's controller)**: `Magic::Choice`'s default `controller = actor.controller` assumes the chooser is the source's controller — wrong here, since `event.player` (the affected upkeep's player) can be either player. Pass that player into the choice explicitly (`SacrificeChoice.new(actor: actor, player: event.player)`, stored as its own ivar, not read via `controller`) and build `choices` off it (e.g. `@player.creatures.excluding_type("Elf")`). Subclass `Magic::Choice::Targeted` with `choice_amount 1` and `resolve!(target:) = target.sacrifice!` (mirrors `Effects::Sacrifice`/`GodEternalBontu`, called directly rather than via `trigger_effect` since the choice already carries the target). Since this is mandatory (not `Choice::May`), only call `game.choices.add(choice)` when `choice.choices.any?` — the "do X, then Y; if you can't" fallback pattern applies even with no explicit "if you can't" clause: an empty pool just means nothing happens, so guard the `add` rather than pushing a choice with no valid targets. Example: `RuthlessWinnower`.

**Casting permission granted "until end of turn" by an activated ability** (not a permanent static condition): track the turn number on the permanent (e.g. `permanent.exile_cast_permission_turn = game.current_turn.number`, a narrow `attr_accessor` added to `Magic::Permanent` alongside `cannot_untap_next_turn`), then have the static ability's `permits_casting_from_exile?(card)` compare it against `game.current_turn.number` — naturally expires when the turn advances, no cleanup step needed. Example: `SerpentsSoulJar`.

**Monarch**: Implemented as a real cross-cutting game mechanic, not a per-card flag. `Game#monarch` / `Game#make_monarch!(player)` (notifies `Events::PlayerBecameMonarch`); `Player#monarch?` / `Player#become_monarch!`. `Game` subscribes to its own events (`subscribe(self)` in `initialize`) and its `receive_event` handles the two game-rule effects that aren't tied to any specific card: the monarch draws a card at the beginning of their own end step (`Events::BeginningOfEndStep`, compares `event.active_player`), and a creature dealing combat damage to the monarch transfers the monarchy to that creature's controller (`Events::CombatDamageDealt`, checks `event.target == monarch`). A card that grants monarch status (e.g. "you become the monarch" on ETB) only needs to call `actor.controller.become_monarch!` — the draw-each-end-step and combat-damage-transfer rules apply automatically regardless of which card granted it. Example: `CourtOfBounty`; mechanic tests live in `spec/game_spec.rb` rather than a card spec.

**"Reveal the top N cards" into a custom multi-part choice** (not a straight search/scry): wrap `actor.controller.library.first(n)` in `Magic::CardList.new(...)` — `Zone#first` (via `Enumerable`) returns a plain `Array`, so you lose `.lands`/`.by_any_type` filtering unless you rewrap it. Reveal with `controller.reveal(*cards)`. To return the unchosen cards "to the bottom in a random order", each card is still physically present in the library's items (only cards actually moved via `move_to_hand!`/`resolve!` are removed) — `remove` then `push` each one, don't just `push`, or they'll be duplicated. Example: `BountyOfSkemfar`.

**Kicker on a non-permanent spell (instant/sorcery)**: `actor.kicked?` only works for permanents (the flag is baked into the `Permanent` at resolution). For a spell that never becomes a permanent, check `kicker_cost.paid?` directly on the card instead — the same card instance persists from cast through resolution, so `kicker_cost` (set during `pay_kicker`) is still valid inside `resolve!`. Example: `VastwoodSurge`.

**"Choose one that hasn't been chosen this turn" (Alliance and similar repeatable modal triggers)**: `Magic::Permanent` has a generic `modes_chosen_this_turn` tracker — `mode_chosen_this_turn?(mode)` / `choose_mode_this_turn!(mode)` — reset in `cleanup!` (so it naturally expires at the end of the turn it was set, same timing as `until_eot` modifiers; reaching cleanup in a spec requires driving the turn state machine all the way there, e.g. `current_turn.untap!; ...; current_turn.cleanup!`, not `game.next_turn`, which just creates a fresh `Turn` object without running the previous turn's `cleanup` step). A plain `Magic::Choice` subclass filters its own `choices` list with `MODES.reject { |mode| actor.mode_chosen_this_turn?(mode) }` and calls `actor.choose_mode_this_turn!(mode)` inside `resolve!`; only push the choice when `choice.choices.any?` (same empty-pool guard as the "if you can't" pattern). Example: `GalaGreeters`.

**Filtering permanents by a subtype like "Aura" (e.g. "target non-Aura permanent")**: `CardList#excluding_type`/`by_any_type` and `Types#type?` do a plain `Array#include?`/`String#include?` check against `permanent.types` — this only works pre-`apply_continuous_effects!`, when a fresh `Card`'s `@types` is still the raw `TYPE_LINE` (a literal string for `Aura`, e.g. `"Enchantment -- Aura"`, so `.include?("Aura")` is a substring check). Once continuous effects run (`ContinuousEffects#calculate_types` does `[*copiable_card.types, ...]`), `permanent.types` becomes an Array containing that whole type-line string as a single element, so `type?("Aura")`/`.include?("Aura")` silently goes from "substring match" to "exact-element match" and returns `false` even for an actual Aura — and continuous effects apply immediately on `Permanent.resolve` (via `Effects::MovePermanentZone`), so this bites on essentially every permanent already on the battlefield, not just after a `game.tick!`. Check the Ruby class instead: `permanent.card.is_a?(Cards::Aura)` (or `Cards::Equipment`, etc. for other CardBuilder base classes) — reliable regardless of continuous-effects timing. Example: `Mirrorform`.

**Moving a card between zones**: Prefer `card.move_to_hand!`/`card.move_to_graveyard!`/`card.move_zone!(to:)` over a manual `from_zone.remove(card); to_zone.add(card)` pair — the manual form skips nothing today (`Zone#add` already sets `card.zone`), but the single-call form is shorter and matches the rest of the codebase. Only reach for manual `remove`/`add` (or `remove`/`push`) when repositioning a card *within the same zone* (e.g. shuffling unchosen cards to the bottom of the library) — there's no "move" happening there. Example: `WrennAndSeven` (+1 ability), `CrownOfSkemfar`.

**`Zone` (`lib/magic/zone.rb`) delegates several `CardList` filters directly** (`.lands`, `.creatures`, `.by_any_type`, `.permanents`, etc.) so `hand.lands` / `graveyard.permanents` work without the `.cards` indirection — prefer that over `hand.cards.lands`. If a `CardList` method you need isn't in `Zone`'s `def_delegators` list yet, add it there rather than routing through `.cards` in card code.

**"Put any number of land cards from your hand onto the battlefield tapped" (optional variable-count zone change)**: Subclass `Magic::Choice::MoveToBattlefield` (`lib/magic/choice/move_to_battlefield.rb`) — its `choices` method returns a `Magic::Targets::Choices.new(amount: 0..n, choices: ...)` (an inclusive range starting at 0 covers "any number, including none"; `n` should be computed live off the current zone, e.g. `hand.lands.count`, not cached), and `resolve!(choices:)` calls `.resolve!` on each chosen card — override `resolve!` to pass `enters_tapped: true` when the effect requires it (the base class's `resolve!` doesn't). Always `game.choices.add(...)` unconditionally here rather than guarding on "any left" — `0..0` for an empty pool is itself a valid "choose zero" choice. Drive it in specs with `game.resolve_choice!(choices: [...])`. Example: `UginTheSpiritDragon` (permanents, no tapped requirement), `WrennAndSeven` (0 ability, lands only, tapped).

**`LoyaltyAbility#resolve!`/`ActivatedAbility#resolve!` bodies must use `source`/`controller`/`trigger_effect`/`hand`/`graveyard`/`library`, not `actor`** — `Magic::Ability` (the base class both inherit from) defines exactly those delegators and has no `actor` method; calling `actor.trigger_effect(...)` inside a loyalty ability's `resolve!` raises `NoMethodError` at activation time. This is easy to miss because `Magic::Choice` subclasses *do* have `actor` (a different base class), so the two easily get confused. A card with no spec can hide this indefinitely since the bug only surfaces when the ability is actually activated.

**Dynamic/CDA power and toughness on a Token (not a Creature card)**: Same pattern as the Creature-card CDA case above — subclass `Abilities::Static::PowerAndToughnessModification` nested inside the `Token` subclass, `applicable_targets = [source]`, override `power_modification`/alias `toughness_modification`, and return it from `def static_abilities` on the token class. Must be a plain `class SomeToken < Token; ... end` definition (not a `Token.create("Name") do ... end` block) so the nested static-ability class lands inside the token's own namespace rather than `Magic::Cards` — same lexical-scope pitfall as the DSL-block-vs-class-reopening note at the top of this file. Example: `WrennAndSeven::TreefolkToken` (power/toughness equal to lands controlled).

**"{N}, {T}, Exile this [permanent]: ..." (exiling itself as an activation cost)**: `Costs::Parser` had no exile-self cost until `Costs::SelfExile` (mirrors `Costs::SelfSacrifice`) plus a `/Exile {this}/` case in the parser — write it as `costs "{3}, {T}, Exile {this}"` same as any other multi-part cost string. `Permanent#exile!` (mirrors `destroy!`) moves both the permanent and its underlying card to `game.exile`. `Player#activate_ability` auto-pays it unconditionally once present, same as `SelfTap`/`SelfSacrifice` — no explicit `pay_self_exile` call needed in specs. Example: `PlazaOfHeroes`.

**"Add one mana of any color. Spend this mana only to cast a legendary spell" (or similar restricted-use mana)**: There's no mana-pool tagging for *what a mana can be spent on* — `Player#mana_pool` is a flat `color => count` hash. Implement the production side only (`Magic::ManaAbility` with `choices :all`, or a computed `choices` list) and don't try to enforce the spending restriction; this matches the codebase's existing looseness around unenforced cost/payment rules (see kicker/counter-distribution notes above). Example: `PlazaOfHeroes`.

**Rebound** ("If you cast this spell from your hand, exile it as it resolves. At the beginning of your next upkeep, you may cast this card from exile without paying its mana cost."): Use the `rebound` DSL macro (mirrors `flashback(cost)`, defines `rebound?` to return `true`) on the card. `Actions::Cast#resolve!` has a generic `elsif card.rebound? && card.zone.hand?` branch (alongside the existing `@flashback` branch) that exiles the card instead of moving it to the graveyard — `card.zone` never actually changes to a "stack" zone in this engine (it stays `hand`/`exile` throughout casting/resolution), so checking `card.zone.hand?` at resolution time reliably distinguishes "cast from hand" from "cast from exile via rebound" without a separate flag. `Zones::Exile` now subscribes/unsubscribes cards with `event_handlers` on add/remove, same as `Zones::Graveyard`/`Zones::Command` already did — this is what lets a card sitting in exile react to `Events::BeginningOfUpkeep` at all. Wire the delayed trigger as a plain card `event_handlers` entry (`Events::BeginningOfUpkeep => ReboundTrigger`, actor is the *card*, not a permanent — `Card#controller` exists so `TriggeredAbility::BeginningOfYourUpkeep`'s `you?` works unmodified) that pushes a `Magic::Choice::May` wrapping a `Magic::Choice::Targeted` for the optional recast (same two-step "may" pattern as `NecroblossomSnarl`). Since the card never leaves exile if declined, it would otherwise refire on every subsequent upkeep — this is a one-shot delayed trigger, not a recurring one, so guard `should_perform?` with an explicit `attr_accessor` flag on the card (e.g. `rebound_triggered`) set inside `call`, distinct from the "once per turn" `Permanent#triggered_once_this_turn?` helper (which resets every turn) and from zone-based unsubscription (which never happens here since the card doesn't move). For the free recast itself, build the action manually rather than via `player.cast`: `controller.prepare_cast(card: actor)` then `action.mana_cost = {}` (an empty-hash `Costs::Mana` is `zero?`/`can_pay?` true and needs no payment) then `action.targeting(target)` then `game.take_action(action)` — this still runs the real `Actions::Cast#perform` (so `Events::SpellCast` fires normally) followed by a normal `game.stack.resolve!`, and since `card.zone` is `exile` (not `hand`) at that point, the rebound branch above doesn't re-trigger and the card goes to the graveyard as usual afterward. Note `Actions::Cast#can_perform?` is never actually consulted by `perform`/`take_action` in this engine (only specs call it as an assertion) — no need to also thread a `permits_casting_from_exile?` static ability through for this to work. Example: `Ephemerate`.

## TriggeredAbility Subclasses

Pre-built subclasses in `lib/magic/triggered_ability/` — use these to avoid rewriting `should_perform?`:

- `TriggeredAbility::BeginningOfYourUpkeep` — fires on `Events::BeginningOfUpkeep` only during controller's upkeep (`you?` built in)
- `TriggeredAbility::BeginningOfEndStep` — fires on `Events::BeginningOfEndStep`; provides `controllers_end_step?` helper
- `TriggeredAbility::EnterTheBattlefield` — provides `another_creature?`, `flying?`, `enchantment?`
- `TriggeredAbility::SpellCast` — provides `spell`, `enchantment?`
- `TriggeredAbility::Landfall`, `::Death`, `::LeaveTheBattlefield`, `::CounterAdded`, `::LoreCounterAdded`

**Composable `should_perform?` predicates on the base `TriggeredAbility` class** (`lib/magic/triggered_ability.rb`): prefer AND-chaining these named predicates over writing out the equivalent `event.permanent`/`game.current_turn` checks inline — `you?`, `opponent?`, `this?` (event permanent is the source), `type?`/`creature?`/`under_your_control?` (all check `event.permanent`), `controllers_turn?`. `add_counter(counter_type, target: actor, amount: 1)` is a similar shorthand for `trigger_effect(:add_counter, counter_type:, target:, amount:)` — note this is a different method from `Permanent#add_counter`, which mutates counters directly with no event and must stay that way (it's what `Effects::AddCounterToPermanent#resolve!` itself calls; routing it back through `trigger_effect` would recurse).

**`Permanent#add_counter`/`#remove_counter` go through the effect pipeline, not raw mutation** — they call `trigger_effect(:add_counter, ...)`/`trigger_effect(:remove_counter, ...)` (`Effects::AddCounterToPermanent`/`Effects::RemoveCounterFromPermanent`, routed through `game.add_effect` and `ReplacementEffectResolver`), so any card calling `permanent.add_counter(...)`/`creature.remove_counter(...)` automatically gets `DoublingSeason`'s `CounterDoubler` (or any future counter replacement effect) applied — no card needs to reach for `trigger_effect(:add_counter, ...)` directly, and there is no longer a "wrong" raw path to accidentally call from card code. The actual mutation lives in `Permanent#put_counters!`/`#take_counters!` (bang, no event/replacement) — those exist only for `Effects::AddCounterToPermanent`/`RemoveCounterFromPermanent#resolve!` to call while resolving; card code should never call them directly. Originally found as a bug via `Aron, Benalia's Ruin`'s activated ability calling the raw path before this fix; combo tests: `spec/game/integration/aron_benalias_ruin_doubling_season_spec.rb`, `spec/game/integration/doubling_season_add_counter_spec.rb`.

**"Do this only once each turn" trigger** (e.g. "Whenever ~ becomes tapped, untap it... Do this only once each turn"): subclass `TriggeredAbility::OncePerTurn` instead of `TriggeredAbility` directly — its `perform!` override gates on and marks `Permanent#triggered_once_this_turn?`/`#trigger_once_this_turn!` (keyed on `self.class`) automatically, wrapping the real `should_perform?`/`call`. The card's own `should_perform?` only needs its domain conditions (the once-per-turn check is applied on top, outside the card's control) and `call` never has to remember to mark itself — there's no way to forget the bookkeeping since it isn't exposed to the subclass. Example: `DionusElvishArchdruid`.

## Static Ability Subclasses

Pre-built subclasses in `lib/magic/abilities/static/` — declare these on a card via `def static_abilities = [...]`. `ContinuousEffects` and `ActivateAbility` query them generically; **never add card-class checks to those layers**.

- `Abilities::Static::KeywordGrant` — grants keywords to matching permanents
- `Abilities::Static::PowerAndToughnessModification` — modifies power/toughness
- `Abilities::Static::TypeGrant` / `TypeRemoval` — adds/removes types
- `Abilities::Static::ManaCostAdjustment` — reduces/adjusts mana costs for matching cards
- `Abilities::Static::AnyColorForCreatureActivations` — controller can spend mana as any color when activating abilities of creature permanents (e.g. Agatha's Soul Cauldron)
- `Abilities::Static::GrantActivatedAbilities` — grants activated abilities to matching permanents; subclass and implement `applies_to?(permanent)` and `granted_abilities` (e.g. Agatha's Soul Cauldron grants abilities from exiled creature cards to creatures with +1/+1 counters)
- `Abilities::Static::LandsEnterUntapped` — subclass and implement `lands_enter_untapped?(card)`; queried by `Permanent.enters_tapped_after_replacements` via `.of_type(...)`, not `respond_to?`. Example: `Spelunking`, `HorizonExplorer`.
- `Abilities::Static::AdditionalCountersForEntering` — subclass and implement `additional_counters_for_entering(permanent)`; queried by `Permanent.resolve` (creatures only) via `.of_type(...)`. Example: `BioengineeredFuture`.
- `Abilities::Static::TriggeredAbilityDoubler` — subclass and implement `doubles_trigger_for?(permanent, event)` (`event` is the cause — check its class/fields when the doubling is conditional on what triggered it, e.g. Panharmonicon only cares about `Events::EnteredTheBattlefield` where `event.permanent` is an artifact or creature). Queried generically from `Permanent#perform_trigger!`, which both `dispatch_lifecycle_triggers` (etb/death/ltb) and `dispatch_event_handlers` route through — a matching doubler makes the ability's `perform!` run one extra time per doubler, so two doublers on the board multiply a single ability firing to 3x, not 4x (additive extra firings, not compounding). Unlike `DoublingSeason` (a `ReplacementEffect` that doubles the *amount* an effect produces, e.g. tokens or counters), this doubles the *ability itself* running again — stacking both together is multiplicative, since each of the ability's separate firings produces its own effect for `DoublingSeason` to double independently. Examples: `RoamingThrone` (restricted to another creature you control of a chosen type), `Panharmonicon` (restricted to ETB triggers caused by an artifact/creature entering, permanent must be yours); combo test: `spec/game/integration/roaming_throne_panharmonicon_spec.rb`.

**Pattern**: define an inner class on the card that subclasses the relevant base, implement `applies_to?` and any extra methods, return it from `def static_abilities`. Access the source permanent via `@source`. Example: `AgathasSoulCauldron::GrantAbilitiesFromExile`.

**Querying static abilities generically**: Use `game.battlefield.static_abilities.of_type(Abilities::Static::SomeBaseClass)` (`lib/magic/static_abilities.rb`), not `.respond_to?(:some_method)` — the latter is fragile (a class overriding the method without inheriting the right base silently no-ops, or worse, an unrelated ability happens to define a same-named method). Every hook queried this way needs a real base class under `lib/magic/abilities/static/`, even if it only has one implementation so far.

## CardList Helper Methods

`Magic::CardList` (`lib/magic/card_list.rb`) wraps arrays of cards/permanents with filtering helpers. Use these instead of manual `select` with type checks:

- `.creatures` — cards/permanents where `creature?` is true
- `.lands` — `land?`
- `.enchantments` — `enchantment?`
- `.planeswalkers` — `planeswalker?`
- `.artifacts` — via `.by_any_type(T::Artifact)`
- `.basic_lands` — `basic_land?`
- `.shrines` — subtype "Shrine"
- `.controlled_by(player)` / `.not_controlled_by(player)` — filter by controller
- `.by_name(name)` — filter by card name
- `.by_any_type(*types)` — filter by one or more type constants
- `.cmc_lte(n)` — mana value ≤ n
- `.nonland` / `.nontoken` — exclusion filters
- `.except(target)` — exclude a specific card/permanent
- `.tapped` / `.attacking` — combat/state filters

These return a new `CardList`, so they chain: `source.exiled_cards.creatures.flat_map(&:activated_abilities)`. Prefer these over `select { |c| c.types.include?(T::Creature) }` or similar manual filters.

## Important Files & Entry Points

- `lib/magic.rb`: Entry point, Zeitwerk setup
- `lib/magic/game.rb`: Game coordinator and main API
- `lib/magic/card.rb`: Card base class
- `lib/magic/permanent.rb`: Permanent on battlefield
- `lib/magic/cards/`: All ~280 card implementations
- `.github/copilot-instructions.md`: Extended card implementation guidance
- `spec/spec_helper.rb`: Test setup and helpers
