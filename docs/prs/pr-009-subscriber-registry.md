# PR 9: Replace hardcoded event recipient list with subscriber registry

## Summary

`Turn#notify!` previously iterated a hardcoded set of recipients on every event: emblems, all graveyard cards (even those with no handlers), all players, and the battlefield (which dispatched to all permanents). Adding new listeners required modifying `Turn`. This PR replaces that with a subscriber registry on `Game`.

## Why

- Adding new event listeners (stack, exile, command zone) required editing `Turn#notify!` — a core class far removed from the objects that need events
- Every event was broadcast to every graveyard card even when those cards had no handlers — an O(n·graveyard_size) scan per event
- The battlefield had its own `receive_event` intermediary that duplicated the dup-for-safety pattern already needed at the top level

## What Changed

**`lib/magic/game.rb`**
- Added `@event_listeners = []` and `attr_reader :event_listeners`
- Added `subscribe(listener)` and `unsubscribe(listener)` methods
- `add_player` now calls `subscribe(player)` automatically
- Added `EmblemList` inner class — an `Enumerable` wrapper whose `<<` operator also subscribes the emblem to the game, so `game.emblems << emblem` works correctly without requiring `add_emblem`
- `add_emblem` delegates to `@emblems <<`

**`lib/magic/game/turn.rb`**
- `notify!` reduced to: `game.event_listeners.dup.each { |listener| listener.receive_event(event) }`
- The `dup` preserves existing behaviour where newly-subscribed listeners (e.g. a token created mid-event) don't receive the event that triggered their creation

**`lib/magic/effects/move_permanent_zone.rb`**
- `game.unsubscribe(target)` after LTB events fire (while permanent is still in subscriber list), before removal from zone
- `game.subscribe(target)` after permanent is added to the battlefield, before ETB events fire

**`lib/magic/zones/battlefield.rb`**
- Removed `receive_event` — permanents are now direct subscribers, so the battlefield no longer acts as an intermediary

**`lib/magic/zones/graveyard.rb`**
- `add` subscribes a card to the game if it has non-empty `event_handlers` (e.g. Bloodghast's landfall-from-graveyard ability)
- `remove` unsubscribes, guarded by `is_a?(Magic::Card)` because `MovePermanentZone` can pass a `Permanent` to `graveyard.remove` when resolving a permanent from the graveyard

## Subscription lifecycle

| Event | Subscriber added | Subscriber removed |
|---|---|---|
| Player joins game | `add_player` | never |
| Emblem added | `EmblemList#<<` | never |
| Permanent enters battlefield | `MovePermanentZone#resolve!` (after LTB, before ETB) | `MovePermanentZone#resolve!` (after LTB fires, before removal) |
| Card enters graveyard with handlers | `Graveyard#add` | `Graveyard#remove` |

**`lib/magic/player.rb`**
- `lose!` now calls `game.unsubscribe(self)` after setting `@lost = true`, so a lost player no longer receives events

**`lib/magic/game.rb`**
- `start!` deals the opening hand by calling `player.library.draw` and `card&.move_to_hand!` directly, bypassing `Player#draw!`'s empty-library guard. This prevents `lose!` from firing during setup when the library is exactly 7 cards.

**`spec/spec_helper.rb`**
- Default library size increased from 7 to 14 cards so the draw step at the start of each turn doesn't immediately exhaust the library

**`spec/cards/peer_into_the_abyss_spec.rb`**
- Added `p2.library.items.clear` before seeding 3 test cards, since p2's library is no longer empty after `game.start!`

## Invariants Preserved

- Newly entering permanents don't receive the ETB event for other permanents entering in the same batch (dup on `event_listeners`)
- Bloodghast and any other graveyard-ability card subscribes when entering the graveyard and unsubscribes when leaving
- A lost player is removed from `event_listeners` immediately after `PlayerLost` fires, so it receives no further events
- All 534 tests pass
