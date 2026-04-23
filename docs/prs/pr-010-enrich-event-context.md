# PR 10: Enrich events with context available at creation time

## Summary

Several events were created with only the minimum data needed at the time they were written, forcing ability handlers to query live game state after the fact. This PR adds fields that were already available at each event's creation site.

`Events::DamageDealt` is left unchanged — enriching it with "damage that actually resolved after prevention" requires a damage-prevention tracking system that does not exist yet.

## What Changed

**`lib/magic/events/card_draw.rb`**
- Added `card` field (the `Card` object removed from the library)
- Field is optional (`card: nil`) so any future call site that omits it continues to work

**`lib/magic/player.rb`**
- `draw!` now passes `card:` to `Events::CardDraw`; the card is available immediately after `library.draw` and before `move_to_hand!`

**`lib/magic/events/spell_cast.rb`**
- Added `x_value` — the raw X value passed at cast time (nil if not an X spell)
- Added `flashback?` — true when the spell was cast from the graveyard via flashback
- Added `targets` — the array of chosen targets at the time the spell was placed on the stack
- `x_value` and `targets` exposed via `attr_reader`; `flashback?` is a predicate method

**`lib/magic/actions/cast.rb`**
- `perform` now passes `x_value:`, `flashback:`, and `targets:` to `Events::SpellCast`; all three are already in scope at that call site

**`lib/magic/events/entered_the_battlefield.rb`**
- Added `kicked?` predicate (stored as `@kicked`, defaulting to `false`)

**`lib/magic/events/permanent_entered_zone_transition.rb`**
- Passes `kicked: permanent.kicked?` when constructing `Events::EnteredTheBattlefield`

## Why these fields

| Field | Previous workaround | Now |
|---|---|---|
| `CardDraw#card` | Inspect player's hand after the fact | Read `event.card` directly |
| `SpellCast#x_value` | Read `mana_cost.x` off the stack item | `event.x_value` |
| `SpellCast#flashback?` | Check card's current zone (may have changed) | `event.flashback?` |
| `SpellCast#targets` | Re-resolve targets from stack item | `event.targets` |
| `EnteredTheBattlefield#kicked?` | Call `permanent.kicked?` on the actor | `event.kicked?` |

## Invariants Preserved

- All new fields have safe defaults (nil / false / []) so existing creation sites that don't pass them continue to compile and work
- No existing handler reads the new fields yet; this is purely additive
- All 534 tests pass
