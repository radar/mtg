# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Reference

### Build & Dependencies
```bash
bundle install              # Install Ruby gems and dependencies
```

### Testing
```bash
bundle exec rspec           # Run all tests
bundle exec rspec spec/cards/island_spec.rb           # Run a single test file
bundle exec rspec spec/cards/island_spec.rb:10        # Run a specific test at line 10
bundle exec rspec -k "taps for"                       # Run tests matching a pattern
```

The test suite uses RSpec with integration testing patterns. See `spec/spec_helper.rb` for available test helpers and shared contexts.

### Code Style
- Use `# frozen_string_literal: true` at top of main library files (`lib/magic/*.rb` and `spec/**/*_spec.rb`)
- Card files in `lib/magic/cards/` do **not** use the frozen_string_literal pragma
- Follow standard Ruby conventions with descriptive variable and method names

## High-Level Architecture

This is a Magic: The Gathering simulation engine written in Ruby without UI. The system models the core game mechanics and card effects using an event-driven architecture with state machines.

### Core Game Flow

1. **Game** (`lib/magic/game.rb`): Central coordinator managing two-player games
   - Maintains the **Turn** state machine (`lib/magic/game/turn.rb`) which progresses through phases: untap → upkeep → draw → main → combat → end
   - Delegates to **Stack** for spell resolution and **Permanent** management on the **Battlefield**
   - Manages **Players** with their libraries, hands, graveyards, and exile zones
   - Notifies interested parties of game **Events** that trigger abilities

2. **Cards & Permanents**: Two-part card model
   - **Card** (`lib/magic/card.rb`): Represents a card in any zone (hand, graveyard, library, exile, stack)
   - **Permanent** (`lib/magic/permanent.rb`): Represents a card on the battlefield with state (tapped, damage counters, attachments, etc.)
   - Card resolution via **Permanent.resolve()** moves a card from stack to battlefield

3. **Card Implementation**: CardBuilder DSL (`lib/magic/card_builder.rb`)
   - All cards defined in `lib/magic/cards/` use the DSL for consistency
   - Base card types: `Creature`, `Instant`, `Sorcery`, `Enchantment`, `Aura`, `Saga`, `Artifact`, `Equipment`
   - Simple cards need only cost and creature stats (Example: `StorySeeker`)
   - Complex cards extend the base class with triggered abilities, activated abilities, and event handlers (Example: `AcademyElite`)
   - **DSL block vs class reopening**: The DSL block (`Enchantment("Name") do ... end`) runs in the `Magic::Cards` lexical scope, so any `class Foo` defined inside it lands in `Magic::Cards::Foo` — not nested inside the card class. To avoid name collisions between cards, keep the DSL block to type and cost only, then define trigger classes, choice classes, and `event_handlers` in a class reopening (`class CardName < Enchantment; ...; end`). Constants defined there are properly scoped to the card. Example: `SanctumOfCalmWaters`, `SanctumOfFruitfulHarvest`.

### Events & Abilities

The system uses an **event-driven architecture** to handle triggered and state-based abilities:

- **Events** (`lib/magic/events/`): 47+ event types (e.g., `CardDraw`, `CreatureAttacked`, `BeginningOfUpkeep`) notify the system when game state changes
- **TriggeredAbility** (`lib/magic/triggered_ability.rb`): Responds to events with `should_perform?` condition check and `call` execution
- **Saga** (`lib/magic/cards/saga.rb`): Enchantment subtype that adds a lore counter on ETB and again at the beginning of the controller's first main phase each subsequent turn (`FirstMainPhaseTrigger`). Each lore counter addition fires `Events::CounterAddedToPermanent`, which triggers the corresponding chapter ability via `CounterAdded`. After the final chapter resolves, the saga sacrifices itself.
- **ActivatedAbility** (`lib/magic/activated_ability.rb`): Player-triggered abilities with costs and effects
- **Event Handlers**: Cards define `event_handlers` hash mapping event class to ability class for automatic triggering

### Actions & Spell Resolution

**Actions** (`lib/magic/actions/`) represent player decisions and game operations:
- `Cast`: Places spell on stack with optional targeting and flashback
- `PlayLand`: Plays a land from hand to battlefield
- `ActivateAbility`: Activates card abilities with cost payment
- `DeclareAttacker` / combat mechanics

**Stack** (`lib/magic/stack.rb`): Manages spell resolution order
- Spells and effects added to stack, then resolved in LIFO order
- **Choices** handle modal effects and decisions during resolution
- **Effects** trigger as side effects of resolution (e.g., draw cards, deal damage, move permanents)

### Effects System

**Effects** (`lib/magic/effects/`) represent state changes during resolution:
- `DrawCards`, `DealDamage`, `DestroyTarget`, `CreateToken`, `MoveCardZone`, `AddCounter`, etc.
- Effects can be modified by **Replacement Effects** before applying (e.g., redirect damage, replace draw)
- **ReplacementEffectResolver** (`lib/magic/game/replacement_effect_resolver.rb`) handles if/then logic before effect executes

### Zones & Player State

Zones are containers for cards in different areas:
- **Battlefield** (`lib/magic/zones/battlefield.rb`): Permanents with combat tracking
- **Hand** (`lib/magic/zones/hand.rb`): Cards in player's hand
- **Library** (`lib/magic/zones/library.rb`): Deck with draw mechanics
- **Graveyard** (`lib/magic/zones/graveyard.rb`): Discard pile
- **Exile** (`lib/magic/zones/exile.rb`): Out-of-game area

**Player** (`lib/magic/player.rb`): Owns zones, tracks life total, mana pool, and counters
- Methods: `draw!`, `play_land()`, `cast()`, `activate_ability()`, `take_action()`

### Mana & Costs

- **Mana** (`lib/magic/mana.rb`): Color representation (white, blue, black, red, green, generic, colorless)
- **Costs** (`lib/magic/costs/`): Mana costs, tap costs, sacrifice costs, counter removal
- **ManaAbility** & **TapManaAbility**: Land activation to produce mana
- Cards define costs via DSL: `cost generic: 1, white: 1`

### Permanents: Creatures, Planeswalkers, Enchantments

**Permanent** includes multiple concerns:
- **Creature** (`lib/magic/permanents/creature.rb`): Power/toughness, combat mechanics, damage tracking
- **Planeswalker** (`lib/magic/permanents/planeswalker.rb`): Loyalty counters, loyalty abilities
- **Enchantment** (`lib/magic/permanents/enchantment.rb`): Static abilities that modify game state
- **Modifications**: Attachments (equipment, auras), keyword grants, power/toughness mods

### Types & Keywords

- **Types** (`lib/magic/types.rb`): Card type system (Creature, Instant, Artifact, etc.)
- **Keywords** (`lib/magic/cards/keywords.rb`): Keyword abilities (lifelink, flying, haste, etc.)
- **Keyword Handlers** (`lib/magic/cards/keyword_handlers/`): Rules implementation for keywords

### Autoloading

Uses **Zeitwerk** (`lib/magic.rb`) for automatic constant loading from `lib/magic/**/*.rb`. Define new classes/modules and they're auto-loaded.

### Dependencies

- `state_machines`: Governs turn structure and phase transitions
- `zeitwerk`: Automatic module/class loading
- `dry-types`: Type definitions for mana and other game concepts
- `rspec`: Testing framework with integration test patterns
- `pry`: Debugging console

## Testing Patterns

**Shared Context** (`spec/spec_helper.rb`): Use `include_context "two player game"` to get:
- `game`: Game instance with two players (p1, p2) with 7 cards in library
- `current_turn`: Access to turn state and phase transitions
- Helper methods: `go_to_main_phase!`, `skip_to_combat!`, `go_to_combat_damage!`
- `ResolvePermanent(name, owner: p1)`: Create and resolve a permanent
- `cast_and_resolve(card:, player:)`: Cast a spell and resolve it immediately

**Card Helper**: `Card(name, owner: p1)` creates card instances by snake_case lookup.

**Testing Sagas**: Since turns alternate between players, advancing to the controller's next main phase requires two `game.next_turn` calls (to skip the opponent's turn) followed by `go_to_main_phase!`. Each chapter is tested in a nested `context` block. Example:
```ruby
before { 2.times { game.next_turn }; go_to_main_phase!; game.stack.resolve!; game.tick! }
```

**Integration Tests**: Focus on game mechanics and card interactions, not unit testing individual methods. Example test file: `spec/cards/island_spec.rb`

## Important Files & Entry Points

- `lib/magic.rb`: Main entry point with Zeitwerk autoloading setup
- `lib/magic/game.rb`: Game coordinator and main API
- `lib/magic/card.rb`: Card definition base class
- `lib/magic/permanent.rb`: Permanent on battlefield
- `lib/magic/cards/`: All ~280 card implementations
- `.github/copilot-instructions.md`: Extended card implementation guidance
- `spec/spec_helper.rb`: Test setup and helpers
