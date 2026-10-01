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
- Run commands from the repo root with relative paths. Don't `cd`, and don't pass absolute paths to commands (each one triggers a permission prompt).
- Don't pipe test output through `rg` with path-like patterns (e.g. `rg -v "^\s*# /Users"`). Use `head`/`tail`, or `rspec --format progress`.
- Edit files with the Edit/Write tools, not `sed`. The shell has `noclobber` set, so `>` onto an existing file fails: use Write, or `>|`.
- Don't write throwaway Ruby (or perl/python) scripts to edit source or spec files -- no `tmp/*.rb` full of `sub!` calls, no `ruby -e` patches. Use the Edit tool (Read the file first). Scripted edits mangled indentation (a `<<~` heredoc strips the common indent from what it inserts) and broke on `#{}` interpolation inside double-quoted patterns, and they hide the change from review.
- For read-only questions about data (transcripts, JSON, logs), use `jq`, `rg` or `fd`, not a Ruby script. Ruby scripts in `tmp/` are for exercising this codebase (e.g. generating a card to look at its output), not for editing or for counting things `jq`/`rg` can count.
- `rm`, `cp` and `mv` are aliased to prompt interactively in this shell, and a prompt hangs the command: use `rm -f` / `cp -f` / `mv -f` (or `command cp -f`). `c` is also an alias, so don't name a shell function `c`.
- A test spec that changes state of the shared game (`game.tick!`, `game.settle!`, `current_turn.end!; current_turn.cleanup!`) needs those calls to see the effect; see the Testing Patterns and Trigger Queue sections before guessing.

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

**Targeted trigger with exactly one legal target**: `Stack` auto-resolves a `Choice::Targeted` whose `target_choices` has a single entry (`stack.rb`, `single_choice?`), so `game.choices` is empty and `game.resolve_choice!(target:)` fails with `undefined method 'resolve!' for nil` — assert the effect directly, or put two legal targets on the battlefield before the trigger fires to test the choice itself. Exiled cards live in `game.exile`, not `player.exile`.

**Putting a specific card on top of the library in a spec**: Use `player.library.add(card)` (default `placement: 0`, so it lands on top), not `player.library.unshift(card)`. `Zone#add` sets `card.zone = self`; `unshift` is a raw delegated Array method that skips it. A card with an unset `zone` silently fails to be removed from its zone when later moved (`move_to_hand!`/`resolve!` no-op on `from.remove` because `from` is nil), so it ends up duplicated instead of moved.

## Action Legality

`Turn#take_action` (so `player.cast`, `play_land`, `activate_ability`, `activate_loyalty_ability`, `declare_attacker`, `cycle`) asks `action.illegal_reason` first and raises `Magic::IllegalAction` (with `#reason`) instead of performing. `Action#legal?` is the boolean form. What is enforced:

- **Cast**: sorcery timing (active player, main phase, empty stack) unless the card is an instant or has flash; zone (hand, flashback graveyard, or a permitted zone); `spell_cast_limit`; card must not be a land (lands are played, not cast) unless `adventure: true` (a land-typed adventure card is cast for its non-land adventure side); card must not already be on the stack, unresolved (`Cast#already_on_stack?`, rule 405.2).
- **PlayLand**: same sorcery timing, zone, `player.can_play_lands?`.
- **ActivateAbility**: activator controls the source; `source.can_activate_ability?`; `ability.requirements_met?` (default `true` on `ActivatedAbility`); `once_each_turn` abilities not already activated this turn; a `{T}` cost needs an untapped, non-summoning-sick source (`Costs::SelfTap#unpayable_reason`, checked in `ActivateAbility#pay` as the cost is paid).
- **ActivateLoyaltyAbility**: controller, sorcery timing unless the ability's `instant_speed?` is true (Teferi, Master of Time), one activation per planeswalker per turn, loyalty must cover a negative cost.
- **DeclareAttacker**: declare attackers step, active player, creature you control, untapped, `can_attack?` (defender), not summoning sick. Re-declaring an already-attacking creature just retargets and skips the tapped/sickness checks. Specs that call `current_turn.declare_attacker` directly (the `CombatPhase` delegate) still bypass all of this.
- **DeclareBlocker** (added for roadmap C2b — blocking had no `Action` at all before this): declare blockers step, you control the blocker, then `CombatPhase#illegal_block_reason` (untapped, defending player controls it, not already blocking that attacker or at `maximum_attackers_blocked`, no protection, no evasion it can't get through). `player.declare_blocker(blocker:, attacker:)` goes through `take_action`/raises `Magic::IllegalAction`; `current_turn.declare_blocker(blocker, attacker:)` (the raw `CombatPhase` delegate, still used directly by most combat specs) bypasses all of this and raises `CombatPhase::IllegalBlock`/`AttackerHasProtection` instead.
- **Cycle**: card must be in hand.

`can_perform?` (on `Cast`, `PlayLand`, `Cycle`) is a separate, advisory "could this player afford/do this" check for UIs; `illegal_reason` runs after costs have been paid, so it must not check affordability. Consequence: a `{T}`/mana cost is paid before the legality check runs for timing/requirement failures, so an illegal `Cast` or `ActivateAbility` can leave the mana spent or the source tapped. Only the `{T}` cost itself is checked at payment time.

**Blocking and combat damage**: `current_turn.declare_blocker` raises `CombatPhase::IllegalBlock` (reason from `illegal_block_reason`) for flying/reach, skulk, tapped blockers, blockers the defending player doesn't control, and a creature already blocking. Menace is checked when leaving declare blockers (`current_turn.combat_damage!` raises). First-strike and double-strike blockers deal damage in the first-strike step. To choose how an attacker divides damage between blockers, call `current_turn.assign_combat_damage(attacker, { blocker => n, p2 => n })` before damage; otherwise damage is lethal to each blocker in declaration order and the rest goes to the last blocker (or through, with trample). "Lethal" counts damage already marked and damage other creatures assign to the same creature in that step. A card allows blocking extra attackers by defining `maximum_attackers_blocked` (default 1); specs can stub it on `permanent.card`. Specs that grant evasion or strike keywords need `game.tick!` after the grant, or the keyword isn't there when blocks are checked.

**Decision-provider interface (roadmap C2 — done)**: `Magic::Agent` (`lib/magic/agent.rb`) is the contract for "ask the player what to do" — `choose_action`, `choose_targets`, `choose_blockers`, `choose_mana_payment`, `resolve_choice`, each raising `NotImplementedError` on the base class. `Magic::Agents::ScriptedAgent.new(answers: [...])` answers every one of those calls from a shared queue, in the order scripted, raising `ScriptedAgent::OutOfAnswers` once it runs out. `Magic::Agents::FirstLegalAgent` takes the first option offered, declines every block, and has no generic `resolve_choice` (raises `NotImplementedError` — script one instead). `Player#agent` holds the agent driving that player; unset by default, so every existing caller keeps driving players directly. `Game#legal_actions(player)` (`lib/magic/legal_actions.rb`) enumerates the unpaid/untargeted `Action` candidates currently legal for `player` — `[*actions, nil]`, `nil` (meaning pass) always **last**, so an agent that just takes the first entry prefers a real action over passing — using `action.legal?` (and `action.can_perform?` where the class defines it: `Cast`, `PlayLand`, `Cycle`) rather than re-implementing any legality rule. `ActivateAbility`/`ActivateManaAbility`/`ActivateLoyaltyAbility` candidates are filtered by `legal?` plus an explicit `Costs::SelfTap#unpayable_reason` check (illegal_reason deliberately doesn't check `{T}`-cost payability — see "Action Legality" above — but an enumeration of what's *currently* activatable has to exclude an already-tapped/summoning-sick source); no other affordability check (`Costs::*#can_pay?` has an inconsistent arity across other cost classes, e.g. `Costs::Tap#can_pay?(_player, permanent)` needs a target that hasn't been chosen, so a legal-but-unaffordable ability can still appear; paying it fails the normal way). A mana ability is built as `Actions::ActivateManaAbility` specifically (not the base `ActivateAbility` — different `#perform`, doesn't use the stack), matching `Player#activate_ability`'s own branch. Block declarations go through the new `Actions::DeclareBlocker`/`Player#declare_blocker` (see "Action Legality" above) — one candidate per (declared attacker, that player's creature) pair in the declare-blockers step. `declarable_attackers` skips re-declaring an already-attacking creature at the *same* target — legal (a no-op retarget) but pointless to offer, and self-play fuzzing (L2) found it hangs a "just take the first legal action" agent forever otherwise.

`Game#run!(max_actions: 10_000)` (`Magic::GameRunner`) plays a whole game with each player's `agent`, requires `Game.new(enforce_priority: true)`, and raises `GameRunner::NotFinished` rather than returning a mid-game state if it doesn't finish in time. Beyond the mechanical loop (drain choices, auto-advance no-priority steps, otherwise ask whoever holds priority), it only knows how to *prepare* a chosen action for: `ActivateAbility`/`ActivateManaAbility`'s self-tap/self-sacrifice/self-exile and mana costs (**neither action's own `#perform` pays its costs** — `Player#activate_ability` normally pays them before calling `take_action`, and `GameRunner` has to stand in for that itself, since it builds and performs the action directly) plus a multi-colour mana ability's colour choice; `Cast`'s mana cost (`auto_pay_mana`) and a single target; `Cycle`'s mana cost. A modal spell that declares `choose_modes` is prepared too: `Cast#available_modes` (modes with something to target) are offered to `Agent#choose_targets` for the minimum count, then each chosen mode gets one target per target list; `Cast#can_perform?` (so `legal_actions`) hides a modal spell with fewer available modes than it needs. Everything else (multi-target spells, a cost needing a chosen target permanent/card) is left to fail the same way it would for a caller that forgot to pay it. `spec/game/integration/game_runner_spec.rb` runs two `FirstLegalAgent`s to a real deck-out loss with no exceptions.

**Renew and Harmonize (TDM)**: a card's abilities usable from its owner's graveyard are `Card#graveyard_abilities` (instances, e.g. Renew: `{cost}, Exile {this}` + `activate_from_graveyard_as_sorcery`; `p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(...).targeting(x) }`; the "Exile {this}" cost is paid before legality is checked, so `requirements_met?` accepts a card already in exile). Harmonize is `Cast.new(card:, harmonize: true)` (cost from `card.harmonize_cost`, spell exiled after, `Cast#harmonize_tap(creature)` reduces generic by power). A card in a spec needs `Card(name, owner: p1)` (with `game:`), a bare `card_class.new(owner:)` has no game. Details in `docs/card_parser.md`.

**Summoning sickness**: `Permanent#summoning_sick?` is true for a non-haste creature whose `controlled_since_turn` is not before the controller's latest turn (`Game#latest_turn_number_of`). `Permanent#controller=` resets it. Grant haste with `grant_haste!` **and `game.tick!`** — the keyword only shows up once continuous effects are recalculated.

**Recasting the same card object** (a bounce-and-recast, or `legal_actions` asked about a spell that's still unresolved on the stack): `Cast#mana_cost` builds a fresh `Costs::Mana` from the card's face-value cost hash (`card.cost.cost.dup`) rather than `card.cost.dup` — `Costs::Mana#dup` is `Object#dup`'s shallow copy, which shares `@balance`/`@payments` **by reference** with the original, and `card.cost` is one instance reused by every `Cast` built for that card over its whole life. Duping it (the old code) meant paying the "fresh" copy permanently mutated the card's own cost, so casting the same physical card a second time — ever, for any reason — raised `Costs::Mana::Overpayment`. Found via self-play fuzzing (roadmap L2); see `docs/engine_roadmap.md` L2 for the other bugs that pass found. Alternative-cost objects that aren't `Costs::Mana` (`Costs::SacrificeAlternativeCost`, `Costs::ExileCardAndLifeAlternativeCost`) don't share this shape and are unaffected.

**Zone permissions**: a card may be cast/played from the top of the library, exile or graveyard only if some battlefield static ability defines `permits_casting_from_top?(card)` / `permits_casting_from_exile?(card)` returning true (these also gate `PlayLand`, so a "play lands from the top of your library" card needs `card.land?` in its check), or an emblem defines `permits_casting_from_graveyard?`. A permission method may take the casting player as a second argument (`permits_casting_from_exile?(card, player)`), for "you may cast it". Permissions that outlast their source ("until the end of your next turn, you may play that card", from a spell) go in `game.play_permissions.grant_until_end_of_next_turn(card:, player:)`. A static ability can also answer `any_mana_type_for?(card, player)` ("mana of any type can be spent to cast that spell") or `free_cast_from_exile?(card, player)` ("without paying its mana cost"), which `Actions::Cast` checks. Casting a card you don't own makes you its controller (`card.controller = player`, reset when it changes zone; a permanent spell enters under the caster's control), and it still goes to its owner's graveyard. A cast an effect instructs (rebound, "you may cast it" on resolution) passes `by_effect: true` to skip zone and timing checks (rule 608.2g). Cards exiled on an adventure carry `card.on_adventure` (cleared when they leave exile). A card with **no zone at all** (a bare `Card(...)` fixture) is treated as being in hand; every other zone is checked for real.

**Spec consequences** (the shared "two player game" context leaves turn 1 in the `beginning` step):

- Anything sorcery-speed (creatures without flash, sorceries, enchantments, artifacts, lands, loyalty abilities) needs `before { go_to_main_phase! }`. `go_to_main_phase!` is idempotent and steps through the draw step, so the library's top card shifts by one.
- The opponent casting a sorcery-speed spell needs their own turn: `go_to_main_phase_for!(p2)` (repeats `game.next_turn` until `p2` is active). Instants and flash creatures are fine any time.
- Two sorcery-speed casts in a row need `game.stack.resolve!` between them (the stack must be empty).
- `ResolvePermanent`/`Permanent` in specs backdate the permanent (`controlled_since_turn = 0`) so it is not summoning sick; pass `summoning_sick: true` to test sickness. Creatures that enter via `p1.cast` + `game.stack.resolve!` are sick for real.
- Lands with "enters tapped" need `permanent.untap!` before you activate their mana ability, and a mana source needs `untap!` between two activations.
- A loyalty ability that costs more than the planeswalker has needs `planeswalker.change_loyalty!(n)` first. Two copies of a legendary planeswalker trigger a pending legend-rule choice that blocks all stack resolution.
- **DSL-block leak**: a `class Foo` written inside a `Creature("Name") do ... end` block lands in `Magic::Cards::Foo`, and a bare `ActivatedAbility` in *any* other card then resolves to whichever leaked `Magic::Cards::ActivatedAbility` loaded last. It showed up as a spec that passed alone and failed in the full suite (`Speaker of the Heavens`, fixed). Put nested classes in a class reopening.
- **Token triggers**: a `Token.create` block can define `event_handlers` (tokens dispatch them like cards), but constants in that block resolve in the *enclosing card's* scope, not the token's. Define the trigger in a `class GoblinShamanToken` reopening and reference it as `GoblinShamanToken::AttacksTrigger` (bare `AttacksTrigger` raises `NameError`). Example: `FableOfTheMirrorBreaker`.

## Card Parser

Specs that count tokens: use `def tokens = p1.creatures.select { ... }`, not a memoized `let` -- a `let` snapshots the list the first time it's read, so a later "is it gone?" check sees stale permanents. A permanent with an ETB `Choice` (surveil, scry) leaves it pending after `ResolvePermanent`, which blocks `settle!`/trigger resolution until `game.skip_choice!`. Mobilize/Flurry parsing: see `docs/card_parser.md`.

`printf 'Name {cost}\nType — Sub\nrules\nP/T\n' | bundle exec rake parse_card` writes `lib/magic/cards/<name>.rb` from plain card text. How it works, what it supports, and how to add a rule or effect: `docs/card_parser.md`. Read it before changing `lib/magic/card_parser/`, `card_parser.rb` or `card_generator.rb`.

## Trigger Queue (rule 603.3b; default since 2026-09-24)

`Game.new(queue_triggers: true)` is now the **default** (pass `queue_triggers: false` to get the old fully-synchronous behavior back, e.g. for isolating a regression). Triggered abilities go on the stack instead of running synchronously inside `notify!`. `Permanent#perform_trigger!` still evaluates `should_perform?`/`TriggeredAbility::OncePerTurn`-style bookkeeping immediately (via `TriggeredAbility#trigger!`, called once at trigger time — any once-per-turn/one-shot bookkeeping a card does itself must live here too, not in `call`; see the Ondu Spiritdancer note below), but defers the effect (`call`) by pushing the instance onto `Game#pending_triggers` instead of calling it right away.

**`Game#settle!`** drains pending triggers onto `game.stack` and resolves the stack, looping until it's empty or a *real* (non-`Choice::OrderTriggers`) choice is pending — call it after any raw engine mutation a spec makes outside `take_action`/`player.cast`/etc. (`permanent.destroy!`, `permanent.sacrifice!`, `permanent.exile!`, `game.notify!(...)`, `p1.draw!`, `p1.gain_life(...)`, `.perform` called directly on an action, ...) before asserting on the result. `Choice::OrderTriggers` (a player's own 2+ simultaneous triggers) auto-resolves transparently inside `Game#check_state_based_actions!` itself — there's no real agent yet to make that decision, so every checkpoint (not just `settle!`) absorbs it rather than blocking on it.

Turn-phase transitions (`upkeep!`, `draw!`, `first_main!`, `beginning_of_combat!`, `end!`, `final_attackers_declared!`, `deal_combat_damage`, and the `PreliminaryAttackersDeclared` step inside `attackers_declared!`) call `settle!` themselves — a plain `current_turn.upkeep!` etc. already resolves whatever it triggers. What *doesn't* auto-settle: `ResolvePermanent` (see below), any raw `permanent`/`player` method call, and anything reached via `game.notify!`/`receive_event` directly.

**`ResolvePermanent` auto-settles** after creating the permanent (skip with `settle: false`, needed when a spec deliberately leaves something else on the stack/pending — e.g. targeting a still-on-the-stack spell with a later cast, or building up multiple stack items before asserting) — **except for Auras**, which are skipped automatically (a fixture that builds one unattached and calls `#attach_to!` as a separate step would otherwise have it die to SBA 704.5m before attaching). A `subject`/`let` (non-bang) permanent evaluated *lazily*, mid-test, can trigger this settle at an inconvenient moment (e.g. resolving a spell the test still wanted on the stack) — reference it (or `let!`/force it) before anything you need to stay pending.

**A trigger resolving can itself create new pending triggers** (e.g. a token entering the battlefield firing another permanent's ETB trigger) — this correctly produces a new `Choice::OrderTriggers` mid-stack-resolution if that player now has 2+ pending.

This does **not** yet let a player respond to a trigger with an instant — that needs real priority (A2/A3, engine-roadmap workstream A) built on top of this.

**Card bugs the more-accurate SBA-before-triggers-on-stack ordering exposed** (fixed while flipping the default; same pattern likely to recur — grep a card's `should_perform?`/`call` for "0/0 that becomes something" or "once per X" logic written across both methods before assuming a new failure here is a spec issue):
- A 0-toughness creature dies to SBA 704.5f *before its own ETB trigger even gets a chance to resolve*, since 704.3 checks SBAs before putting triggers on the stack. Any "enters with counters" card must use `Abilities::Static::AdditionalCountersForEntering` (applied synchronously inside `Permanent.resolve`, before the permanent is ever checked), not an ETB triggered ability — `AcademyElite` was fixed this way. `Clone`-style "you may have this enter as a copy of X" uses the `enters_as_copy` card macro instead: `Permanent.resolve` sets `copy_choice_pending`, which makes SBA 704.5f skip that 0/0 until its ETB choice is answered (`Clone`, `OmniChangeling`); the ETB `call`/choice must clear the flag on every path (accepted, declined, or nothing to copy).
- A card's own once-per-turn/one-shot guard must be written with the *mark* in `should_perform?` (or an overridden `trigger!`), not in `call` — `call` is deferred, so anything that itself creates more of the same event (e.g. a token entering re-firing the same trigger class) can queue a second instance before the first one's `call` ever runs and records the guard. Fixed this way: `OnduSpiritdancer::EntersTrigger` (moved its turn-log write into `trigger!`).
- `ElderfangRitualist`'s "return **another** target Elf card" search excluded only other cards, not its own (now-in-the-graveyard-by-resolution-time) card — add `- [actor.card]` (or equivalent) to any "another X" search/filter that runs off a death/leaves-the-battlefield trigger.

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

## Priority (opt-in)

`Game.new(enforce_priority: true)` turns on the priority model: `game.priority_player` holds priority, `game.pass_priority!` passes it (both players passing resolves the top stack item via `Stack#resolve_top!`, or ends the step via `Turn#advance_step!` when the stack is empty), and `Turn#take_action` raises `IllegalAction` ("does not have priority") for other players. Steps don't auto-resolve triggers in this mode (`Turn#checkpoint!` only runs SBAs and queues triggers), so a spec must pass priority to resolve them. Default is off (specs drive both players directly). See `spec/game/integration/priority_spec.rb`. Actions that never use priority override `uses_priority?` to `false`.

## Combat

`CombatPhase#declare_blocker` raises `CombatPhase::IllegalBlock` (or `AttackerHasProtection`) for an illegal block; `#can_block?`/`#block_illegal_reason` are the query forms. Menace-style constraints are checked when the turn enters `combat_damage` (`validate_blocks!`), not per blocker. Grant evasion in specs with `grant_keyword(Magic::Cards::Keywords::FLYING)` etc. (`Landwalk.new("Forest")` for landwalk). A creature that enters tapped (e.g. `Forgotten Sentinel`) needs `untap!` before it can block. Combat damage is dealt per step (`deal_first_strike_damage`, `deal_combat_damage`), attackers and blockers together, all computed before applying; a lone blocker is assigned *all* of the attacker's damage, not just lethal. Override the split with `current_turn.combat.assign_combat_damage(attacker, blocker => n)` before damage.

## Targeting Keywords (hexproof, shroud, protection, ward)

`Permanent#can_be_targeted_by?(source, controller:)` (and `Player#`) is the one place shroud, hexproof, `HexproofFrom` and protection are decided. `Cast#can_target?`, `Cast::Mode#can_target?` and `Ability#valid_targets?` (activated **and** loyalty abilities) call it via `Targetable.targetable_by?`, so `targeting(...)` raises for an illegal target. Known gap: `Choice::Targeted` (trigger targets) is **not** filtered, since it can't tell "target" from "choose". Ward is two triggers (`WARD_TRIGGER` on `SpellCast`, `WARD_ABILITY_TRIGGER` on `AbilityActivated`) pushing `Choice::Ward`; resolve it with `game.resolve_choice!(payment: {...})` (empty payment counters the spell/ability). Specs that used a red spell against protection-from-red now correctly fail: use another colour.

## Indestructible, Regeneration, Protection from Damage

`Permanent#destroy!` is the replacement point: indestructible returns false, then a regeneration shield (`regenerate!` adds one; `regenerated!` spends it: tap, clear damage and `@marked_for_death`, `CombatPhase#remove_from_combat`, fire `Events::Regenerated`) returns false too. Both also cover SBA lethal damage/deathtouch since it calls `destroy!`. Shields reset in `Permanent#cleanup!`. `put_into_graveyard!`/`sacrifice!` bypass both. Protection prevents damage in `TargetedEffect#damage_prevented?` (used by `DealDamage`, `DealCombatDamage`), which resolves an ability source to its permanent. "Can't be regenerated" is not modelled.
