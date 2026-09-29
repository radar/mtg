# Card parser: post-2016 mechanic gaps

Which mechanics from the last decade of sets (Kaladesh onward) the card parser does not
handle, how many cards each affects, and whether the engine already supports them. Used to
decide what to build next in `lib/magic/card_parser/`.

## Method

`script/mechanic_counts.rb` (`bundle exec ruby script/mechanic_counts.rb`) runs a regex per
mechanic over the Oracle data (`data/oracle-cards-*.jsonl`, one printing per card) and counts
cards whose `released_at` is on or after 2016-09-01.

Caveats:

- The date is the default printing's, so reprints of older cards are counted.
- Regexes are approximate and overlap (a card can count under several mechanics). "instead"
  matches every card using the word, not only replacement effects; "Room" and "storm" match
  ordinary words.
- The "unimplemented" column in the script's output uses a name-to-filename guess and is
  close to the total for most rows; use the totals.
- Engine support was judged by `rg` over `lib/magic` (outside `cards/` and `card_parser/`),
  not by running specs.

Parser coverage was read from `docs/card_parser.md` and `lib/magic/card_parser/rules/keywords.rb`:
the parser handles evergreen keywords, ward, protection, toxic, hexproof-from, kicker,
flashback and cycling, scry/surveil/blight, Treasure/Food/Clue tokens, sagas and modal spells.

## Tier 1: engine has it, parser does not

| Mechanic | Cards | Engine support |
|---|---|---|
| "...instead" replacement text | ~850 | Replacement effects exist |
| Planeswalker card kind | 262 | `permanents/planeswalker.rb`, loyalty actions |
| "As an additional cost to cast" | 248 | `Cast` supports additional costs |
| X spells (`{X}`) | 214 | `Cast#value_for_x` |
| Kicker on triggers/abilities, multikicker | 153 / 11 | Kicker cost exists; parser limits it to instants, sorceries, modes |
| Investigate | 118 | `tokens/clue.rb`; no parsed effect |
| Convoke | 96 | `Card.convoke` macro, `Cast` support; Keywords rule ignores it |
| Proliferate | 85 | `Choice::Proliferate` |
| Landcycling | 78 | Cycling exists; parser rejects it |
| Monarch | 53 | Player and game state |
| Ward with a non-mana cost | 50 | Ward exists; parser reads mana and life only |
| Rebound | 26 | `rebound` macro |
| Adventure | 21 | `adventure` macro, `on_adventure`, `Cast(adventure:)`; no parser card kind |
| Blitz | 19 | `Cast(blitz:)` |

## Tier 2: small engine addition plus a parser rule

Amass 71, explore 53, connive 50, cascade 48, incubate 32, discover 29, populate 24,
adapt 25, delve 17, improvise 26, emerge 11, exalted 16, undying 12, persist 16,
afterlife 12, riot 16, mentor 22, training 13, evoke 28, madness 44.

## Tier 3: engine work first

Double-faced and modal double-faced cards 450 (only `Permanent#transform!` exists), Vehicles and
crew 190, energy 142, morph/disguise/manifest/cloak 142 (no face-down permanents),
elemental bending 112, Room 64, foretell 57, companion 38, dungeons 38, initiative 26,
escape 38, disturb 29, jump-start 14, mutate 35, bestow 15, prototype 19, reconfigure 17,
backup 26, saddle 30, boast 20, Battle 36.

## Build order

1. "...instead" replacement text.
2. Planeswalker card kind.
3. Additional-cost and X spells.
4. Investigate, proliferate, convoke.
5. Kicker on triggers, landcycling, non-mana ward, monarch, adventure kind.
6. Explore, amass, connive, incubate.
7. Vehicles and crew, then double-faced cards.

Steps 1 and 2 were started on separate branches; see the git history for their state.
