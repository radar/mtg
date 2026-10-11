# DSK blockers: plan

Written 2026-10-11 from `docs/dsk_blockers.md`. Groups the blocked Duskmourn cards by the engine feature they need, with card counts (including "also blocks" cards; cards needing two mechanics count under both), and orders the work.

## Tally

| # | Mechanic | Cards | Notes |
|---|---|---|---|
| 1 | Rooms: door lock/unlock, Eerie event | ~35 | 12 Room cards, 13 Eerie/unlock-effect cards, 9 "also blocks" |
| 2 | Face-down permanents (manifest dread, turn face up) | ~31 | Includes 4 manifest-dread Equipment |
| 3 | Impending | 5 | All DSK Overlords |
| 4 | Opening-hand pregame step (Leylines) | 5 | Mutation, Transformation, Resonance need extra work |
| 5 | Finality counter (die → exile) | 4 | Resurrected Cultist, Balustrade Wurm, Meathook Massacre II, Rite of the Moth |
| 6 | Exile-as-cost (graveyard cards or own creature) | 3 | Say Its Name, Abhorrent Oculus, Fear of Abduction |
| 7 | Copy effects | 3 | Jolly Balloon Man, Niko, Tale of Tamiyo |
| 8 | Variable-count ("up to N") targets | 2 | Cathartic Parting, The Rollercrusher Ride |
| 9 | One-offs | 4 | Waltz of Rage, Toby, Valgavoth, Kaito |

Rooms plus face-down cover about 75% of the blocked cards.

## Phase 1: Rooms (~35 cards)

1. Room card type: a split enchantment whose `Card` has two door halves (own name, cost, abilities each).
2. Door state on `Permanent`: locked/unlocked per door. Casting a half enters the permanent with only that door unlocked. Only unlocked doors grant abilities.
3. Unlock special action: pay a door's cost at sorcery speed. Lock/unlock-a-door effect.
4. `Events::DoorUnlocked` and `Events::RoomFullyUnlocked` (Eerie). Eerie's other half, "an enchantment you control enters", already works since a Room is an enchantment.
5. Count of unlocked doors, "target Room" filter, unlock cost reduction (Inquisitive Glimmer).
6. Order: the 12 Room cards, then Eerie cards, then the "also blocks" cards.

Status (2026-10-11): steps 1-4 done (`Cards::Room`, `Actions::UnlockDoor`, both events, `Cast door:`, `LegalActions`), see "Rooms (doors)" in `docs/engine_notes.md`. Step 5 and all cards remain.

## Phase 2: Face-down permanents (~31 cards)

1. `face_down` on `Permanent`: a 2/2 with no name, types, colours or abilities, applied through the characteristics pipeline.
2. Turn face up: special action (mana cost of a creature card, or the card's own cost) and `Events::TurnedFaceUp`.
3. Manifest dread as a `Choice` (look at top two, manifest one, other to the graveyard). "Can't be turned face up" (Unable to Scream).
4. Implement Manifest Dread plus one card of each shape, then the rest.
5. Finish Creeping Peeper once Phases 1 and 2 land.

## Phase 3: Small shared engine pieces (independent commits)

- Impending: alternative cost with time counters, not a creature while it has counters, counter removal at end step (5 Overlords). Hauntwoods also needs an "Everywhere" token with all basic land types.
- Finality counter: counter type plus die → exile replacement (4 cards).
- Opening-hand step: pregame hook so a card in the opening hand may start on the battlefield. Void, Hope, Mutation first; Transformation and Resonance last.
- Exile-as-cost: `Costs::ExileFromGraveyard`, `Costs::ExileCreature`, `pay_*` helpers. Fear of Abduction also needs a hook handing paid-cost cards to the resolved permanent.
- "Up to N" target lists in `Cast`, then Cathartic Parting and The Rollercrusher Ride.

## Phase 4: Leftovers

Copy effects (Balloon Man, Niko, Tale of Tamiyo), game-level delayed trigger (Waltz of Rage), group attack restriction (Toby), Valgavoth. Kaito last or dropped (ninjutsu is a large feature for one card).

## Workflow

- Each engine feature: own commit, integration spec, note in `docs/engine_notes.md`.
- Each card: own commit via `implement-card`.
- When a feature lands, delete the matching lines from `docs/dsk_blockers.md`.
- Keep the suite green at every commit.
