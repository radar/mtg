# PR 6: Damage pipeline normalization

## Summary
This PR normalizes damage event emission so both noncombat and combat damage produce canonical `Events::DamageDealt` records.

Combat damage retains existing `Events::CombatDamageDealt` emission for compatibility, while gameplay logic and new triggers can rely on `Events::DamageDealt` with metadata.

## Why
Damage handling was inconsistent:
- Noncombat damage applied life loss/damage but emitted no canonical damage event.
- Combat damage emitted a combat-only event.

This made downstream trigger logic and telemetry inconsistent.

## What Changed
1. Expanded canonical damage event metadata:
- `lib/magic/events/damage_dealt.rb`
- Added `combat` and `infect` fields plus predicate helpers.

2. Emitted canonical event for noncombat damage:
- `lib/magic/effects/deal_damage.rb`
- Now notifies `Events::DamageDealt` after applying damage.

3. Emitted canonical event for combat damage:
- `lib/magic/effects/deal_combat_damage.rb`
- Now notifies `Events::DamageDealt` with `combat: true` and infect metadata.
- Existing `Events::CombatDamageDealt` notification is retained.

4. Removed obsolete player-side DamageDealt life-loss reaction:
- `lib/magic/player.rb`
- Prevents potential double life loss now that DamageDealt is emitted broadly.

5. Migrated Lathril trigger to canonical event:
- `lib/magic/cards/lathril_blade_of_the_elves.rb`
- Listens to `Events::DamageDealt` and filters to combat damage.

6. Added normalization integration tests:
- `spec/game/integration/damage_event_normalization_spec.rb`
- Verifies noncombat and combat paths both emit canonical damage events with expected metadata and life changes.

## Behavior Notes
- Damage is still applied directly by damage effects.
- `Events::DamageDealt` is now the canonical cross-path damage signal.
- `Events::CombatDamageDealt` remains available for backward compatibility.

## Files Included In This PR
- `lib/magic/events/damage_dealt.rb`
- `lib/magic/effects/deal_damage.rb`
- `lib/magic/effects/deal_combat_damage.rb`
- `lib/magic/player.rb`
- `lib/magic/cards/lathril_blade_of_the_elves.rb`
- `spec/game/integration/damage_event_normalization_spec.rb`

## Test Evidence
Targeted:
- `bundle exec rspec spec/game/integration/damage_event_normalization_spec.rb spec/cards/lathril_blade_of_the_elves_spec.rb spec/cards/lightning_bolt_spec.rb spec/game/integration/combat/pack_leader_prevents_combat_damage_spec.rb`
- Result: passing

Full suite:
- `bundle exec rspec`
- Result: 530 examples, 0 failures

## Follow-up
- Move remaining combat-only consumers to canonical damage events.
- Evaluate eventual deprecation path for `Events::CombatDamageDealt` once no direct consumers remain.
