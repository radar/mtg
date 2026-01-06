# Copilot Instructions for MTG Ruby Project

This is a Ruby implementation of a Magic: The Gathering simulation. The project is a learning exercise focusing on game mechanics without a UI.

## Project Structure

- `lib/magic/` - Core game logic and mechanics
- `lib/magic/cards/` - Individual card implementations
- `spec/` - RSpec test files with integration tests
- Card implementations use the `CardBuilder` DSL

## Code Style

- Use `# frozen_string_literal: true` at the top of main library files (like `lib/magic.rb`, `lib/magic/version.rb`) and spec files
- Card files in `lib/magic/cards/` do not use the frozen_string_literal pragma
- Follow standard Ruby conventions and style guides
- Use descriptive variable and method names
- Prefer clarity over brevity

## Implementing Cards

### Using CardBuilder DSL

All new card implementations should use the `CardBuilder` DSL. The DSL provides methods for creating different card types:

- `Creature(name)` - For creature cards
- `Instant(name)` - For instant spells
- `Sorcery(name)` - For sorcery spells
- `Enchantment(name)` - For enchantments
- `Aura(name)` - For aura enchantments
- `Saga(name)` - For saga enchantments
- `Artifact(name)` - For artifacts
- `Equipment(name)` - For equipment

### Example: Simple Creature

```ruby
module Magic
  module Cards
    StorySeeker = Creature("Story Seeker") do
      cost generic: 1, white: 1
      creature_type("Dwarf Cleric")
      keywords :lifelink
      power 2
      toughness 2
    end
  end
end
```

### Cards with Abilities

For cards with triggered abilities, event handlers, or activated abilities, extend the card class:

```ruby
module Magic
  module Cards
    LibraryLarcenist = Creature("Library Larcenist") do
      creature_type "Merfolk Rogue"
      cost generic: 2, blue: 1
      power 1
      toughness 2

      class CreatureAttackedTrigger < TriggeredAbility
        def should_perform?
          this?
        end

        def call
          actor.controller.draw!
        end
      end

      def event_handlers
        {
          Events::CreatureAttacked => CreatureAttackedTrigger
        }
      end
    end
  end
end
```

### Card File Location

Create card files at `lib/magic/cards/<card_name>.rb` using snake_case naming.

## Testing

### Running Tests

```bash
bundle install
bundle exec rspec
```

### Test Structure

Tests use RSpec and follow integration testing patterns. The test suite includes:

- Shared context `"two player game"` for game setup
- Helper methods in `CardHelper` and `PlayerHelper`
- Integration tests in `spec/game/integration/`

### Common Test Helpers

Available in specs through `CardHelper` and shared contexts:

- `Card(name, owner: p1)` - Create a card instance
- `ResolvePermanent(name, owner: p1)` - Create and resolve a permanent
- `cast_and_resolve(card:, player:)` - Cast and resolve a card
- `go_to_main_phase!` - Advance to main phase
- `skip_to_combat!` - Advance to combat phase

### Test Example

```ruby
require 'spec_helper'

RSpec.describe Magic::Game, "card functionality" do
  include_context "two player game"

  let!(:creature) { ResolvePermanent("Creature Name", owner: p1) }

  it "performs expected behavior" do
    # Test implementation
    expect(creature.power).to eq(2)
  end
end
```

## Dependencies

The project uses:

- `state_machines` - For game state management
- `zeitwerk` - For autoloading
- `dry-types` - For type definitions
- RSpec for testing

## Contributing

When implementing cards:

1. Check existing cards for similar mechanics
2. Use the CardBuilder DSL for consistency
3. Add appropriate tests for card functionality
4. Follow existing code patterns and conventions

### Legacy vs. CardBuilder DSL Pattern

Most cards now use the CardBuilder DSL. Some older cards may use a direct class inheritance pattern:

```ruby
class CardName < Creature
  # Implementation
end
```

Modern cards should use the CardBuilder DSL pattern:

```ruby
CardName = Creature("Card Name") do
  # Implementation
end
```

For cards with complex abilities, use the DSL first, then extend with a class definition (see `lib/magic/cards/academy_elite.rb` for an example).
