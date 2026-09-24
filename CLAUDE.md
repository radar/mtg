# CLAUDE.md

Guidance for Claude Code when working in this repo.

## Quick Reference

### Build & Dependencies

```bash
bundle install              # Install Ruby gems and dependencies
```

> **Note for Copilot cloud agent**: `bundle` is not on PATH. Use this pattern instead:
>
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

### Tooling

- Use `fd`, not `find`, for file searches.
- Use `rg`, not `grep`, for text searches.
- Avoid `xargs`. Never, ever use it. Find another way.
- Temporary files: write to a `tmp/` dir within this repo, not `/tmp`.

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
- `ResolvePermanent(name, owner: p1)`: Create and resolve a permanent (the card is owned by `owner` too)
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

## Action Legality

`Turn#take_action` (so `player.cast`, `play_land`, `activate_ability`, `activate_loyalty_ability`, `declare_attacker`, `cycle`) asks `action.illegal_reason` first and raises `Magic::IllegalAction` (with `#reason`) instead of performing. `Action#legal?` is the boolean form. What is enforced:

- **Cast**: sorcery timing (active player, main phase, empty stack) unless the card is an instant or has flash; zone (hand, flashback graveyard, or a permitted zone); `spell_cast_limit`.
- **PlayLand**: same sorcery timing, zone, `player.can_play_lands?`.
- **ActivateAbility**: activator controls the source; `source.can_activate_ability?`; `ability.requirements_met?` (default `true` on `ActivatedAbility`); `once_each_turn` abilities not already activated this turn; a `{T}` cost needs an untapped, non-summoning-sick source (`Costs::SelfTap#unpayable_reason`, checked in `ActivateAbility#pay` as the cost is paid).
- **ActivateLoyaltyAbility**: controller, sorcery timing unless the ability's `instant_speed?` is true (Teferi, Master of Time), one activation per planeswalker per turn, loyalty must cover a negative cost.
- **DeclareAttacker**: declare attackers step, active player, creature you control, untapped, `can_attack?` (defender), not summoning sick. Re-declaring an already-attacking creature just retargets and skips the tapped/sickness checks. Specs that call `current_turn.declare_attacker` directly (the `CombatPhase` delegate) still bypass all of this.
- **Cycle**: card must be in hand.

`can_perform?` (on `Cast`, `PlayLand`, `Cycle`) is a separate, advisory "could this player afford/do this" check for UIs; `illegal_reason` runs after costs have been paid, so it must not check affordability. Consequence: a `{T}`/mana cost is paid before the legality check runs for timing/requirement failures, so an illegal `Cast` or `ActivateAbility` can leave the mana spent or the source tapped. Only the `{T}` cost itself is checked at payment time.

**Blocking and combat damage**: `current_turn.declare_blocker` raises `CombatPhase::IllegalBlock` (reason from `illegal_block_reason`) for flying/reach, skulk, tapped blockers, blockers the defending player doesn't control, and a creature already blocking. Menace is checked when leaving declare blockers (`current_turn.combat_damage!` raises). First-strike and double-strike blockers deal damage in the first-strike step. To choose how an attacker divides damage between blockers, call `current_turn.assign_combat_damage(attacker, { blocker => n, p2 => n })` before damage; otherwise damage is lethal to each blocker in declaration order and the rest goes to the last blocker (or through, with trample). "Lethal" counts damage already marked and damage other creatures assign to the same creature in that step. A card allows blocking extra attackers by defining `maximum_attackers_blocked` (default 1); specs can stub it on `permanent.card`. Specs that grant evasion or strike keywords need `game.tick!` after the grant, or the keyword isn't there when blocks are checked.

**Summoning sickness**: `Permanent#summoning_sick?` is true for a non-haste creature whose `controlled_since_turn` is not before the controller's latest turn (`Game#latest_turn_number_of`). `Permanent#controller=` resets it. Grant haste with `grant_haste!` **and `game.tick!`** — the keyword only shows up once continuous effects are recalculated.

**Zone permissions**: a card may be cast/played from the top of the library, exile or graveyard only if some battlefield static ability defines `permits_casting_from_top?(card)` / `permits_casting_from_exile?(card)` returning true (these also gate `PlayLand`, so a "play lands from the top of your library" card needs `card.land?` in its check), or an emblem defines `permits_casting_from_graveyard?`. A permission method may take the casting player as a second argument (`permits_casting_from_exile?(card, player)`), for "you may cast it". Permissions that outlast their source ("until the end of your next turn, you may play that card", from a spell) go in `game.play_permissions.grant_until_end_of_next_turn(card:, player:)`. A static ability can also answer `any_mana_type_for?(card, player)` ("mana of any type can be spent to cast that spell") or `free_cast_from_exile?(card, player)` ("without paying its mana cost"), which `Actions::Cast` checks. Casting a card you don't own makes you its controller (`card.controller = player`, reset when it changes zone; a permanent spell enters under the caster's control), and it still goes to its owner's graveyard. A cast an effect instructs (rebound, "you may cast it" on resolution) passes `by_effect: true` to skip zone and timing checks (rule 608.2g). Cards exiled on an adventure carry `card.on_adventure` (cleared when they leave exile). A card with **no zone at all** (a bare `Card(...)` fixture) is treated as being in hand; every other zone is checked for real.

**Spec consequences** (the shared "two player game" context leaves turn 1 in the `beginning` step):

- Anything sorcery-speed (creatures without flash, sorceries, enchantments, artifacts, lands, loyalty abilities) needs `before { go_to_main_phase! }`. `go_to_main_phase!` is idempotent and steps through the draw step, so the library's top card shifts by one.
- The opponent casting a sorcery-speed spell needs their own turn: `go_to_main_phase_for!(p2)` (repeats `game.next_turn` until `p2` is active). Instants and flash creatures are fine any time.
- Two sorcery-speed casts in a row need `game.stack.resolve!` between them (the stack must be empty).
- `ResolvePermanent`/`Permanent` in specs backdate the permanent (`controlled_since_turn = 0`) so it is not summoning sick; pass `summoning_sick: true` to test sickness. Creatures that enter via `p1.cast` + `game.stack.resolve!` are sick for real.
- Lands with "enters tapped" need `permanent.untap!` before you activate their mana ability, and a mana source needs `untap!` between two activations.
- A loyalty ability that costs more than the planeswalker has needs `planeswalker.change_loyalty!(n)` first. Two copies of a legendary planeswalker trigger a pending legend-rule choice that blocks all stack resolution.
- **DSL-block leak**: a `class Foo` written inside a `Creature("Name") do ... end` block lands in `Magic::Cards::Foo`, and a bare `ActivatedAbility` in *any* other card then resolves to whichever leaked `Magic::Cards::ActivatedAbility` loaded last. It showed up as a spec that passed alone and failed in the full suite (`Speaker of the Heavens`, fixed). Put nested classes in a class reopening.

## Card Parser

`printf 'Name {cost}\nType — Sub\nrules\nP/T\n' | bundle exec rake parse_card` writes `lib/magic/cards/<name>.rb` from plain card text. How it works, what it supports, and how to add a rule or effect: `docs/card_parser.md`. Read it before changing `lib/magic/card_parser/`, `card_parser.rb` or `card_generator.rb`.

## Card Ability Patterns

Moved to `docs/card_patterns.md` (Common Card Ability Patterns, TriggeredAbility Subclasses, Static Ability Subclasses, CardList Helper Methods) — kept out of this file since it only matters when implementing a card; `implement-card` skill reads it directly.

## Important Files & Entry Points

- `lib/magic.rb`: Entry point, Zeitwerk setup
- `lib/magic/game.rb`: Game coordinator and main API
- `lib/magic/card.rb`: Card base class
- `lib/magic/permanent.rb`: Permanent on battlefield
- `lib/magic/cards/`: All ~280 card implementations
- `.github/copilot-instructions.md`: Extended card implementation guidance
- `spec/spec_helper.rb`: Test setup and helpers
