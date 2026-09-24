# Engine Roadmap

Plan for the major rules gaps in the engine, split into workstreams that can be picked up independently by a human or an agent. Written 2026-09-21 against `master` at `863ebad` (1328 specs, all green).

Findings below come from reading the code, not from running experiments. Anything marked **(verify)** was inferred from a failed grep rather than a read; confirm it before building on it.

## How to use this document

- Each workstream is one or more PRs. Sub-items (e.g. `D2`) are the unit of work: one branch, one PR, one commit series.
- Every workstream lists **Depends on**. Anything with "none" can start today.
- Every workstream has a **Done when** list. Those are integration specs, in the style of `spec/game/integration/`, not unit tests of private methods.
- Keep the suite green at every commit. Baseline: `bundle exec rspec` → 1328 examples, 0 failures.
- Record new gotchas in `CLAUDE.md` or `docs/patterns/*.md` in the same commit, per the existing workflow rule.
- Existing specs lean on manual `game.tick!` calls and synchronous trigger resolution. When a workstream changes those semantics, it owns updating the affected specs. Prefer adding a spec helper (in `spec/spec_helper.rb`) over editing 100 spec files by hand.

## Where things stand

What exists: turn state machine, a LIFO stack with choices, a synchronous event bus (`Turn#notify!` → every listener's `receive_event`), replacement effects with chooser ordering, counters, sagas, planeswalkers, emblems, monarch, ~570 card files.

The big structural facts that drive this plan:

1. **No priority.** `Stack#resolve!` (`lib/magic/stack.rb:88`) drains the whole stack in a loop. Triggered abilities run synchronously inside `notify!` and never touch the stack.
2. **State-based actions are not a thing.** `Game#tick!` (`game.rb:189`) does continuous effects, state triggers and dead-creature cleanup, and is only called from combat damage. No life ≤ 0 check, legend rule or planeswalker-0-loyalty check turned up **(verify)**.
3. **Actions are not validated.** `Turn#take_action` (`game/turn.rb:158`) calls `action.perform` directly. `can_perform?` exists on only `Cast`, `Cycle` and `PlayLand`, and nothing calls it.
4. **Combat is a simplified model.** `CombatPhase#can_block?` only checks protection. Flying, reach, menace and friends are never consulted. `Attack#resolve` makes blockers deal damage in whatever step the attacker's attack resolves, so a first-strike blocker does not strike first.
5. **No decision-maker.** Specs call `player.cast(...)`, `pay_mana(...)`, `declare_attacker(...)` directly. There is no interface a bot, UI or network player could implement, and no way to ask "what can this player legally do right now?".
6. **Continuous effects are a fixed pipeline, not layers.** `Permanents::ContinuousEffects#apply!` computes types → abilities/keywords → power/toughness in one pass. No timestamps, no dependency, no colour or control layer, no 7a–7d sublayers.
7. **Mana is a flat hash** (`Player#mana_pool`). No restrictions, no emptying between steps **(verify)**.
8. **No game setup.** `Game#start!` draws seven cards. No mulligan, no deck loading, no choice of who goes first **(verify)**.
9. **Two players assumed** (`Game#next_active_player` rotates the `players` array; specs use `"two player game"`).
10. **Keywords are scattered.** `lib/magic/cards/keywords.rb` has a fixed list of predicate methods, and `keyword_handlers/` holds only `prowess.rb`.

## Dependency map

```
Tier 0 (start now, parallel)     Tier 1                Tier 2
------------------------------   -------------------   -------------------
B  State-based actions      ---->
C1 Action legality/timing   ---->  A  Priority + stack --> C2 Decision interface
D  Combat correctness                                 --> I  Multiplayer / Commander
E  Keyword framework                                  --> L2 Fuzz/self-play testing
F  Layers
G  Mana + casting pipeline
H1 Cleanup step
J  Object identity / copies
K  Mechanics long tail
L1 Tooling
H2 Game setup / mulligans (needs C2 for the decisions, but deck loading can start now)
```

Recommended order if only one thing can happen at a time: **B → C1 → A → C2**. That is the spine; everything else hangs off it or is orthogonal.

## Merge-conflict hotspots

Five files get touched by nearly every workstream. Agree on an owner per wave to avoid rebase pain.

| File | Primary owner | Others touch it for |
|---|---|---|
| `lib/magic/stack.rb` | A | G (fizzle), C1 |
| `lib/magic/game/turn.rb` | A | H, C1, D |
| `lib/magic/game.rb` | B (`tick!`), A | I, H2 |
| `lib/magic/permanent.rb` | F | B, D, J |
| `lib/magic/game/combat_phase.rb` | D | A (priority in combat), I |

---

## B. State-based actions (rule 704)

**Status (2026-09-21): B1–B3 done and merged to `master`.** `Game::StateBasedActions` covers 704.5a–d, f–j, m, n and q. Deviations from the plan below: SBAs also run after each `take_action`, stack resolution and choice resolution (skipped while a choice is pending); `Game#tick!` is kept as an alias so specs did not need rewriting (B3 reduced to fixing two specs that relied on the old behaviour: `sublime_epiphany_spec`, `auras_sent_to_graveyards_spec`). Follow-ups found along the way and also done: `Permanent#destroy!` now respects indestructible (raw move is `put_into_graveyard!`); Auras declare `enchant ...` restrictions that SBAs enforce, along with protection; `Game#over?`/`#drawn?`/`#winner`. Still open: nothing stops a game that is over (belongs with A/C2), and the rest of 704.5 that this pass doesn't cover (e.g. the saga, battle, and Role rules) hasn't been audited.

**Problem.** `Game#tick!` is a partial, ad-hoc SBA pass called from two places. Most of rule 704.5 is missing, and SBAs are not checked after stack resolution or between game actions.

**Scope.**
- B1. Extract `Game#check_state_based_actions!` that loops until a pass changes nothing. Move dead-creature handling, state triggers and continuous-effect refresh into it. Call it after every resolution, after combat damage, and after every action.
- B2. Add missing SBAs: player at ≤ 0 life; 10+ poison counters; drew from empty library (flag set by `Player#draw!`, checked here rather than losing immediately); legend rule (with a player choice via `Choice`); planeswalker with 0 loyalty; +1/+1 and −1/−1 counter annihilation; Auras attached illegally or to nothing; Equipment attached illegally; tokens outside the battlefield cease to exist; creature with lethal damage *or* deathtouch damage *or* toughness ≤ 0. Respect `indestructible?` for damage/deathtouch deaths but not toughness ≤ 0.
- B3. Remove the now-redundant manual `game.tick!` calls from specs where the engine handles it, or leave them as no-ops. Do not rewrite specs wholesale.

**Entry points.** `lib/magic/game.rb` (`tick!`, `move_dead_creatures_to_graveyard`), `lib/magic/player.rb` (`lose!`, `draw!`, `lose_life`), `lib/magic/permanent.rb` (`destroy!`, `alive?`), `spec/game/integration/auras_sent_to_graveyards_spec.rb` (existing partial coverage).

**Done when.** One integration spec per rule in 704.5 listed above. A player at 0 life loses without any `tick!` in the spec. Two legendary permanents with the same name cause a keep-one choice.

**Depends on.** None. A later hooks this into the priority loop (SBAs run before any player would receive priority).

**Size.** Medium. **Good for.** Agent, one sub-item per PR.

---

## C. Legality and decision interface

Two independent halves.

### C1. Action legality and timing enforcement

**Status (2026-09-21): done and merged to `master` (local, not yet pushed).** `Action#illegal_reason`/`#legal?` plus `Turn#take_action` raising `Magic::IllegalAction`; details, gotchas and the spec-side consequences are in `CLAUDE.md` under "Action Legality". Deviations and leftovers:
- `can_perform?` stayed as the advisory affordability check; `illegal_reason` is the new contract, because it runs after costs are paid. So timing/requirement failures can still leave mana spent or a source tapped (only `{T}` is checked as it is paid). Real fix belongs with G3 (cost framework) or A (priority), which should check legality *before* costs are paid.
- A card with no zone (bare spec fixture) is treated as being in hand. Every spec that casts still needs a real zone before this can be strict; that is a mechanical follow-up.
- `by_effect: true` on `Cast` is a stopgap for effect-instructed casts (rebound, Idol of Endurance); G3 should replace it with proper alternative-cost/permission objects.
- Not covered: planeswalker abilities beyond one per turn per walker (no "additional activation" effects), attacking a planeswalker or battle vs a player, attack requirements/costs (D4), flash-granting effects ("cast as though it had flash"), the adventure half's own card type (adventures are treated as sorcery-speed, which is wrong for an instant adventure), abilities activated from non-battlefield zones, `{T}`-cost checks for `Costs::Tap`/`MultiTap`.
- Bugs this surfaced and fixed: Oracle of Mul Daya and Radha never had a top-of-library permission, Valakut Exploration had no exile permission, `Token` lacked `additional_lands_per_turn`, Speaker of the Heavens leaked `Magic::Cards::ActivatedAbility` (order-dependent World Map failure), and about 20 specs that only passed because timing, tapped state or loyalty cost were never checked.

**Problem.** Nothing stops a player casting a sorcery during combat, playing a second land, attacking with a summoning-sick or tapped creature, or activating a planeswalker ability twice in a turn. `Game::Turn#can_cast_sorcery?` exists (`turn.rb:220`) but is not enforced.

**Scope.** `Action#legal?` (or make `can_perform?` a real base-class contract) that `Turn#take_action` checks, raising `Magic::IllegalAction` with a reason. Rules to enforce: sorcery-speed timing (main phase, empty stack, active player), flash/instant timing, one land per turn (already partly in `PlayLand`), summoning sickness for attack and `{T}` costs (unless haste), tapped/untapped requirements, planeswalker one-activation-per-turn, `player.spell_cast_limit`, cards must be in the correct zone, costs payable.

**Entry points.** `lib/magic/action.rb`, `lib/magic/actions/*.rb`, `lib/magic/game/turn.rb`.

**Done when.** Each rule above has a spec asserting the illegal attempt raises and the legal attempt still works. Whole suite still green; fix any spec that only passed because timing was not enforced, and note each such fix in the PR description (those are the interesting bugs).

**Depends on.** None. **Size.** Medium. **Good for.** Agent.

### C2. Decision-provider interface and game runner

**Problem.** There is no seam for "ask the player what to do". This blocks bots, a UI, network play, and automated testing of whole games.

**Scope.**
- C2a. Define `Magic::Agent` (or `Player#controller`) with methods like `choose_action(game, legal_actions)`, `choose_targets`, `choose_blockers`, `choose_mana_payment`, `resolve_choice(choice)`. Ship a `ScriptedAgent` (queue of answers, for specs) and a `FirstLegalAgent`.
- C2b. `Game#legal_actions(player)`: enumerate castable spells, playable lands, activatable abilities, attack/block declarations. Builds on C1's legality predicate.
- C2c. `Game#run!` main loop: while game not over, ask the player with priority for an action. Requires A for real semantics; before A lands, it can drive turn-level actions only.
- Existing `Stack#choices` queue becomes "ask the choice's `controller`'s agent" instead of waiting for specs to call `resolve_choice!`.

**Entry points.** `lib/magic/player.rb`, `lib/magic/choice.rb`, `lib/magic/stack.rb` (choices).

**Done when.** A full game between two `FirstLegalAgent`s runs to completion with no exceptions. Existing specs keep working unchanged because default behaviour is "no agent → caller drives".

**Depends on.** C1 (legal actions), A (priority loop). C2a can start earlier. **Size.** Large. **Good for.** Human-led design, agent-implemented pieces.

---

## A. Priority passing, the stack, and triggers

**Problem.** The single biggest gap. Players cannot respond. Triggered abilities resolve during event dispatch instead of going on the stack, so there is no APNAP ordering and no way to respond to a trigger. Split second, "can't be countered while X", and "in response to" effects are impossible.

**Scope.**
- A1. **Trigger queue.** `TriggeredAbility` instances created during `notify!` go into a pending list on the game instead of running. The next time a player would receive priority, put pending triggers on the stack in APNAP order (active player's first, i.e. lowest on the stack), with a `Choice` for ordering a player's own simultaneous triggers.
  - Keep the existing synchronous path behind a switch so the suite can migrate card-by-card. The default flips once the suite is green.
  - Watch out for triggers that currently rely on synchronous resolution: ETB triggers used as replacement-ish behaviour, and "enters tapped" patterns documented in `docs/patterns/triggers.md`.
- A2. **Priority model.** `Game#priority_player`, `Game#pass_priority!`. Active player gets priority first in each step that grants it; both players passing in succession with an empty stack ends the step; with a non-empty stack, resolves the top item then gives the active player priority again. Steps without priority (untap, cleanup) stay as-is.
- A3. **Stack resolution one item at a time.** Replace the recursive drain in `Stack#resolve!` with `resolve_top!`. Keep `resolve!` as a spec-friendly "pass priority until the stack is empty" helper.
- A4. **Responses.** Instants, flash, activated abilities, and mana abilities (which do not use the stack) cast/activated while the stack is non-empty. `can_cast_sorcery?` becomes real.
- A5. **Interaction with SBAs and choices.** Run B's SBA pass, then put pending triggers on the stack, before each priority grant. Choices pause the loop as they do today.
- A6. Split second, "counter target spell" edge cases, and stack-item legality on resolution belong in G2/E, not here.

**Entry points.** `lib/magic/stack.rb`, `lib/magic/game/turn.rb` (state machine transitions), `lib/magic/game.rb`, `lib/magic/triggered_ability.rb`, `lib/magic/permanent.rb` (`dispatch_event_handlers`, `perform_trigger!`), `lib/magic/actions/cast.rb`.

**Done when.**
- Two simultaneous triggers from different controllers resolve in APNAP order.
- A player can cast an instant in response to a trigger, and it resolves first.
- Both players passing with an empty stack advances the step.
- The whole existing suite passes with the new default.

**Depends on.** B (SBAs to slot in) and C1 (timing rules). A1 can begin before either if the switch keeps old behaviour.

**Size.** Very large; sequence A1 → A2/A3 → A4 → A5. **Good for.** One human lead plus agents on A1/A4; A2/A3 are the delicate part and deserve a human's eyes.

---

## D. Combat correctness

**Status (2026-09-24): D1–D3 done.** Specs: `spec/game/integration/combat/{blocking_restrictions,first_strike_blockers,damage_assignment}_spec.rb`. Deviations from the plan below:
- D1 covers flying/reach, menace, skulk, tapped blockers, blockers the defending player doesn't control, one attacker per blocker, and blocking something that isn't attacking. Fear, intimidate, shadow, horsemanship and landwalk have no keyword in the engine yet, so they're left for E. Menace is checked by `CombatPhase#validate_blocks!` when leaving the declare blockers step.
- D3 follows the current rules (Foundations removed damage assignment order): the attacking player divides damage however they like, with trample still needing lethal damage on every blocker first. Instead of a `Choice`, the seam is `current_turn.assign_combat_damage(attacker, { blocker => n, player => n })`, validated on the spot; until C2 exists, that's how a spec or caller makes the decision. Without one, the default is lethal damage to each blocker in the order declared, and what's left goes to the player (trample) or the last blocker.
- A blocked attacker whose blockers have all left combat stays blocked and deals no damage unless it has trample (509.1h). A creature with 0 or less power deals no combat damage.
- Bug this surfaced: `brash_taunter_spec` expected a 2/2 attacker to deal only 1 damage to its single 1/1 blocker.
- Still open: D4, D5, and 510.1c's "damage from other creatures assigned in the same step" when working out lethal damage.

**Problem.** See fact 4 above. In addition, `Attack#resolve` assigns `[blocker.toughness, damage].min` to each blocker in turn: it ignores damage already marked, ignores deathtouch when not trampling, and gives the attacking player no ordering or split choice.

**Scope.**
- D1. **Blocking legality.** Make `CombatPhase#declare_blocker` consult `Permanent#can_block?` and evasion: flying/reach, menace (≥ 2 blockers), fear, intimidate, shadow, skulk, horsemanship, landwalk, "can't be blocked", "can't block", protection. Blocker must be an untapped creature the defending player controls. A blocker may block only one attacker unless a card says otherwise. Validate menace-style constraints when blocks are *finalised*, not per blocker.
- D2. **Damage step rewrite.** Separate the first-strike damage step from the regular one: each step deals damage from the creatures that qualify in that step, attackers and blockers alike. Double strike deals in both. Lifelink, deathtouch, wither and infect apply per damage event, not per creature.
- D3. **Damage assignment.** Attacker's controller orders blockers and assigns lethal-then-rest, via a `Choice`. Default (no agent): current auto behaviour but correct lethal calculation, including damage already marked and deathtouch. Trample and "trample over planeswalkers" build on this.
- D4. **Attack restrictions and requirements.** "Attacks each combat if able", "can't attack unless…", attack costs (Propaganda), "must be blocked", attacking a planeswalker or battle vs a player, removal from combat, creatures that become attacking/blocking mid-combat.
- D5. **Combat triggers timing.** Ensure `CreatureBlocked`, `AttackersDeclared` etc. fire once and at the right step. Coordinate with A so triggers land on the stack in the right window (declare attackers, declare blockers, combat damage).

**Entry points.** `lib/magic/game/combat_phase.rb`, `lib/magic/game/turn.rb`, `lib/magic/effects/deal_combat_damage.rb`, `lib/magic/permanents/creature.rb`, `spec/game/integration/combat/`.

**Done when.** A spec per keyword above. A first-strike blocker kills a non-first-striking attacker before it deals damage. Deathtouch plus trample assigns 1 and tramples the rest (already covered; keep it passing).

**Depends on.** None for D1–D3. D5 wants A. **Size.** Large, splits cleanly into five PRs. **Good for.** Agent.

---

## E. Keyword and ability framework

**Problem.** Keyword behaviour is spread across `Cards::Keywords` predicates, per-effect checks and one handler module. Adding a keyword means hunting for every place it must be checked. No generic `Fight`; `CopyEffect` exists (`lib/magic/copy_effect.rb`) but copy-spell semantics are card-by-card (**verify**).

**Scope.**
- E1. **Keyword audit.** Build a table (in `docs/keywords.md`) of every Oracle keyword: implemented / partial / missing / n.a., with the file that owns it. Generate the candidate list from `data/oracle-cards-*.jsonl` (`Magic::Oracle`). This is a research task and the input for E2–E4.
- E2. **Targeting keywords enforced generically.** Hexproof, shroud, protection (targeting, damage, blocking, enchanting/equipping), ward as a real triggered ability tied to the stack. One central `can_be_targeted_by?(source)` that every targeting path uses.
- E3. **Evergreen combat/damage keywords.** Coordinate with D. Indestructible, regeneration as a replacement shield, `Permanent#regenerate!` currently just untaps and clears damage.
- E4. **Cost and cast keywords.** Convoke, delve, affinity, emerge, alternative costs, evoke, overload, cycling variants, flashback/escape/disturb, buyback, kicker variants. Shares a design with G3, so land G3 first or pair them.
- E5. **Triggered and static keywords as reusable handlers.** Exalted, annihilator, persist, undying, cascade, evolve, extort, prowess (exists), landfall (exists), ninjutsu, etc. Follow the shape of `keyword_handlers/prowess.rb`.
- E6. **Generic effects.** `Effects::Fight`, `Effects::CopySpell`, `Effects::Bounce`, `Effects::Mill`, etc., so cards stop hand-rolling them.

**Entry points.** `lib/magic/cards/keywords.rb`, `lib/magic/cards/keyword_handlers/`, `lib/magic/effects/`, `lib/magic/protection.rb`, `lib/magic/targetable.rb`.

**Done when.** Per keyword: one integration spec, and card files that previously hand-rolled the behaviour are migrated or left with a note. E1's table shows no "unknown" rows.

**Depends on.** None (E1–E3, E5–E6). E4 pairs with G3. **Size.** Large; every sub-item is independently shippable. **Good for.** Agents; E1 first.

---

## F. Layers and continuous effects (rule 613)

**Problem.** See fact 6. Consequences: control-changing effects, colour-changing effects, "loses all abilities", Humility-style interactions, and copy effects layered over other effects cannot be modelled correctly.

**Scope.**
- F1. **Effect objects with timestamp and duration.** Replace the ad-hoc `modifiers` array and `until_eot` flags on `Permanent` with a `ContinuousEffect` that has a layer, a timestamp, a source, and a duration (`until_end_of_turn`, `while_source_on_battlefield`, `permanent`).
- F2. **Layers 1–7d.** Copy (1), control (2), text (3), type (4), colour (5), ability add/remove (6), power/toughness: characteristic-defining (7a), set (7b), modify including counters (7c), switch (7d). Apply in order, by timestamp within a layer.
- F3. **Dependency ordering** within a layer (613.8). Can be a follow-up; start with timestamp only and leave a documented hook.
- F4. **Cleanup of durations.** Replace `remove_until_eot_*` in `Permanent#cleanup!` with duration expiry driven by the turn structure (cleanup step, "until your next turn", etc.).

**Entry points.** `lib/magic/permanents/continuous_effects.rb`, `lib/magic/permanents/modifications/`, `lib/magic/static_ability.rb`, `lib/magic/abilities/static/`, `lib/magic/permanent.rb`.

**Done when.** A spec per layer, plus at least two documented interaction cases (e.g. a P/T setter and a +1/+1 anthem applied in either timestamp order give the right result). Existing static-ability specs unchanged.

**Depends on.** None. J3 (copy) uses layer 1. **Size.** Large. **Good for.** Human-led design; agent implementation of F4.

---

## G. Mana, casting, and cost pipeline

**Scope.**
- G1. **Mana objects.** Replace the flat `color => count` pool with mana that remembers its source and restrictions ("spend only on creature spells", "…only to activate abilities"). Pool empties at end of each step and phase. Today restricted mana is documented as unenforced (`docs/patterns/costs.md`); this removes that caveat. Keep `add_mana(green: 2)` and `pay_mana(...)` working for specs.
- G2. **Resolution-time legality.** On resolution, re-check targets. A spell or ability with all targets illegal fizzles (does not resolve); with some illegal targets, resolves without affecting them. `Stack::TargetedCast#validate!` is a starting point.
- G3. **Cost framework.** A single `CostSet` pipeline for additional costs, alternative costs, cost increases/reductions, and X, with explicit order (601.2f–h). Sits under `Actions::Cast` and `Actions::ActivateAbility`. Includes Phyrexian, hybrid and snow mana.
- G4. **Choice and cost validation layer.** Modal spells validate mode counts, distributions validate sums, colour choices validate allowed sets. Today these are unenforced and duplicated in card classes (see the many "nothing validates…" notes in `docs/patterns/`).

**Entry points.** `lib/magic/mana.rb`, `lib/magic/player.rb` (mana pool), `lib/magic/costs/`, `lib/magic/actions/cast.rb`, `lib/magic/actions/activate_ability.rb`, `lib/magic/choice.rb`.

**Done when.** Restricted-mana cards (e.g. `PlazaOfHeroes`) actually enforce the restriction. A fizzle spec exists. Mana empties between steps.

**Depends on.** None (G1, G2, G4). G3 and E4 pair up. **Size.** Large in total, each item medium. **Good for.** Agent.

---

## H. Turn structure and game setup

- H1. **Cleanup step.** Discard to hand size (7) with a choice; remove marked damage; end "until end of turn" effects simultaneously; a second cleanup if triggers fire. Today `Turn` calls only `battlefield.cleanup` → `Creature#cleanup!`. *Depends on:* none for the basics; F4 for durations. *Size:* small.
- H2. **Game setup.** Deck loading and validation (60-card / Commander), shuffle with a seedable RNG, choose starting player, London mulligan, first player skips their first draw. `Game.start!` today just draws seven. *Depends on:* deck loading and RNG none; mulligan decisions need C2.
- H3. **Extra and skipped turns, phases and steps.** `take_additional_turn` and `queue_additional_combat!` exist. Add "skip your next draw step", extra main phases, "end the turn" effects (Time Stop), and end-of-game handling (win/draw detection, concession, draw when both lose simultaneously).

**Entry points.** `lib/magic/game/turn.rb`, `lib/magic/game.rb`, `lib/magic/zones/library.rb`.

**Size.** Small to medium each. **Good for.** Agent.

---

## I. Multiplayer and Commander

**Problem.** Fact 9. `opponents`, the monarch logic and "each opponent" effects all assume one opponent.

**Scope.**
- I1. **N-player turn order.** Stop mutating `players` with `rotate`. Track `active_player` and seat order separately; APNAP over N players; player elimination mid-game (removes their permanents, spells and triggers).
- I2. **"Each opponent" audit.** Search `lib/magic/cards/` for `opponents.first`, `players.last`, and similar; convert to iterate over all opponents. Add a three-player shared context to `spec_helper.rb` and a spec for a representative card.
- I3. **Commander format.** Command zone (`Zones::Command` exists), commander tax, commander damage SBA, colour identity, "partner", commander-replacement choice for graveyard/exile. `Player#add_commander` exists (from `CommandTower`) but nothing uses it beyond that.
- I4. **Multiplayer rules.** Range of influence is optional. Shared team turns are out of scope.

**Depends on.** A (APNAP for triggers) for full correctness; I1/I2 can start earlier. **Size.** Large. **Good for.** Human-led for I1, agent for I2 (mechanical).

---

## J. Object identity, copies, and hidden information

- J1. **New-object rule and last-known information.** A card that changes zones is a new object. Triggers and abilities that reference "it" after it left need last-known information (power, controller, counters when it left). Today `Permanent` and `Card` are separate but referencing dead permanents from triggers leans on luck.
- J2. **Multi-face cards.** Transform / double-faced cards, modal DFCs, split cards, adventure (partly supported via `adventure:` on `Cast`), aftermath, meld. Decide on a single `Card#faces` representation. `Permanent#transform!` exists for a narrow case.
- J3. **Copy framework.** Copiable values, copying permanents (including their triggered and static abilities; currently only characteristics are live-copied, per `docs/patterns/zones_and_state.md`), copying spells and abilities on the stack, token copies. Uses F's layer 1.
- J4. **Hidden information views.** `Game#view_for(player)` returns what that player may see: own hand, opponents' hand sizes, revealed cards only. Required for any UI, network play or non-cheating agent.

**Depends on.** J3 wants F. J1, J2, J4 none. **Size.** Medium to large. **Good for.** Agent (J2, J4), human (J1, J3 design).

---

## K. Mechanics long tail

Independent, card-driven features. Pick them up when a card needs one, or batch them. Each is one PR with a spec and a note in `docs/patterns/mechanics.md`.

- Auras and Equipment attach rules (enchant restrictions, equip cost and timing, reattach on move).
- Vehicles and crew; Levelers; Classes; Rooms; Battles and sieges.
- The four Ring abilities (`Emblem::TheRing#level` tracks the level, nothing reads it; see `docs/patterns/mechanics.md`).
- Day/night, initiative and dungeons, energy, experience, poison variants (toxic, proliferate exists).
- Alternative casting zones: escape, disturb, foretell, adventure, plot, impending, prototype.
- Face-down permanents: morph, manifest, disguise, cloak.
- Planeswalker uniqueness (`loyalty` rules) once B lands.
- Replacement-effect completeness beyond the current chooser (self-replacement ordering, "instead" text, prevention effects and damage prevention shields).

**Depends on.** Varies; most depend on nothing. **Good for.** Agent per item.

---

## L. Tooling and confidence

- L1. **Card coverage report.** `rake coverage`: compares `data/oracle-cards-*.jsonl` (filtered to the card pool being targeted) with `lib/magic/cards/`. Lists unimplemented cards grouped by the mechanic they need, feeding K and E1. Cheap and useful for prioritising every other workstream.
- L2. **Self-play fuzzing.** With C2's `FirstLegalAgent` or a random agent and a seeded RNG (H2), play many games between random decks and assert invariants: the stack is empty at end of turn; no negative life without a loss; every permanent belongs to exactly one zone; card count is conserved. Any crash is a bug report.
- L3. **Comprehensive Rules conformance specs.** A `spec/rules/` directory with one file per rules section (e.g. `rule_704_spec.rb`) mapping rule numbers to specs, written as workstreams land. Ties each workstream's "Done when" to something citable.
- L4. **Game log and replay.** `EventLog` (`game/event_log.rb`) already records events per turn. Serialise it plus RNG seed so a failing game can be replayed.

**Depends on.** L1 none, L3 none, L4 none. L2 needs C2 and H2. **Good for.** Agent (L1, L3), human (L2 design).

---

## Suggested waves

**Wave 1 (parallel; no dependencies):** B, C1, D1–D3, E1, F1–F2, G1, G2, H1, J2, J4, L1, L3.
**Wave 2:** A (needs B, C1), D4–D5, E2–E6, F3–F4, G3–G4, H2, H3, J1, J3.
**Wave 3:** C2, I, K, L2, L4.

Within Wave 1, put the human's attention on B and C1, because A can't start meaningfully without them, and let agents take D, E1, G and L in parallel.

## Explicitly out of scope

A graphical or network UI; AI opponents beyond the trivial agents in C2; sanctioned-tournament rules, sideboarding and match structure; Un-sets and other silver-border mechanics; digital-only (Arena) cards.
