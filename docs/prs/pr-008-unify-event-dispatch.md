# PR 8: Unify event dispatch in Permanent

## Summary

Replaces three separate event dispatch patterns in `Permanent#receive_event` with a single, consistent mechanism.

## Why

`Permanent#receive_event` contained two independent dispatch paths that served different purposes but had no clear boundary:

1. A hardcoded `case` statement routing `EnteredTheBattlefield`, `LeftTheBattlefield`, and `CreatureDied` to `entered_the_battlefield!`, `left_the_battlefield!`, and `died!` helper methods
2. A hash lookup in `card.event_handlers` for all other events

The `case` path called `.perform` directly on trigger instances, bypassing `should_perform?`. The hash path called `.perform!`, which correctly gates on `should_perform?`. These two paths were also inconsistent with each other in naming (`def perform` vs `def call`) and in how much responsibility the trigger class held.

Additionally, `add_event_handler` in `Cards::Shared::Events` had a bug: it set up an array with `||= []` then immediately overwrote it with `= klass`, preventing multiple handlers from accumulating for the same event type.

## What Changed

**`lib/magic/permanent.rb`**
- Replaced the `case` block and duplicated handler dispatch in `receive_event` with two private methods: `dispatch_lifecycle_triggers` and `dispatch_event_handlers`
- `dispatch_lifecycle_triggers` checks `event.permanent == self` and handles attachment cleanup on LTB — both things previously spread across three separate methods
- `dispatch_event_handlers` wraps the hash lookup in `Array()` to support single-class or array values uniformly
- Removed `left_the_battlefield!` and `died!` (internal-only, now inlined)
- Kept `entered_the_battlefield!` public (used directly in some specs) delegating to the same private logic

**`lib/magic/card.rb`**
- DSL `enters_the_battlefield` now creates triggers with `def call` instead of `def perform`, consistent with how event_handlers triggers work

**18 card files** (`academy_elite`, `annex_sentry`, `aven_gagglemaster`, `barrin_tolarian_archmage`, `basris_acolyte`, `bog_badger`, `carrion_grub`, `cloudkin_seer`, `conclave_mentor`, `elderfang_ritualist`, `gale_swooper`, `geist_honored_monk`, `hill_giant_herdgorger`, `idol_of_endurance`, `nine_lives`, `shalais_acolyte`, `storm_caller`, `valorous_steed`)
- Renamed `def perform` → `def call` in ETB, LTB, and death trigger inner classes so they all go through `perform!` → `should_perform?` → `call`

**`lib/magic/cards/shared/events.rb`**
- Fixed `add_event_handler` to accumulate an array rather than overwrite; `dispatch_event_handlers` uses `Array()` to handle both single-class and array values

## Invariants Preserved

- ETB triggers still only fire when `event.permanent == self` (checked in `dispatch_lifecycle_triggers`)
- Attachment cleanup on LTB still runs before LTB triggers
- Cards using `event_handlers` for ETB/death events (e.g. `EssenceWarden`, `ArchonOfSunsGrace`) continue to gate on their own `should_perform?` as before
- All 534 tests pass
