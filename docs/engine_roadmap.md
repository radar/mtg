# Engine Roadmap

Plan for the major rules gaps in the engine, split into workstreams that can be picked up independently by a human or an agent. Written 2026-09-21; facts and statuses refreshed 2026-09-26 against `master` at `3a1b5f9d` (2235 specs, all green).

Findings below come from reading the code, not from running experiments. Anything marked **(verify)** was inferred from a failed grep rather than a read; confirm it before building on it. The workstream sections keep their original "Problem" text for history; each one's **Status** note says what has changed since.

## How to use this document

- Each workstream is one or more PRs. Sub-items (e.g. `D2`) are the unit of work: one branch, one PR, one commit series.
- Every workstream lists **Depends on**. Anything with "none" can start today.
- Every workstream has a **Done when** list. Those are integration specs, in the style of `spec/game/integration/`, not unit tests of private methods.
- Keep the suite green at every commit. Baseline: `bundle exec rspec` → 2235 examples, 0 failures.
- Record new gotchas in `CLAUDE.md` or `docs/patterns/*.md` (or `docs/card_patterns.md`) in the same commit, per the existing workflow rule.
- Existing specs lean on manual `game.tick!` calls and synchronous trigger resolution. When a workstream changes those semantics, it owns updating the affected specs. Prefer adding a spec helper (in `spec/spec_helper.rb`) over editing 100 spec files by hand.

## Where things stand

What exists: turn state machine, a LIFO stack with choices, a synchronous event bus (`Turn#notify!` → every listener's `receive_event`), replacement effects with chooser ordering, counters, sagas, planeswalkers, emblems, monarch, ~640 card files, state-based actions (B), action legality (C1), a trigger queue (A1, default on), an opt-in priority loop (A2/A3), blocking legality and per-step combat damage (D1–D3), and generic targeting/destruction keywords (E1–E3).

The structural facts that drive the remaining plan (items 1–5 were gaps when this was written; 1–4 are now closed or partly closed, as noted):

1. ~~No priority.~~ **Closed, by design opt-in.** Triggers go on the stack (A1, default) and a priority loop exists (`Game#pass_priority!`, `Stack#resolve_top!`), gated behind `Game.new(enforce_priority: true)`. This isn't a temporary state waiting for a default flip: card specs test card mechanics, not priority-passing, so they drive both players directly and use `Stack#resolve!` to drain the stack, the same way they always have; `enforce_priority` is exercised by the specs that are actually about priority/responses/whole-game play (`priority_spec.rb`, `game_runner_spec.rb`, `self_play_spec.rb`). Split second and combat-damage trigger windows are still open.
2. ~~No state-based actions.~~ **Closed** (B). `Game#check_state_based_actions!` runs after actions, resolutions and checkpoints.
3. ~~Actions are not validated.~~ **Closed** (C1). `Turn#take_action` asks `illegal_reason` and raises `Magic::IllegalAction`. Costs are still paid before that check (see C1).
4. ~~Combat is a simplified model.~~ **Closed for D1–D3.** Blocking legality, first-strike steps and damage assignment are done. Attack restrictions/requirements (D4) and trigger windows (D5) are open.
5. **No decision-maker.** Specs call `player.cast(...)`, `pay_mana(...)`, `declare_attacker(...)` directly. There is no agent interface for a bot, UI or network player, and no `legal_actions` enumeration (C2). Still true.
6. **Continuous effects are a fixed pipeline, not layers.** `Permanents::ContinuousEffects#apply!` computes types → abilities/keywords → power/toughness in one pass. No timestamps, no dependency, no colour or control layer, no 7a–7d sublayers. Still true. (`Permanent` carries a `timestamp` but layers do not use it; `until_end_of_turn`/`modifiers` are still ad hoc.)
7. **Mana is a flat hash** (`Player#mana_pool`). No restrictions, and nothing empties it between steps. Still true.
8. **No game setup.** `Game#start!` (`game.rb:171`) draws seven cards. No mulligan, no deck loading, no seedable RNG, no choice of who goes first. Still true.
9. **Two players assumed** (`Game#next_active_player` rotates the `players` array; specs use `"two player game"`). `Game#opponents(player)` exists, but it is not audited. Still true.
10. **Keywords are only partly generic.** E1–E3 added targeting keywords, regeneration and protection, and `lib/magic/keywords.rb` plus per-card handlers cover changeling and others. `docs/keywords.md` lists what is still missing (789 of ~880 Oracle keywords, many of them n.a.). `keyword_handlers/` still holds only `prowess.rb`.

## Dependency map

```
Tier 0 (start now, parallel)     Tier 1                Tier 2   (B, C1, A1–A3, D1–D3, E1–E3 done)
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

Recommended order if only one thing can happen at a time: ~~B → C1 → A → C2~~ — all done. `enforce_priority` stays opt-in (see A's 2026-09-27 status: it's the wrong layer to force the whole suite through), so it's off the spine rather than the next link in it.

## Merge-conflict hotspots

Five files get touched by nearly every workstream. Agree on an owner per wave to avoid rebase pain.

| File | Primary owner | Others touch it for |
|---|---|---|
| `lib/magic/stack.rb` | A | G (fizzle), C1 |
| `lib/magic/game/turn.rb` | A | H, C1, D |
| `lib/magic/game.rb` | A (priority, `settle!`), B (SBA checkpoint) | I, H2 |
| `lib/magic/permanent.rb` | F | B, D, J |
| `lib/magic/game/combat_phase.rb` | D | A (priority in combat), I |

---

## B. State-based actions (rule 704)

**Status (2026-09-21): B1–B3 done and merged to `master`.** `Game::StateBasedActions` covers 704.5a–d, f–j, m, n and q. Deviations from the plan below: SBAs also run after each `take_action`, stack resolution and choice resolution (skipped while a choice is pending); `Game#tick!` is kept as an alias so specs did not need rewriting (B3 reduced to fixing two specs that relied on the old behaviour: `sublime_epiphany_spec`, `auras_sent_to_graveyards_spec`). Follow-ups found along the way and also done: `Permanent#destroy!` now respects indestructible (raw move is `put_into_graveyard!`); Auras declare `enchant ...` restrictions that SBAs enforce, along with protection; `Game#over?`/`#drawn?`/`#winner`. Still open: nothing stops a game that is over (belongs with A/C2), and the rest of 704.5 that this pass doesn't cover (e.g. the saga, battle, and Role rules) hasn't been audited.

**Original problem (solved; see status).** `Game#tick!` was a partial, ad-hoc SBA pass called from two places. Most of rule 704.5 is missing, and SBAs are not checked after stack resolution or between game actions.

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

**Status (2026-09-21): done and merged to `master`.** `Action#illegal_reason`/`#legal?` plus `Turn#take_action` raising `Magic::IllegalAction`; details, gotchas and the spec-side consequences are in `CLAUDE.md` under "Action Legality". Deviations and leftovers:
- `can_perform?` stayed as the advisory affordability check; `illegal_reason` is the new contract, because it runs after costs are paid. So timing/requirement failures can still leave mana spent or a source tapped (only `{T}` is checked as it is paid). Real fix belongs with G3 (cost framework) or A (priority), which should check legality *before* costs are paid.
- A card with no zone (bare spec fixture) is treated as being in hand. Every spec that casts still needs a real zone before this can be strict; that is a mechanical follow-up.
- `by_effect: true` on `Cast` is a stopgap for effect-instructed casts (rebound, Idol of Endurance); G3 should replace it with proper alternative-cost/permission objects.
- Not covered: planeswalker abilities beyond one per turn per walker (no "additional activation" effects), attacking a planeswalker or battle vs a player, attack requirements/costs (D4), flash-granting effects ("cast as though it had flash"), the adventure half's own card type (adventures are treated as sorcery-speed, which is wrong for an instant adventure), abilities activated from non-battlefield zones, `{T}`-cost checks for `Costs::Tap`/`MultiTap`.
- Bugs this surfaced and fixed: Oracle of Mul Daya and Radha never had a top-of-library permission, Valakut Exploration had no exile permission, `Token` lacked `additional_lands_per_turn`, Speaker of the Heavens leaked `Magic::Cards::ActivatedAbility` (order-dependent World Map failure), and about 20 specs that only passed because timing, tapped state or loyalty cost were never checked.

**Original problem (solved; see status).** Nothing stopped a player casting a sorcery during combat, playing a second land, attacking with a summoning-sick or tapped creature, or activating a planeswalker ability twice in a turn. `Game::Turn#can_cast_sorcery?` (`turn.rb:295`) existed but was not enforced; `Cast#illegal_reason` now uses it.

**Scope.** `Action#legal?` (or make `can_perform?` a real base-class contract) that `Turn#take_action` checks, raising `Magic::IllegalAction` with a reason. Rules to enforce: sorcery-speed timing (main phase, empty stack, active player), flash/instant timing, one land per turn (already partly in `PlayLand`), summoning sickness for attack and `{T}` costs (unless haste), tapped/untapped requirements, planeswalker one-activation-per-turn, `player.spell_cast_limit`, cards must be in the correct zone, costs payable.

**Entry points.** `lib/magic/action.rb`, `lib/magic/actions/*.rb`, `lib/magic/game/turn.rb`.

**Done when.** Each rule above has a spec asserting the illegal attempt raises and the legal attempt still works. Whole suite still green; fix any spec that only passed because timing was not enforced, and note each such fix in the PR description (those are the interesting bugs).

**Depends on.** None. **Size.** Medium. **Good for.** Agent.

### C2. Decision-provider interface and game runner

**Status (2026-09-27): C2a done.** `Magic::Agent` (`lib/magic/agent.rb`) documents the contract (`choose_action`, `choose_targets`, `choose_blockers`, `choose_mana_payment`, `resolve_choice`) by raising `NotImplementedError`; `Magic::Agents::ScriptedAgent` answers from a queue passed at construction (raises `OutOfAnswers` once it's empty); `Magic::Agents::FirstLegalAgent` takes the first option offered (including a `nil` "pass"), declines every block, and has no generic answer for `resolve_choice` yet (`Choice` subclasses each expect a different answer shape — see C2b/C2c). Nothing in the engine calls these yet; `Player` has no `agent`/`controller` attribute. Specs: `spec/agent_spec.rb`, `spec/agents/`.

**Status (2026-09-27): C2b done, including blocks.** `Game#legal_actions(player)` (`lib/magic/legal_actions.rb`) returns `[*actions, nil]` (`nil` is "pass", last so an agent that just takes the first entry prefers a real action) built from every hand/graveyard/library-top/exile card that a `Cast`/`PlayLand`/`Cycle` candidate says is `legal?` (and, for those three, `can_perform?`); every controlled permanent's `activated_abilities` and planeswalker's `loyalty_abilities` as `ActivateAbility`/`ActivateManaAbility`/`ActivateLoyaltyAbility` candidates filtered by `legal?` plus (new) an explicit `Costs::SelfTap#unpayable_reason` check, since `illegal_reason` deliberately doesn't check `{T}`-cost payability; no other affordability check yet (costs are too heterogeneous across `Costs::*` classes to check generically without a chosen target; see G3); a `DeclareAttacker` per untapped/non-summoning-sick creature × opponent in the declare-attackers step for the active player; and a `DeclareBlocker` per (declared attacker, that player's creature) pair in the declare-blockers step. Blocking had no `Action` at all before this pass — `CombatPhase#declare_blocker` was only ever called directly, bypassing `illegal_reason`/`take_action` — so this added `Actions::DeclareBlocker` and `Player#declare_blocker` (mirroring `DeclareAttacker`) first, purely additively; the ~57 specs that call `current_turn.declare_blocker` directly are untouched and still bypass legality, same as `current_turn.declare_attacker` already did. Bugs this exposed and fixed: `Cast#illegal_reason` never rejected land cards (lands are played, not cast, rule 111.1) except when `adventure: true` (a land-typed adventure card, e.g. `LindblumIndustrialRegency`, is still cast for its non-land adventure side); a mana ability was always wrapped in the base `Actions::ActivateAbility` instead of `Actions::ActivateManaAbility` (wrong `uses_priority?`, wrong `#perform`). Specs: `spec/game/integration/legal_actions_spec.rb`, `spec/game/integration/action_legality/block_spec.rb`, plus two new cases in `spec/game/integration/action_legality/cast_spec.rb`.

**Status (2026-09-27): C2c done, with real limits.** `Game#run!(max_actions: 10_000)` (`Magic::GameRunner`) plays a whole game using each `Player#agent`: drains pending choices (via the choice controller's `agent.resolve_choice`), auto-advances no-priority steps (untap/cleanup, and the turn boundary at cleanup, via `game.next_turn`), and otherwise asks whoever holds priority to pick from `legal_actions` and either passes or prepares and performs it. Needs `Game.new(enforce_priority: true)` (raises otherwise). "Prepares" only covers: `ActivateAbility`/`ActivateManaAbility`'s self-tap/self-sacrifice/self-exile and mana costs (neither action's own `#perform` pays costs — `Player#activate_ability` normally does this before `take_action`, and `GameRunner` is standing in for it here) plus a multi-colour mana ability's colour choice; `Cast`'s mana cost (`auto_pay_mana`) and a single target (asked via `Agent#choose_targets`, modal/multi-target spells not handled); `Cycle`'s mana cost. Anything else unpaid (`Costs::Tap`/`Sacrifice`/`Discard`, needing a chosen target) is left to fail the same way it would for a caller that forgot to pay it. Raises `GameRunner::NotFinished` past `max_actions` rather than returning a mid-game state. Bug this exposed and fixed: `Costs::SelfTap` was never paid for an `ActivateManaAbility` GameRunner built directly (only `Player#activate_ability`'s wrapper paid it), so an untapped land's mana ability looked perpetually available and the loop never progressed — same root cause as the `legal_actions` fix above, from the opposite side (paying instead of enumerating). "Done when" met: `spec/game/integration/game_runner_spec.rb` runs a full 2-`FirstLegalAgent` game to a deck-out loss with no exceptions, and a second spec proves an agent that prefers a real action over passing actually plays lands and taps them for mana (this is `FirstLegalAgent` itself, now that `nil` sorts last). Still open: block decisions (`FirstLegalAgent#choose_blockers` always declines, which is never asked for since block *declaration* goes through `choose_action`/`legal_actions` like everything else, but an agent that wants to describe "block with X" more directly than one `DeclareBlocker` at a time would use `choose_blockers`), a resolve_choice answer generic enough for `FirstLegalAgent` (only `ScriptedAgent` can answer a real `Choice`), and multi-target/modal spells.

**Problem.** There is no seam for "ask the player what to do". This blocks bots, a UI, network play, and automated testing of whole games.

**Scope.**
- C2a (done). Define `Magic::Agent` (or `Player#controller`) with methods like `choose_action(game, legal_actions)`, `choose_targets`, `choose_blockers`, `choose_mana_payment`, `resolve_choice(choice)`. Ship a `ScriptedAgent` (queue of answers, for specs) and a `FirstLegalAgent`.
- C2b (done). `Game#legal_actions(player)`: enumerate castable spells, playable lands, activatable abilities, attack/block declarations. Builds on C1's legality predicate.
- C2c (done, with real limits -- see status). `Game#run!` main loop: while game not over, ask the player with priority for an action. Requires A for real semantics; before A lands, it can drive turn-level actions only.
- Existing `Stack#choices` queue becomes "ask the choice's `controller`'s agent" instead of waiting for specs to call `resolve_choice!`.

**Entry points.** `lib/magic/player.rb`, `lib/magic/choice.rb`, `lib/magic/stack.rb` (choices).

**Done when.** A full game between two `FirstLegalAgent`s runs to completion with no exceptions (met -- see the C2c status above). Existing specs keep working unchanged because default behaviour is "no agent → caller drives".

**Depends on.** C1 (legal actions), A (priority loop) for C2b/C2c; both are done, and so is all of C2. **Size.** Large. **Good for.** Human-led design, agent-implemented pieces.

---

## A. Priority passing, the stack, and triggers

**Status (2026-09-23): A1 done and merged to `master`.** `Game.new(queue_triggers: true)` (default `false`, so the whole existing suite is untouched) makes `Permanent#perform_trigger!` push `TriggeredAbility` instances onto `Game#pending_triggers` instead of calling them, and drains that queue onto `game.stack` at the same checkpoints B already added (`Game#state_based_actions_checkpoint!` — there's no real priority loop yet, so this is the closest available stand-in for "the next time a player would receive priority" until A2/A3 land). APNAP ordering falls out of `Game#players` already being active-player-first; a player's own 2+ simultaneous triggers get a new `Choice::OrderTriggers` (`lib/magic/choice/order_triggers.rb`), a lone one skips the choice via the existing single-choice auto-resolve. Details, gotchas (mid-resolution nested triggers spawning a new ordering choice; specs need a manual checkpoint call after a bare turn-step transition) and the `settle!`-to-quiescence spec pattern are in `CLAUDE.md` under "Trigger Queue". `TriggeredAbility::OncePerTurn` needed a small refactor along the way — its "mark as triggered" bookkeeping moved from an overridden `perform!` into a new `trigger!` hook (default: `should_perform?`), since `perform_trigger!` now needs to decide *that* an ability triggers (and do that bookkeeping) without also executing its effect immediately.

**Status (2026-09-24): default flipped to `true`.** Migrated the whole suite (1441 examples, 0 failures) rather than leaving it deferred. Collapsed into three structural fixes rather than 350 one-off spec patches: (1) `Game#check_state_based_actions!` auto-resolves a pending `Choice::OrderTriggers` itself (not just `settle!`), so every existing checkpoint transparently absorbs it — found and fixed a real ordering bug here along the way (it was re-batching a still-pending player's remaining triggers into a *second*, duplicate `OrderTriggers` choice each loop iteration, corrupting resolution order — see `Game#put_pending_triggers_on_stack!`'s comment); (2) `Game#settle!` (drain + resolve to quiescence) added and wired into the turn-phase-transition hooks in `turn.rb` that represent genuine atomic priority-equivalent boundaries (upkeep/draw/first_main/beginning_of_combat/end, `final_attackers_declared!`, `deal_combat_damage`, and mid-`attackers_declared!` before the "attackers without targets" check) — deliberately *not* wired into `Turn#notify!` broadly, because that fires mid-way through multi-step engine sequences like `Permanent.resolve` (SBA-checking a still-0/0 permanent before a same-call step like `add_additional_counters_for_entering` gets to run); (3) `ResolvePermanent` (spec helper) auto-settles by default, except Auras. Full account, including the two genuine (pre-existing, now-fixed) card bugs this exposed (`AcademyElite`, `ElderfangRitualist`, `OnduSpiritdancer`) and the "0/0 that becomes something needs a replacement effect, not an ETB trigger" pattern (still an open gap for `Clone`), is in `CLAUDE.md` under "Trigger Queue".

Still open from that pass: a genuine "choose as it enters" replacement-effect mechanism (would let `Clone` be implemented correctly).

**Status (2026-09-26): A2/A3 (with A4/A5 as far as the opt-in model goes) done and merged to `master`.** `Stack#resolve_top!` resolves one item (`resolve_stack!`/`resolve!` loop it, so the suite is unchanged). `Game#priority_player`, `#grant_priority!`, `#pass_priority!` (returns `:passed`, `:resolved`, `:step_ended` or `:choice_pending`), `#receive_priority!` (SBAs + queue triggers, then grant; A5) and `Turn#advance_step!` implement the priority loop. Enforcement is opt-in: `Game.new(enforce_priority: true)` makes `Turn#take_action` reject actions from a player without priority and swaps the turn-step `settle!` calls for `Turn#checkpoint!` (SBAs + triggers onto the stack, no auto-resolve) so players can respond to triggers. Actions with `uses_priority? == false` (mana abilities, tap, declare attacker, concede) skip the check. A4 (responses) works for instants/flash/abilities through this. Not done: split second, combat-damage-step trigger windows (D5). (A default flip to `enforce_priority: true` was considered next and rejected — see the 2026-09-27 status below.)

**Status (2026-09-27): attempted the default flip, reverted; then decided against ever flipping it.** Flipping `enforce_priority` to `true` took the suite from 0 to 393 failures. One structural fix (`Game#start!` now calls `grant_priority!(active_player)` right after building turn 1 — "beginning", the state `Turn` starts in before its first `untap!`, is a `NO_PRIORITY_STEP` like untap/cleanup, but unlike those it isn't a real rules concept; it only exists so a spec, or any caller, can act — cast an instant, activate a mana ability — before bothering with `go_to_main_phase!`, and that needs someone to hold priority) got that down to 155, kept regardless of the default (harmless no-op when `enforce_priority?` is false, and a genuine correctness improvement: priority now reflects reality even in opt-in mode). See `spec/game/integration/priority_spec.rb` ("gives the active player priority as soon as the game starts"). The remaining 155 broke down into two categories, both `p1.cast(...)` immediately followed by `p2.cast(...)`/`p2.declare_blocker(...)`/etc. with no `pass_priority!` between them (the vast majority, across ~115 card specs plus `card_parser`/`combat`/`action_legality`), or a triggered ability's `Choice` not existing yet because nothing passed priority to let the trigger resolve onto the stack first.

Reverted the flip and, on reflection, dropped it as a goal rather than a deferred one: **priority-passing and card mechanics are different concerns, and forcing every card spec through the first to test the second is the wrong layer for it.** `spec/cards/*.rb` and most of `spec/game/integration/` test "does this card's effect resolve correctly" by driving both players directly (`p1.cast(...)`, `p2.declare_blocker(...)`, ...) — C1 already enforces everything those specs need to be honest about (sorcery timing, zones, once-per-turn limits, summoning sickness, ...). Whether a player currently *holds priority* to take that action is a separate, real rule, but it's the priority system's own rule to test, not every card's. That's already how the specs that do care are built: `spec/game/integration/priority_spec.rb`, `game_runner_spec.rb` and `self_play_spec.rb` each opt in with `Game.new(enforce_priority: true)` explicitly, and nothing needed the rest of the suite to do the same. `enforce_priority` stays opt-in permanently — for the priority system's own specs, for `Game#run!`/`GameRunner` (real play), and for any future spec that specifically tests a response/APNAP/"can't act without priority" scenario — not a temporary state waiting for the whole suite to migrate onto it.

**Original problem (mostly solved; see statuses).** The single biggest gap was that players could not respond. Triggered abilities resolve during event dispatch instead of going on the stack, so there is no APNAP ordering and no way to respond to a trigger. Split second, "can't be countered while X", and "in response to" effects are impossible.

**Scope.**
- A1 (done). **Trigger queue.** `TriggeredAbility` instances created during `notify!` go into a pending list on the game instead of running. The next time a player would receive priority, put pending triggers on the stack in APNAP order (active player's first, i.e. lowest on the stack), with a `Choice` for ordering a player's own simultaneous triggers.
  - Keep the existing synchronous path behind a switch so the suite can migrate card-by-card. The default flips once the suite is green.
  - Watch out for triggers that currently rely on synchronous resolution: ETB triggers used as replacement-ish behaviour, and "enters tapped" patterns documented in `docs/patterns/triggers.md`.
- A2 (done, opt-in). **Priority model.** `Game#priority_player`, `Game#pass_priority!`. Active player gets priority first in each step that grants it; both players passing in succession with an empty stack ends the step; with a non-empty stack, resolves the top item then gives the active player priority again. Steps without priority (untap, cleanup) stay as-is.
- A3 (done). **Stack resolution one item at a time.** Replace the recursive drain in `Stack#resolve!` with `resolve_top!`. Keep `resolve!` as a spec-friendly "pass priority until the stack is empty" helper.
- A4 (done, opt-in). **Responses.** Instants, flash, activated abilities, and mana abilities (which do not use the stack) cast/activated while the stack is non-empty. `can_cast_sorcery?` becomes real.
- A5 (done, opt-in). **Interaction with SBAs and choices.** Run B's SBA pass, then put pending triggers on the stack, before each priority grant. Choices pause the loop as they do today.
- A6. Split second, "counter target spell" edge cases, and stack-item legality on resolution belong in G2/E, not here.

**Entry points.** `lib/magic/stack.rb`, `lib/magic/game/turn.rb` (state machine transitions), `lib/magic/game.rb`, `lib/magic/triggered_ability.rb`, `lib/magic/permanent.rb` (`dispatch_event_handlers`, `perform_trigger!`), `lib/magic/actions/cast.rb`.

**Done when.**
- Two simultaneous triggers from different controllers resolve in APNAP order.
- A player can cast an instant in response to a trigger, and it resolves first.
- Both players passing with an empty stack advances the step.
- ~~The whole existing suite passes with the new default.~~ True for A1's `queue_triggers` (the whole suite migrated). Not the goal for `enforce_priority` — see the 2026-09-27 status above: it's meant to stay opt-in, exercised by the specs that are actually testing priority/response/whole-game behaviour, not by every card spec.

**Depends on.** B (SBAs to slot in) and C1 (timing rules). A1 can begin before either if the switch keeps old behaviour.

**Size.** Very large; sequence A1 → A2/A3 → A4 → A5. **Good for.** One human lead plus agents on A1/A4; A2/A3 are the delicate part and deserve a human's eyes.

---

## D. Combat correctness

**Status (2026-09-24): D1–D3 done.** Specs: `spec/game/integration/combat/{blocking_restrictions,first_strike_blockers,damage_assignment}_spec.rb`. Deviations from the plan below:
- D1 covers flying/reach, menace, skulk, tapped blockers, blockers the defending player doesn't control, one attacker per blocker, and blocking something that isn't attacking. Fear, intimidate, shadow, horsemanship and landwalk have no keyword in the engine yet, so they're left for E. Menace is checked by `CombatPhase#validate_blocks!` when leaving the declare blockers step.
- D3 follows the current rules (Foundations removed damage assignment order): the attacking player divides damage however they like, with trample still needing lethal damage on every blocker first. Instead of a `Choice`, the seam is `current_turn.assign_combat_damage(attacker, { blocker => n, player => n })`, validated on the spot; until C2 exists, that's how a spec or caller makes the decision. Without one, the default is lethal damage to each blocker in the order declared, and what's left goes to the player (trample) or the last blocker.
- A blocked attacker whose blockers have all left combat stays blocked and deals no damage unless it has trample (509.1h). A creature with 0 or less power deals no combat damage.
- Bug this surfaced: `brash_taunter_spec` expected a 2/2 attacker to deal only 1 damage to its single 1/1 blocker.
- Lethal damage counts damage already marked and damage other creatures are assigning to the same creature in the same step (510.1c, 702.19c), via `CombatPhase::PendingDamage`. Chosen divisions are worked out first, then default ones in attack order, then blockers. A chosen division is checked against the other attackers' chosen divisions only. So to trample over using another attacker's damage, assign that attacker's division first.
- A creature can block more than one attacker when its card's `maximum_attackers_blocked` is above 1 (no card uses it yet). It divides its damage between those attackers the same way: lethal damage first, the rest to the last one. The defending player can't choose that division yet.
- Still open: D4, D5.

**Original problem (D1–D3 solved).** See fact 4 above. In addition, `Attack#resolve` assigns `[blocker.toughness, damage].min` to each blocker in turn: it ignores damage already marked, ignores deathtouch when not trampling, and gives the attacking player no ordering or split choice.

**Scope.**
- D1. **Blocking legality.** Make `CombatPhase#declare_blocker` consult `Permanent#can_block?` and evasion: flying/reach, menace (≥ 2 blockers), fear, intimidate, shadow, skulk, horsemanship, landwalk, "can't be blocked", "can't block", protection. Blocker must be an untapped creature the defending player controls. A blocker may block only one attacker unless a card says otherwise. Validate menace-style constraints when blocks are *finalised*, not per blocker.
- D2. **Damage step rewrite.** Separate the first-strike damage step from the regular one: each step deals damage from the creatures that qualify in that step, attackers and blockers alike. Double strike deals in both. Lifelink, deathtouch, wither and infect apply per damage event, not per creature.
- D3. **Damage assignment.** Attacker's controller orders blockers and assigns lethal-then-rest, via a `Choice`. Default (no agent): current auto behaviour but correct lethal calculation, including damage already marked and deathtouch. Trample and "trample over planeswalkers" build on this.
- D4. **Attack restrictions and requirements.** "Attacks each combat if able", "can't attack unless…", attack costs (Propaganda), "must be blocked", attacking a planeswalker or battle vs a player, removal from combat, creatures that become attacking/blocking mid-combat.
- D5. **Combat triggers timing.** Ensure `CreatureBlocked`, `AttackersDeclared` etc. fire once and at the right step. Coordinate with A so triggers land on the stack in the right window (declare attackers, declare blockers, combat damage).

**Entry points.** `lib/magic/game/combat_phase.rb`, `lib/magic/game/turn.rb`, `lib/magic/effects/deal_combat_damage.rb`, `lib/magic/permanents/creature.rb`, `spec/game/integration/combat/`.

**Done when.** A spec per keyword above. A first-strike blocker kills a non-first-striking attacker before it deals damage. Deathtouch plus trample assigns 1 and tramples the rest (already covered; keep it passing).

**Depends on.** None for D1–D3. D5 wants A. **Size.** Large, splits cleanly into five PRs. **Good for.** Agent.

**Status (2026-09-26, implementation summary):** `CombatPhase#block_illegal_reason` enforces blocker legality (untapped creature the defending player controls, not already blocking, `Permanent#can_block?`, protection, flying/reach, shadow, horsemanship, fear, intimidate, skulk, landwalk (`Keywords::Landwalk.new("Swamp")`), `Keywords::CANT_BE_BLOCKED`); menace is checked as a whole by `CombatPhase#validate_blocks!` in a `before_transition to: :combat_damage`. Damage is now worked out per step for attackers *and* blockers together: the first-strike step covers first/double strikers, the regular step covers everyone who didn't strike first plus double strikers, and all damage in a step is computed before any is applied. `Attack#attacker_damage` assigns lethal damage (accounting for marked damage and deathtouch) to each blocker in declaration order and the rest to the last blocker, or over the blockers with trample; `CombatPhase#assign_combat_damage(attacker, blocker => n)` lets the attacking player override this (validated). Deviation from D3: the split is a direct API call, not a `Choice`, because a pending `Choice` blocks the stack and there's no agent yet (C2). Still open: D4 and D5, and letting the defending player choose how a multi-blocker divides its damage.

---

## E. Keyword and ability framework

**Status (2026-09-26): E1–E3 done; E4–E6 open.** Specs: `spec/game/integration/{targeting_keywords,destruction_keywords}_spec.rb`. Details and gotchas are in `CLAUDE.md` ("Targeting Keywords", "Indestructible, Regeneration, Protection from Damage"). Deviations and leftovers:
- E1: `script/keyword_audit.rb` generates `docs/keywords.md` (edit the status tables in the script, then rerun it). Most rows are "missing" by default; many of those are really n.a. and haven't been triaged.
- E2: one `can_be_targeted_by?(source, controller:)` on `Permanent` and `Player`, called from `Cast`, `Cast::Mode` and `Ability#valid_targets?` (activated and loyalty abilities). Ward is a spell trigger plus an ability trigger (`Choice::Ward`). **Not done:** targets chosen through `Choice::Targeted` (triggered abilities) are not filtered, because that class cannot tell "target" from "choose". Fix by giving targeting choices their own subclass or flag. Player hexproof/shroud (Leyline of Sanctity, Witchbane Orb) is not modelled either.
- E3: indestructible was already handled in `Permanent#destroy!`; regeneration is now a shield (`regenerate!`/`regenerated!`, expires in `cleanup!`, removes from combat), and protection prevents damage. "Can't be regenerated" is not modelled. `Permanent#regenerate!` callers (Rhys the Exiled) now get a shield rather than an immediate untap-and-tap.

**Problem.** Keyword behaviour is spread across `Magic::Keywords` (`lib/magic/keywords.rb`) predicates, per-effect checks and one handler module. Adding a keyword means hunting for every place it must be checked. There is no generic `Effects::Fight` (the card parser has a `Fight` effect and `BrashTaunter` hand-rolls one); `CopyEffect` exists (`lib/magic/copy_effect.rb`) but copy-spell semantics are card-by-card (**verify**).

**Scope.**
- E1 (done). **Keyword audit.** Build a table (in `docs/keywords.md`) of every Oracle keyword: implemented / partial / missing / n.a., with the file that owns it. Generate the candidate list from `data/oracle-cards-*.jsonl` (`Magic::Oracle`). This is a research task and the input for E2–E4.
- E2 (done, with gaps). **Targeting keywords enforced generically.** Hexproof, shroud, protection (targeting, damage, blocking, enchanting/equipping), ward as a real triggered ability tied to the stack. One central `can_be_targeted_by?(source)` that every targeting path uses.
- E3 (done). **Evergreen combat/damage keywords.** Indestructible, regeneration as a shield, protection damage prevention.
- E4. **Cost and cast keywords.** Convoke, delve, affinity, emerge, alternative costs, evoke, overload, cycling variants, flashback/escape/disturb, buyback, kicker variants. Shares a design with G3, so land G3 first or pair them.
- E5. **Triggered and static keywords as reusable handlers.** Exalted, annihilator, persist, undying, cascade, evolve, extort, prowess (exists), landfall (exists), ninjutsu, etc. Follow the shape of `keyword_handlers/prowess.rb`.
- E6. **Generic effects.** `Effects::Fight`, `Effects::CopySpell`, `Effects::Bounce`, `Effects::Mill`, etc., so cards stop hand-rolling them.

**Entry points.** `lib/magic/keywords.rb`, `lib/magic/cards/keyword_handlers/`, `lib/magic/effects/`, `lib/magic/protection.rb`, `lib/magic/targetable.rb`.

**Done when.** Per keyword: one integration spec, and card files that previously hand-rolled the behaviour are migrated or left with a note. E1's table shows no "unknown" rows.

**Depends on.** None (E5–E6). E4 pairs with G3. **Size.** Large; every sub-item is independently shippable. **Good for.** Agents; E1 first.

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

**Status (2026-09-29): done, with deliberate simplifications.** `Permanents::ContinuousEffect` (renamed from `Modification`) carries a `layer`/`sublayer` (class-level `layer N, sublayer: :x` macro), a `timestamp` (`ContinuousEffect.next_timestamp`, a process-wide monotonic counter) and a `duration` derived from `until_eot:` (F1). `Permanent` now exposes its own `timestamp` (previously a dead ivar), used as a static ability's effective timestamp (`StaticAbility#timestamp`, falling back to 0 for the one graveyard-sourced static ability, `Anger`). `ContinuousEffects#apply!` applies layers 1–7d in order with an explicit comment per layer (F2); a `last_by_timestamp` helper resolves same-sublayer conflicts (fixed two real bugs this exposed: a spell-created base-P/T setter used to always beat a static characteristic-setting base-P/T setter regardless of actual recency, and colour resolution mixed a characteristic-setting override with a separate array-order fallback instead of comparing timestamps) — this is also F3's documented hook for a future 613.8 dependency-ordering pass, not implemented. New layer 7d (`Modifications::SwitchPowerToughness`, `Permanent#switch_power_and_toughness!`). Layer 2 (control) gained a real `ControlChangeEffect` list (`Permanent#control_change_effects`) replacing a single-slot `@controller_before_eot` ivar, though control still applies eagerly via `controller=` rather than being recomputed every `apply!` pass — no card needs the latter. Layer 1 (copy) and layer 2 remain thin: F only provides the layer *slot*, not new copy-value or control-source infrastructure (copy already routed through `Permanent#copiable_card`/`copied_card`; J3 owns making that a real timestamped/duration effect). F4: `Permanent#cleanup!` calls the same shape of `remove_until_eot_*`/`expire_control_change_effects!` methods, now duration-driven under the hood rather than a bare boolean, though only `:until_end_of_turn`/`:permanent` durations exist (no card needs "until your next turn" yet). `docs/card_patterns.md`'s sibling doc `docs/patterns/static_abilities.md` has the per-pattern details. Found and fixed in passing: `Permanent#base_power`/`#base_toughness` (`Permanents::Creature`, used by `ZinniaValleysVoice`) had a second, independent "last modifier wins" implementation with no characteristic-setting awareness at all — now delegates to the same `ContinuousEffects` resolution. New coverage: `spec/game/integration/continuous_effect_layers_spec.rb`.

**Depends on.** None. J3 (copy) uses layer 1. **Size.** Large. **Good for.** Human-led design; agent implementation of F4.

---

## G. Mana, casting, and cost pipeline

**Scope.**
- G1. **Mana objects.** Replace the flat `color => count` pool with mana that remembers its source and restrictions ("spend only on creature spells", "…only to activate abilities"). Pool empties at end of each step and phase. Today restricted mana is documented as unenforced (`docs/patterns/costs.md`); this removes that caveat. Keep `add_mana(green: 2)` and `pay_mana(...)` working for specs.
- G2. **Resolution-time legality.** (Some spell types have their own target checks; there is no generic fizzle rule **(verify)**.) On resolution, re-check targets. A spell or ability with all targets illegal fizzles (does not resolve); with some illegal targets, resolves without affecting them. `Stack::TargetedCast#validate!` is a starting point.
- G3. **Cost framework.** A single `CostSet` pipeline for additional costs, alternative costs, cost increases/reductions, and X, with explicit order (601.2f–h). Sits under `Actions::Cast` and `Actions::ActivateAbility`. Includes Phyrexian, hybrid and snow mana.
- G4. **Choice and cost validation layer.** Modal spells validate mode counts, distributions validate sums, colour choices validate allowed sets. Today these are unenforced and duplicated in card classes (see the many "nothing validates…" notes in `docs/patterns/`).

**Entry points.** `lib/magic/mana.rb`, `lib/magic/player.rb` (mana pool), `lib/magic/costs/`, `lib/magic/actions/cast.rb`, `lib/magic/actions/activate_ability.rb`, `lib/magic/choice.rb`.

**Done when.** Restricted-mana cards (e.g. `PlazaOfHeroes`) actually enforce the restriction. A fizzle spec exists. Mana empties between steps.

**Depends on.** None (G1, G2, G4). G3 and E4 pair up. **Size.** Large in total, each item medium. **Good for.** Agent.

---

## H. Turn structure and game setup

- H1. **Cleanup step.** Discard to hand size (7) with a choice; remove marked damage; end "until end of turn" effects simultaneously; a second cleanup if triggers fire. Still true 2026-09-26: `Turn` calls only `battlefield.cleanup` → `Creature#cleanup!` (no discard, no second cleanup; `Choice::Discard` exists to build on). *Depends on:* none for the basics; F4 for durations. *Size:* small.
- H2. **Game setup.** Deck loading and validation (60-card / Commander), shuffle with a seedable RNG, choose starting player, London mulligan, first player skips their first draw. `Game#start!` today just draws seven. *Depends on:* deck loading and RNG none; mulligan decisions need C2.
- H3. **Extra and skipped turns, phases and steps.** `take_additional_turn` and `queue_additional_combat!` exist. Add "skip your next draw step", extra main phases, "end the turn" effects (Time Stop), and end-of-game handling. `Game#over?`/`#drawn?`/`#winner` and `Actions::Concede` exist (B); what is left is refusing actions once the game is over.

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
- Replacement-effect completeness beyond the current chooser (self-replacement ordering, "instead" text, prevention effects and damage prevention shields).

**Depends on.** Varies; most depend on nothing. **Good for.** Agent per item.

---

## L. Tooling and confidence

- L1 (done). **Card coverage report.** `rake coverage`: compares `data/oracle-cards-*.jsonl` (filtered to the card pool being targeted) with `lib/magic/cards/`. Lists unimplemented cards grouped by the mechanic they need, feeding K and E1. Cheap and useful for prioritising every other workstream.

**Status (2026-09-27): L1 done.** `rake coverage[<set code>]` (or `bundle exec ruby script/coverage.rb <set code> [--lines] [--cards]`) reports, for one set at a time (the "card pool being targeted" is whichever set you name — currently `ecl`, Lorwyn Eclipsed, the set most other work targets), how many of its cards have no `lib/magic/cards/` file yet, and tags each unimplemented one by the mechanic blocking it (reusing `script/parser_gaps.rb`'s tagging, extracted into shared `script/mechanic_tags.rb` so the two scripts don't keep two copies of the same ~40-regex table) — or "Ready to generate" for one `rake parse_card` alone would produce cleanly, no gap to close first. "Implemented" means `Magic::Cards` defines the constant for the card's name, true whether the file was hand-written or `rake parse_card`-generated; this is a different (and narrower) question than `parser_gaps.rb`'s "can the parser reproduce this Oracle text", so an already-implemented but hand-rolled-around-a-parser-gap card doesn't show up here. First `ecl` run: 262 cards, 55 implemented, 207 not, 36 of those "ready to generate" right now. Known approximation, shared with `parser_gaps.rb`: adventure/split/transform cards are looked up by Scryfall's combined name, so a hand-written file keyed on only the front face's name could misreport as unimplemented (not observed in the current `ecl` data — spot-checked `Lindblum, Industrial Regency`, correctly counted implemented).
- L1b. **Whole-corpus parser gap: "At the beginning of …" triggers, by phase** (measured 2026-09-29; scratch scripts were `tmp/parser_coverage.rb`, `tmp/parser_gaps_all.rb`, `tmp/phases.rb`, not committed). Method: every non-basic-land, non-token face in `data/oracle-cards-*.jsonl` (35,824 faces, 65,902 rules lines), reminder text stripped, own name replaced with `~`, a line counts as supported if any `Magic::CardParser::Rule.parse` accepts it. That is line-level recognition only, not "generates loadable code", and "Unclassified"/phase bucketing is regex-based, so treat every count as approximate. Headline: 33.4% of rules lines and 15.4% of faces are fully recognised (the face figure is inflated by vanilla faces). "At the beginning of …" is the single biggest gap: 2,124 lines, only 161 parsed (7.6%). **The trigger clause is mostly already supported** (`lib/magic/card_parser/rules/trigger.rb` has kinds for "your upkeep", "your first main phase", "combat on your turn", "your end step", "each end step"); lines fail on the **effect body** after the comma. "Sole" = faces whose only unparsed line is this one, i.e. fully unlocked by fixing it.

  | Phase | Lines | Parsed | Not | Sole | Whose (unparsed) |
  |---|---|---|---|---|---|
  | Upkeep | 1,104 | 97 | 1,007 | 478 | your 743, each/any 211, opponent's 35 |
  | End step | 594 | 25 | 569 | 269 | your 402, each/any 158, opponent's 7 |
  | Beginning of combat | 310 | 36 | 274 | 133 | your 236, each/any 30, opponent's 5 |
  | First / precombat main | 65 | 3 | 62 | 22 | your 53 |
  | Draw step | 32 | 0 | 32 | 7 | your 14, each/any 13 |
  | Second / postcombat main | 19 | 0 | 19 | 6 | your 17 |

  Cleanup, declare attackers and end of combat matched no lines in the pool (nothing to build). Effect-body blockers per phase (unparsed lines; an example each is in the script output):
  - **Upkeep:** intervening if/unless 224; counters (remove "a X counter from ~", add, move) 185; sacrifice ("sacrifice ~ unless you …") 121; other/multi-sentence 113; opponent/target-directed ("each opponent draws") 84; damage 76; top-of-library (exile/reveal/mill/scry) 54; life loss 50; "you may pay {cost}. If you do, …" 30; create a token (mostly copies) 30; return/bounce 21.
  - **End step:** intervening if 266 (the parser only knows two fixed ifs: "another creature entered", "you put a counter"); counters 64; other 53; life 28; sacrifice ("sacrifice ~" at the beginning of *the* end step, i.e. delayed triggers) 25; modal "choose one —" 24; create token ("a number of Food tokens equal to …") 23; damage 22; return-to-hand delayed triggers 12; may-pay 14.
  - **Beginning of combat:** opponent/target-directed and "you may have …" 59; intervening if 50; other (explore, roll dice, becomes a copy) 43; counters ("put a +1/+1 counter on target creature you control", then more) 35; pump/keywords until end of turn 30; may-pay incl. {E} 18.
  - **First main:** "you may discard/pay {R}. If you do, …" 34 combined; other 19. **Draw step:** "draws an additional card" for each other player 13, "draw two additional cards" 7 (these want a draw-step replacement/extra-draw effect, not just a trigger). **Second main:** intervening if 8.

  Ranked by faces unlocked, cheapest first:
  1. **Intervening-if on triggers** (`if <condition>, <effect>`): ~540 lines across upkeep/end step/combat. `Magic::CardParser::Condition` already parses conditions for statics (`as long as …`); reuse it as the trigger's `should_perform?`. Also covers "each end step, if an opponent discarded a card this turn" (needs a per-turn event scan, same shape as the existing two hard-coded ifs, which it would replace).
  2. **Trigger-side effects that already exist as `Effects::` parsers but aren't wired to trigger bodies with a subject other than "you"/"~"**: "each opponent draws", "target creature you control", "you lose N life", "sacrifice ~ unless …" (needs an unless-cost form), counters on `~`/target (`remove an X counter from ~`, `put a +1/+1 counter on target creature you control`).
  3. **"You may pay {cost}. If you do, …"** ~79 lines here (and many more for non-beginning-of triggers): an optional cost plus a dependent effect; `OptionalEffect` and `Costs::Mana` exist, the dependent "if you do" branch does not.
  4. **Phase coverage gaps in `trigger.rb` itself:** "each upkeep" (98 lines), "each player's upkeep" (82), "each opponent's upkeep" (36), "the end step" / "the next end step" delayed triggers (50), "each combat" (28), "each player's end step" (22), "your draw step"/"each player's draw step", "your second main phase". These are new `Kind`s, one line each, mostly reusing the existing event classes with a different `active_player` check (`Events::BeginningOfUpkeep`/`BeginningOfEndStep`/`BeginningOfCombat` already exist; check whether there are draw-step/second-main events before adding kinds for them).
  5. **Not worth chasing yet:** multi-sentence "other" bodies (dice, explore, dungeon, "perpetually", conjure, Horde/Archenemy) are a long tail with no shared shape.

  Re-measure after each step by rerunning the method above (about a minute); a `rake parser_coverage` task that prints the table is the obvious follow-up if this is going to be repeated. **Good for.** Agent, one PR per numbered step.
- L2 (done, scoped down -- see status). **Self-play fuzzing.** With C2's `FirstLegalAgent` or a random agent and a seeded RNG (H2), play many games between random decks and assert invariants: the stack is empty at end of turn; no negative life without a loss; every permanent belongs to exactly one zone; card count is conserved. Any crash is a bug report.

**Status (2026-09-27): L2 done, scoped to fixed decks (no H2 yet).** `spec/game/integration/self_play_spec.rb` runs `Game#run!` (two `FirstLegalAgent`s) to completion on three fixed decks (all-land; vanilla creatures; creatures + a single-target burn spell across two colors) and asserts, per player: the stack is empty, life is positive unless the player lost, and every card they started with is in exactly one zone/on the battlefield with none duplicated or dropped. No seeded RNG or random decks yet (needs H2), so this is a fixed fuzz set, not a random one -- rerunning it finds the same bugs, not new ones, until more decks are added. Bugs this found and fixed, exactly as intended ("any crash is a bug report"):
  - `spec_helper.rb`'s own `p2_library` built every card with the `Card()` helper's default `owner: p1` instead of `p2` -- latent since the shared "two player game" context was written, never caught because no existing spec actually played one of its filler lands (they all build their own test-specific cards). A land P2 "played" out of that deck resolved as a permanent P1 controlled.
  - `LegalActions#declarable_attackers` offered re-declaring an already-attacking creature at the *same* target as a distinct legal action forever (it's legal -- see `DeclareAttacker#illegal_reason` -- but a no-op). A "take the first legal action" agent picked it every time forever instead of ever passing, hanging the whole run.
  - A mana ability was still being built as the base `Actions::ActivateAbility`, not `Actions::ActivateManaAbility` in one path (see C2b's fix); `Costs::SelfTap` still wasn't excluded (also C2b).
  - **The one worth its own callout:** `Cast#mana_cost` built its per-cast cost via `Costs::Mana#dup` (`Object#dup`'s default *shallow* copy), which shares `@balance`/`@payments` **by reference** with the original -- `card.cost` is one persistent `Costs::Mana` instance per card, reused by every `Cast` action built for that card over its whole life (cast, resolve, bounced back to hand, cast again; or, more simply, offered again by `legal_actions` while still unresolved on the stack). Paying the "fresh" duplicate mutated the card's own cost permanently, so a second cast against the same card ever again raised `Costs::Mana::Overpayment`. Fixed by building a real fresh `Costs::Mana` from the face-value cost hash (`cost.cost.dup`) instead of duping the stateful wrapper; alternative-cost objects that aren't `Costs::Mana` (`Costs::SacrificeAlternativeCost`, `Costs::ExileCardAndLifeAlternativeCost`) keep the old behaviour, since they don't share this shape or this problem. This was a real, pre-existing engine bug independent of self-play or `enforce_priority` -- any caller that recast the same physical card object twice (a bounce-and-recast, most plausibly) would have hit it. Added `Cast#already_on_stack?` alongside it (rule 405.2: a spell already on the stack isn't in a zone it can be cast from again), which is what `legal_actions` was actually tripping over.
  Specs: `spec/game/integration/self_play_spec.rb`, two new cases in `spec/game/integration/action_legality/cast_spec.rb` for `already_on_stack?`.
- L3. **Comprehensive Rules conformance specs.** A `spec/rules/` directory with one file per rules section (e.g. `rule_704_spec.rb`) mapping rule numbers to specs, written as workstreams land. Ties each workstream's "Done when" to something citable.
- L4. **Game log and replay.** `EventLog` (`game/event_log.rb`) already records events per turn. Serialise it plus RNG seed so a failing game can be replayed.

**Depends on.** L1 none, L3 none, L4 none. L2 needed C2 (done); full random-deck fuzzing still wants H2, the scoped-down fixed-deck version done above didn't. **Good for.** Agent (L1, L3), human (L2 design).

---

## Suggested waves

**Wave 1 (parallel; no dependencies):** B (done), C1 (done), D1–D3 (done), E1 (done), F1–F2, G1, G2, H1, J2, J4, L1 (done), L3.
**Wave 2:** A (A1–A5 done, opt-in priority by design), C2 (done), D4–D5, E2–E3 (done), E4–E6, F3–F4, G3–G4, H2, H3, J1, J3.
**Wave 3:** I, K, L4.

B, C1, C2, L1 and L2 are all done; A stays opt-in by design (not a deferred default flip — see its 2026-09-27 status). `rake coverage[ecl]` (L1) says where the cheapest card-implementation wins are (36 cards ready to generate outright). Next human attention goes wherever's most useful next: F/G (layers, mana/cost pipeline) are the biggest remaining structural gaps. Agents can keep taking D4–D5, E4–E6, H and L3/L4 in parallel.

## Explicitly out of scope

A graphical or network UI; AI opponents beyond the trivial agents in C2; sanctioned-tournament rules, sideboarding and match structure; Un-sets and other silver-border mechanics; digital-only (Arena) cards.
