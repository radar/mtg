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

## Common Card Ability Patterns

**Ward (additional life cost)**: Use `ward life: N` DSL in the card definition block. Automatically registers a `SpellCast` trigger that checks `opponents.include?(event.player) && event.targets.include?(actor)` and calls `trigger_effect(:lose_life, target: event.player, life: N)`. If the card also defines `event_handlers` in a class reopening, call `super.merge(...)` to preserve the ward trigger. Example: `TerrorOfThePeaks`.

**Targeted ETB trigger ("deals damage to any target")**: Add `Magic::Choice::Targeted` subclass to card's class reopening. Define `choices` (e.g. `game.any_target`) and `resolve!(target:)`. In trigger's `call`, push instance onto `game.choices`. Pass data needed at resolution (e.g. entering creature's power) via constructor. Example: `TerrorOfThePeaks::DamageChoice`.

**Simple ETB effect (no targeting/choice)**: Use the `enters_the_battlefield` DSL block inside the card definition — no class reopening needed. Example: `SetessanTraining` draws a card on ETB with `actor.trigger_effect(:draw_cards, number_to_draw: 1)`.

**Modal ETB choice (pick one of N effects)**: Subclass `Magic::Choice` directly. Define `resolve!(mode:)` with a `case mode` switch. Use symbol constants (e.g. `COUNTER = :counter`). In the ETB trigger's `call`, push an instance onto `game.choices`. Example: `Trufflesnout`.

**Optional ETB (may do X)**: Wrap the real choice in a `Magic::Choice::May` subclass — override `resolve!` to push the inner choice onto `game.choices`. Example: `AlpineHoundmaster::MaySearchChoice`.

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

## TriggeredAbility Subclasses

Pre-built subclasses in `lib/magic/triggered_ability/` — use these to avoid rewriting `should_perform?`:

- `TriggeredAbility::BeginningOfYourUpkeep` — fires on `Events::BeginningOfUpkeep` only during controller's upkeep (`you?` built in)
- `TriggeredAbility::BeginningOfEndStep` — fires on `Events::BeginningOfEndStep`; provides `controllers_end_step?` helper
- `TriggeredAbility::EnterTheBattlefield` — provides `under_your_control?`, `another_creature?`, `flying?`, `enchantment?`
- `TriggeredAbility::SpellCast` — provides `spell`, `enchantment?`
- `TriggeredAbility::Landfall`, `::Death`, `::LeaveTheBattlefield`, `::CounterAdded`, `::LoreCounterAdded`

## Static Ability Subclasses

Pre-built subclasses in `lib/magic/abilities/static/` — declare these on a card via `def static_abilities = [...]`. `ContinuousEffects` and `ActivateAbility` query them generically; **never add card-class checks to those layers**.

- `Abilities::Static::KeywordGrant` — grants keywords to matching permanents
- `Abilities::Static::PowerAndToughnessModification` — modifies power/toughness
- `Abilities::Static::TypeGrant` / `TypeRemoval` — adds/removes types
- `Abilities::Static::ManaCostAdjustment` — reduces/adjusts mana costs for matching cards
- `Abilities::Static::AnyColorForCreatureActivations` — controller can spend mana as any color when activating abilities of creature permanents (e.g. Agatha's Soul Cauldron)
- `Abilities::Static::GrantActivatedAbilities` — grants activated abilities to matching permanents; subclass and implement `applies_to?(permanent)` and `granted_abilities` (e.g. Agatha's Soul Cauldron grants abilities from exiled creature cards to creatures with +1/+1 counters)

**Pattern**: define an inner class on the card that subclasses the relevant base, implement `applies_to?` and any extra methods, return it from `def static_abilities`. Access the source permanent via `@source`. Example: `AgathasSoulCauldron::GrantAbilitiesFromExile`.

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
