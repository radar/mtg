# PR 5: Will-enter-the-battlefield replacement checkpoint

## Summary
This PR introduces an explicit `WillEnterTheBattlefield` checkpoint event in permanent zone transitions.

When a `MovePermanentZone` effect resolves to the battlefield, the engine now emits a pre-entry event before any leave/add transition work is applied.

## Why
The engine had no explicit pre-entry event despite having an event class for it. Modeling this window makes ETB replacement timing clearer and gives future rules work a concrete hook for "would enter" interactions.

## What Changed
1. Added pre-entry checkpoint notification:
- `lib/magic/effects/move_permanent_zone.rb`
- Emits `Events::WillEnterTheBattlefield` before leaving-zone notifications and before adding to battlefield.

2. Expanded event payload:
- `lib/magic/events/will_enter_the_battlefield.rb`
- Added `from` and `to` zone attributes.
- Updated `inspect` output with transition context.

3. Added integration coverage:
- `spec/game/integration/will_enter_the_battlefield_event_spec.rb`
- Verifies event is emitted for normal battlefield entry.
- Verifies event is not emitted when entry is replaced by `Containment Priest` (because move effect is replaced before resolve).

## Behavior Notes
- The checkpoint fires only when `MovePermanentZone` actually resolves toward battlefield.
- If replacement changes the effect away from battlefield entry, no `WillEnterTheBattlefield` event is emitted for that object.
- Existing ETB/LTB notification behavior remains unchanged.

## Files Included In This PR
- `lib/magic/effects/move_permanent_zone.rb`
- `lib/magic/events/will_enter_the_battlefield.rb`
- `spec/game/integration/will_enter_the_battlefield_event_spec.rb`

## Test Evidence
Targeted:
- `bundle exec rspec spec/game/integration/will_enter_the_battlefield_event_spec.rb spec/cards/containment_priest_spec.rb spec/game/integration/replacement_effect_source_eligibility_spec.rb`
- Result: passing

Full suite:
- `bundle exec rspec`
- Result: 528 examples, 0 failures

## Follow-up
- Use this checkpoint for deeper "as enters" / "would enter" replacement modeling.
- Add additional tests for multi-replacement entry chains as those mechanics are implemented.
