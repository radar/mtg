---
name: implement-set
description: Implement every unimplemented card in a set using the card-collector, card-implementer and card-reviewer agents. Use when asked to implement a whole set. Arg is the set code.
---
# Implement a set

Run as the lead session. Arg: one or more set codes. Process sets one at a time, fully finishing a set before starting the next. Steps 1-6 below apply per set `<code>`.

Only one agent that commits runs at a time (builders, implementers, fixers all share one branch). Reviewers are read-only: run them in the background and never wait on them.

1. Spawn `card-collector` with that single set code. It returns the ordered card list and writes `tmp/sets/<code>/cards.md`. Never give it more than one set.
2. Group the cards by mechanic. Spawn one read-only agent (Explore or general-purpose) to read `cards.md` and write `tmp/sets/<code>/groups.md`: each group is a mechanic or ability pattern (explore, discover, Map/Treasure tokens, crew, ward, cycling, "up to N targets", ...) with the cards that use it, plus a "no special mechanic" group. Mark mechanics the engine lacks (check `rg` in `lib/magic` and `docs/keywords.md`).
3. Build missing mechanics first, one group at a time. A mechanic missing from the engine goes to one builder (general-purpose agent, or `card-implementer` for small ones). It adds the shared effect/choice/shortcut with its own spec, documents it in `docs/patterns/` and commits. It proves the mechanic with the group's simplest card. Build mechanics that block many cards before ones that block few.
4. Implement cards group by group, in batches. Give one `card-implementer` a batch of 4-8 cards from the same group (same mechanic or similar shape) plus the `cards.md` path. It follows the `implement-card` skill for each card and makes one commit per card. Shared setup it discovers for one card (helpers, token classes, spec pattern) it reuses for the rest of the batch.
   a. If it reports `BLOCKED: <mechanic>` for a card, record the card in `tmp/sets/<code>/blocked.md`, add the mechanic to step 3's list, and continue the batch.
   b. After each batch, spawn `card-reviewer` in the background, one per card, with card name, commit SHA, cards.md path. Start the next batch right away.
   c. On `VERDICT: FAIL`, append the card, SHA and findings to `tmp/sets/<code>/backlog.md`. Do not interrupt a running implementer.
   d. Before starting each new batch, and at the end, check `backlog.md`. Group entries that share a finding (same spec gap on several cards) into one fix batch for one `card-implementer`, then spawn background reviewers on the fix commits. Max 2 fix rounds per card, then record the card in `blocked.md` with the last findings.
5. After the last card, wait for all reviews and backlog fixes to finish, then run `bundle exec rspec` once. Report failures.
6. Final report: cards passed, cards blocked (with mechanic or finding), engine notes found by reviewers, full-suite result.

Spec rules to put in every implementer prompt (reviewers fail cards that skip them):
- Never use heredocs, `sed`, `perl` or shell redirects. Create and edit files only with Write/Edit. Run specs only as `bundle exec rspec <file>`.
- Every Bash call is one simple command. No `for`/`while` loops, no `&&`/`;` chains, no `| head` pipes, no `$(...)`: compound commands cannot be matched against the allowlist and prompt the user every time. To read several cards from `cards.md`, use one `rg -n -A12 -e "^#+ (Name A|Name B)$" tmp/sets/<code>/cards.md` call, or the Read tool with an offset. Use `rg`/`fd` for search and Read for files.
- Read `lib/magic/effect_shortcuts.rb` before writing effects and use the shortcuts (`move_card`, `deal_damage`, `pump`, `create_token`, `explore`, `discover`, ...) instead of `game.add_effect Effects::X.new(...)`. Choice, TriggeredAbility, Ability and Permanent classes all include them. Pass `from:` explicitly to `move_card` when the card's zone changed before the call.
- "One or more X ..." triggers fire once per simultaneous group (CR 603.2c), not once per object: collapse them like `lib/magic/cards/moonshadow.rb` and spec two simultaneous objects giving one trigger plus a later one giving a second.
- Conditions on "each other attacking creature" and similar sets are evaluated when the ability resolves, not copied from the trigger event.
- Every custom `Choice` subclass must define `decline!` (what `game.skip_choice!` does): for "may" choices it declines, for mandatory choices it performs the default (see Choice::LookAtTopCards, Choice::Discover). Spec `game.skip_choice!` for each. Never define classes inside the `Card("...") do ... end` DSL block: put them in a `class CardName < Type` reopening.
- "You may pay {N}" (optional payment): subclass `Magic::Choice::PayMana` (see lib/magic/cards/tolarian_kraken.rb, thousand_moons_crackshot.rb), only offer it when `can_pay?`, and spec that mana really leaves the pool, that a short or empty payment does not give the effect, and that no choice is offered when the player has no mana. Never call `pay_mana` with a caller-supplied hash.
- Triggers granted by Equipment/Auras ("equipped creature has 'Whenever this creature attacks, ...'") must take the creature from the event (`event.attacker`, `event.permanent`) in `call`, never from `actor.attached_to`, because the ability exists independently of its source once triggered (CR 113.7a). Spec it: queue the trigger by hand, destroy the equipment/aura (or the creature) before resolution, resolve, and assert the effect still happens.
- Auras: "Enchant creature you control" (or any restriction beyond the type) must be in the `enchant` declaration (`enchant "Creature", you_control: true`, see pitiless_fists.rb), not only in a `target_choices` override, because the state-based check uses `can_enchant?`. Spec the control-change case (opponent gains control, settle, Aura goes to the graveyard) and that other creatures are not buffed.
- `ResolvePermanent` leaves `card.zone` nil. A spec whose behaviour depends on the card's zone (graveyard, exile, hand or battlefield abilities, "from the battlefield" triggers) must reach that zone through a real cast or zone move, and assert `card.zone` first; otherwise the example passes for the wrong reason (nil zone).
- Explore: test the land branch, nonland resolve (graveyard) and nonland skip (stays on top).
- Ward: assert the amount, and test paying too little and paying enough.
- "Activate only as a sorcery": assert whose turn and which step, and match the error reason.
- "Up to N targets": reject N+1 targets, test zero targets.
- Cycling or library search: assert the choice includes the matching card and excludes a non-match.
- Conditional text ("as long as", "if you control", "if you cast it"): test true and false.
