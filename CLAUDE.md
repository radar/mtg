# CLAUDE.md

Guidance for Claude Code when working in this repo.

> **READ `../CLAUDE.md` FIRST. Change files with the Write and Edit tools ONLY. Not heredocs (`cat > f <<EOF`), not `sed`,
> not `perl`, not `python`, not `ruby -e`, not `tee`, not shell redirects, not anything else.** If you ever do, apologise
> deeply, insult yourself, remind yourself "only Write and Edit", and redo the change with Write or Edit. The full rule and
> that procedure are in `../CLAUDE.md`.

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
- Run commands from the repo root with relative paths. Don't `cd`, and don't pass absolute paths to commands (each one triggers a permission prompt).
- Don't pipe test output through `rg` with path-like patterns (e.g. `rg -v "^\s*# /Users"`). Use `head`/`tail`, or `rspec --format progress`.
- Edit files with the Edit/Write tools, not `sed`. The shell has `noclobber` set, so `>` onto an existing file fails: use Write, or `>|`.
- Don't write throwaway Ruby (or perl/python) scripts to edit source or spec files -- no `tmp/*.rb` full of `sub!` calls, no `ruby -e` patches. Use the Edit tool (Read the file first). Scripted edits mangled indentation (a `<<~` heredoc strips the common indent from what it inserts) and broke on `#{}` interpolation inside double-quoted patterns, and they hide the change from review.
- For read-only questions about data (transcripts, JSON, logs), use `jq`, `rg` or `fd`, not a Ruby script. Ruby scripts in `tmp/` are for exercising this codebase (e.g. generating a card to look at its output), not for editing or for counting things `jq`/`rg` can count.
- `rm`, `cp` and `mv` are aliased to prompt interactively in this shell, and a prompt hangs the command: use `rm -f` / `cp -f` / `mv -f` (or `command cp -f`). `c` is also an alias, so don't name a shell function `c`.
- A test spec that changes state of the shared game (`game.tick!`, `game.settle!`, `current_turn.end!; current_turn.cleanup!`) needs those calls to see the effect; see the Testing Patterns section and `docs/engine_notes.md` (Trigger Queue) before guessing.

### Code Style

- `# frozen_string_literal: true` at top of `lib/magic/*.rb` and `spec/**/*_spec.rb`
- Card files in `lib/magic/cards/` do **not** use the frozen_string_literal pragma
- Follow Ruby conventions
- Avoid `instance_variable_set` / `instance_variable_get` in `lib/`. To change a copy of an object, give it a real method: `Effect#with_amount(n)` and `Effect#with_damage(n)` (built on protected writers) are how replacement effects double, triple or halve an effect. Only `LoggerlessMarshal` (serialisation) may reach into instance variables.

### Workflow

- Each card: own commit. Commit to the current branch unless asked for a branch/PR (the `implement-card` skill has the details).
- Stage only that card's files by explicit path, never `git add -A`.
- After implementing, note new patterns/gotchas in `docs/patterns/*.md` (or `docs/engine_notes.md` for engine behavior) in the same commit, not in this file. Keep this file short: it is loaded on every turn.

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

**Targeted trigger with exactly one legal target**: `Stack` auto-resolves a `Choice::Targeted` whose `target_choices` has a single entry (`stack.rb`, `single_choice?`), so `game.choices` is empty and `game.resolve_choice!(target:)` fails with `undefined method 'resolve!' for nil` — assert the effect directly, or put two legal targets on the battlefield before the trigger fires to test the choice itself. Exiled cards live in `game.exile`, not `player.exile`.

**Putting a specific card on top of the library in a spec**: Use `player.library.add(card)` (default `placement: 0`, so it lands on top), not `player.library.unshift(card)`. `Zone#add` sets `card.zone = self`; `unshift` is a raw delegated Array method that skips it. A card with an unset `zone` silently fails to be removed from its zone when later moved (`move_to_hand!`/`resolve!` no-op on `from.remove` because `from` is nil), so it ends up duplicated instead of moved.

**Spec consequences** (the shared "two player game" context leaves turn 1 in the `beginning` step):

- Anything sorcery-speed (creatures without flash, sorceries, enchantments, artifacts, lands, loyalty abilities) needs `before { go_to_main_phase! }`. `go_to_main_phase!` is idempotent and steps through the draw step, so the library's top card shifts by one.
- The opponent casting a sorcery-speed spell needs their own turn: `go_to_main_phase_for!(p2)`. Instants and flash creatures are fine any time.
- Two sorcery-speed casts in a row need `game.stack.resolve!` between them.
- `ResolvePermanent` backdates the permanent so it is not summoning sick; pass `summoning_sick: true` to test sickness. Creatures that enter via `p1.cast` + `game.stack.resolve!` are sick for real. Grant haste with `grant_haste!` **and `game.tick!`**.
- Lands that enter tapped need `permanent.untap!` before activating their mana ability; a mana source needs `untap!` between two activations.
- **DSL-block leak**: a `class Foo` inside a `Creature("Name") do ... end` block lands in `Magic::Cards::Foo` and can shadow other cards' classes (spec passes alone, fails in the full suite). Put nested classes in a class reopening.
- **Token triggers**: constants in a `Token.create` block resolve in the *enclosing card's* scope. Define the trigger in a `class GoblinShamanToken` reopening and reference it as `GoblinShamanToken::AttacksTrigger` (example: `FableOfTheMirrorBreaker`).

**Trigger queue** (default): triggers go on the stack, not run inside `notify!`. After any raw engine mutation in a spec (`permanent.destroy!`, `game.notify!`, `p1.draw!`, `.perform` on an action, ...) call `game.settle!` before asserting. `ResolvePermanent` settles itself (not for Auras). Details: `docs/engine_notes.md`.

## Card Parser

Specs that count tokens: use `def tokens = p1.creatures.select { ... }`, not a memoized `let` -- a `let` snapshots the list the first time it's read, so a later "is it gone?" check sees stale permanents. A permanent with an ETB `Choice` (surveil, scry) leaves it pending after `ResolvePermanent`, which blocks `settle!`/trigger resolution until `game.skip_choice!`. Mobilize/Flurry parsing: see `docs/card_parser.md`.

Endure and Behold (TDM): endure is a `Choice::Endure` (`resolve_choice!` = counters, `skip_choice!` = Spirit token); an optional "you may behold" additional cost is the card's `kicker_cost` (`Costs::OptionalBehold`, `pay_kicker`), and "if a Dragon was beheld" is `kicker_cost.paid?`; a destroyed permanent's `zone` is nil, so check `p2.graveyard.cards.map(&:name)` in specs. Details: `docs/card_parser.md`.

`printf 'Name {cost}\nType — Sub\nrules\nP/T\n' | bundle exec rake parse_card` writes `lib/magic/cards/<name>.rb` from plain card text. How it works, what it supports, and how to add a rule or effect: `docs/card_parser.md`. Read it before changing `lib/magic/card_parser/`, `card_parser.rb` or `card_generator.rb`.

## Engine notes (read the section you need: `docs/engine_notes.md`)

Moved out of this file to keep it short. Headline hazards, each explained in `docs/engine_notes.md`:

- **Action Legality**: `Turn#take_action` raises `Magic::IllegalAction` for illegal casts/plays/activations/attacks/blocks. Mana and `{T}` costs are paid before the legality check, so an illegal action can leave mana spent.
- **Decision providers / `GameRunner`**: `Magic::Agent`, `ScriptedAgent`, `FirstLegalAgent`, `Game#legal_actions`, `Game#run!`.
- **Zone permissions**: casting from the top of the library, exile or graveyard needs a battlefield static ability answering `permits_casting_from_*?`; `game.play_permissions` for temporary ones; `by_effect: true` skips zone/timing checks.
- **Graveyard**: a card in the graveyard ignores events unless the handler defines `self.works_from_graveyard?`; `Card#graveyard_abilities` lists Renew-style abilities.
- **Replacement effects off the battlefield**: `zone_replacement_effects`; never scan every zone per effect.
- **Trigger queue / SBA ordering**: "enters with counters" must use `AdditionalCountersForEntering` (not an ETB trigger); once-per-turn guards go in `should_perform?`/`trigger!`, not `call`.
- **Engine hooks added for arena**: pay-life casts, Station/Spacecraft, Bargain, Goad, UI hooks on `Choice`, `Choice::Targeted` is a target by default (`def targets? = false` for plain picks).
- **Priority** (`enforce_priority: true`), **Combat**, **Targeting keywords/ward**, **Indestructible/regeneration**.

## Card Ability Patterns

Moved to `docs/card_patterns.md` (Common Card Ability Patterns, TriggeredAbility Subclasses, Static Ability Subclasses, CardList Helper Methods) — kept out of this file since it only matters when implementing a card; `implement-card` skill reads it directly.

## Important Files & Entry Points

- `lib/magic.rb`: Entry point, Zeitwerk setup
- `lib/magic/game.rb`: Game coordinator and main API
- `lib/magic/card.rb`: Card base class
- `lib/magic/permanent.rb`: Permanent on battlefield
- `lib/magic/cards/`: All card implementations
- `.github/copilot-instructions.md`: Extended card implementation guidance
- `spec/spec_helper.rb`: Test setup and helpers
- `docs/engine_notes.md`: Engine behaviour reference (moved from this file)
