# Jeskai deck (Zinnia, Valley's Voice): implementation plan

The pasted deck has 91 distinct cards. 25 are implemented already (basic lands, Arcane Signet, Mind Stone, Sol Ring, Path to
Exile, Fable of the Mirror-Breaker, Zinnia, Panharmonicon, Impact Tremors, Anointed Procession, the Temples of Epiphany and
Triumph, Thriving lands in other colours, ...). **66 are not.** Found by running the arena `Deck#missing` check on the list.

Then, in arena, add `config/decks/jeskai.txt` (the pasted list) and run seeded sims with `DECK=jeskai`.

## How to implement a card

- Plain text card: `printf 'Name {cost}\nType — Sub\nrules\nP/T\n' | bundle exec rake parse_card` writes `lib/magic/cards/<name>.rb`
  (`docs/card_parser.md`). Always read the generated file against the Oracle text, then write a spec in `spec/cards/`.
- Otherwise copy the closest existing card (`docs/card_patterns.md`).
- `bundle exec rake coverage[<set code>]` says which mechanics block the parser.
- Change files with Write and Edit only. One spec per card. Each card ends with a seeded sim sweep.

## Status (2026-10-06): all 91 cards are implemented and the deck plays

All 66 missing cards now exist, each with a spec (`bundle exec rspec`: 5148 examples). `arena/config/decks/jeskai.txt` is
in, `DeckTest` and a `TableTest` game test cover it, and seeded bot games (`DECK=jeskai bin/rails runner
script/simulate.rb <seed>`) finish to a winner. What the work turned up, beyond the cards:

Engine:
- Bouncing a token crashed (`Permanent#return_to_hand`); `Permanent#destroy!(regenerate: false)` ("can't be regenerated");
  a permanent spell keeps its X (`Permanent#x_value`, `Card#entering_counters_for_x`, Jacked Rabbit's ravenous);
  `Cast#can_target?` asks the card `target_fits_x?` (Stolen by the Fae); `Costs::Gift` ("Gift a card", Starfall
  Invocation); `Modifications::RemoveTypes` ("the token isn't legendary", Helm of the Host); reconfigure (Lizard Blades:
  attached means "isn't a creature", `ContinuousEffects#calculate_types`); `Costs::Parser` reads "Sacrifice a Treasure";
  unearth (Molten Gatekeeper) as a graveyard ability; a modal double-faced land is played with `face: :back`.
- A Saga that transformed (Fable of the Mirror-Breaker) kept gaining lore counters and crashed on the next chapter; it is
  no longer sacrificed after its final chapter either.
- A `TriggeredAbility::BeginningOfYourUpkeep` override must call `super` (Hellkite Tyrant's win check fired on any upkeep).

Arena:
- `GiftPrompt`, an X prompt that only offers the X with a legal target, a May that picks up to N cards (Fable's discard),
  shift-click for a back face, and mana that is restricted to some spells (Path of Ancestry's) is no longer tapped to pay
  for a choice, an ability, cycling, or an X or kicker payment that is made from the pool.
- `audit_castable.rb` now has Islands and Mountains; it is silent for this deck.

Not modelled: Adeline's token always attacks the player, never a planeswalker; Suture Priest and Solemn Simulacrum always
take their "may" (it is never worse to); Skyclave Apparition, Sun Titan and Echoing Assault ask for their target even when
there is only one.

## Earlier status (2026-10-05)

**Batches 1 and 2 are done** (all 19 lands, the 3 Signets and Fellwar Stone, each with a spec; 4941 mtg examples pass),
except Helm of the Host, which waits for Batch 4/5. 25 of the 66 missing cards are now implemented, so **41 remain**
(Batches 3 and 4, plus Helm of the Host). Notes from doing them:

- The tables below were drafted from memory; the Oracle text in `data/` was the source of truth, and some guesses were wrong:
  Skycloud Expanse, Ferrous Lake and Sunscorched Divide are `{1},{T}: Add two colours` lands (no enters-tapped, no single
  mana ability); Seachrome Coast is a fast land; Cascade Bluffs and Rugged Prairie are `{C}` plus a hybrid-cost filter.
- Hybrid costs (`{U/R}`) and mana abilities with a mana cost work as they are (`costs "{1}, {T}"`).
- Filter lands pick a pair with `choose(:blue_red)`-style names. Arena's auto-tapper only uses mana sources whose own cost
  is generic (`payable_from_pool?`), so it never taps the two hybrid filter lands for mana: they only give `{C}` there.
  A hybrid-cost source in `Table#tap_for_mana` is the one arena gap left from this batch.
- Needleverge Pathway // Pillarverge Pathway: `PlayLand` takes `face: :back` (`Player#play_land(land:, face: :back)`),
  which transforms the new permanent to its back face. Arena: shift-click the card in hand; the hand card's title says so.
- `Deck` reads "Front / Back" lines as the front face. `config/decks/jeskai.txt` is not added yet: `DeckTest` fails any
  deck with unimplemented cards, so add it when Batches 3 and 4 are done.

## Batch 1: lands (19), mostly copies of existing patterns (about an hour)

| Group | Cards | Based on |
|-------|-------|----------|
| Pain / painland-style taps for colour or {C}, damage | Adarkar Wastes, Battlefield Forge, Shivan Reef | existing painlands (search `deals 1 damage to you`) |
| Fastlands... check-lands (enter tapped unless you control a basic of type) | Clifftop Retreat, Glacial Fortress, Sulfur Falls, Rugged Prairie? | check an existing "unless you control a Plains or Island" land |
| Slowland/"unless two or more other lands" | Cascade Bluffs, Seachrome Coast, Skycloud Expanse | Cascade Bluffs is a filter land: `{1},{T}: two mana of W/U` etc., check `Abilities::Mana` for a filter pattern |
| Snarls ("may reveal a card to enter untapped") | Furycalm Snarl | needs a reveal-a-card-from-hand choice (`Choice`) |
| Thriving | Thriving Bluff, Thriving Heath | Thriving Grove / Thriving Moor |
| Temple | Temple of Enlightenment | Temple of Epiphany |
| Castle | Castle Ardenvale | an existing Castle if any, else {2}{W}{W},{T}: Human 1/1 token; enters tapped unless you control a Plains |
| Other | Mystic Monastery (tri-land, enters tapped), Needleverge Pathway (modal double-faced land: two cards in one), Sunscorched Divide (wait: it is a Tapland variant, check Oracle), Ferrous Lake | Indatha Triome; Pathway needs a back face (see Fable of the Mirror-Breaker for the two-face model) |

Rugged Prairie is the {R/W} filter land: confirm hybrid-cost payment works for `{R/W}` before writing it.

Arena: lands that ask a question on entering (Snarl reveal, Castle, check-lands) go through `ChoicePrompt`, so no new UI. The
Pathway needs a "which face" choice when played from hand: the cast/play prompt does not offer faces yet (see Batch 5).

## Batch 2: mana rocks (5), small

Azorius Signet, Boros Signet, Izzet Signet, Fellwar Stone, Helm of the Host (the last one is not a rock: see Batch 5).
Signets: `{1},{T}: add one mana of each of two colours`; copy Arcane Signet and add the `{1}` cost. Fellwar Stone: add one
mana of any colour a land an opponent controls could produce (needs `Player#land_colours_producible`, or answer
"any colour" and note the gap in the spec).

## Batch 3: simple creatures and spells, the bulk (about 25 cards)

Parser-sized (plain ETB, triggers on one event, keyword creatures): Aether Channeler (modal ETB: bounce, draw, or Map token),
Agate Instigator is implemented, Circuit Mender, Curiosity Crafter, Jacked Rabbit, Loyal Warhound, Plumecreed Escort,
Pollywog Prodigy, Rapid Augmenter, Rose Room Treasurer, Selfless Spirit, Soul Warden, Suture Priest, Thopter Engineer,
Witty Roastmaster, Echoing Assault, Fell the Mighty, Rowdy Research, Starfall Invocation, Stolen by the Fae, Storm of
Souls, Calamity of Cinders, Lizard Blades, Jeska's Will, Mentor of the Meek, Hellkite Tyrant, Molten Gatekeeper,
Ornithopter of Paradise, Solemn Simulacrum, Sun Titan, Siege-Gang Commander, Blade Splicer.

For each: run `parse_card`, fix by hand what it cannot do. Likely gaps: "whenever one or more", "power 2 or less" filters
(Mentor of the Meek), "enters with X counters" (Rapid Augmenter, Rapid Hybridization), "target creature's power" scaling
(Fell the Mighty), Treasure/Map/Thopter token helpers (check `Magic::Tokens`), and "choose a basic land type" for Jeska's Will
("exile top three, you may play them this turn"; the engine has `play_permissions.grant_until_end_of_next_turn`).

## Batch 4: needs a new engine piece (about 8 cards), do one at a time

| Card | Piece to build |
|------|----------------|
| Skyclave Apparition | exile until it leaves, return a token of the exiled card's mana value (Grasp of Fate model plus a token copy by mana value) |
| Sun Titan | "return a permanent card with mana value 3 or less from your graveyard" ETB/attack trigger (`ReturnCards`, `docs/card_parser.md` graveyard recursion) |
| Elspeth, Sun's Champion | planeswalker with −3 "destroy all creatures with power 4 or greater", +1 three tokens: use the Calix pattern, loyalty abilities already work in arena |
| Dualcaster Mage | flash, "copy target instant or sorcery spell" needs copy-spell on the stack (check `Effects::CopySpell`; Repeated Reverberation has one) |
| Mystic Remora | cumulative upkeep: counters and a "pay {1} per age counter" choice. Engine has no cumulative upkeep: add it (`Keywords::CumulativeUpkeep`) |
| Brudiclad, Telchor Engineer | tokens become copies of a chosen token: layer 1 copy of a token (J3 on the roadmap), probably a replacement effect for `CreateToken`; hard |
| Rapid Hybridization | destroys a creature and gives a 3/3 Frog: simple, but "can't be regenerated" is not modelled |
| Professional Face-Breaker | Treasure on combat damage, sacrifice a Treasure: exile top card, play it this turn |

Order within the batch: Elspeth, Sun's Champion; Sun Titan; Skyclave Apparition; Rapid Hybridization; Professional Face-
Breaker; Dualcaster Mage; Mystic Remora; Brudiclad (last, or leave unimplemented and cut from the deck for the playtest).

## Batch 5: arena gaps this deck will surface

- A face choice for modal double-faced lands (Needleverge Pathway): `Table#play` needs a prompt, `Magic::Actions::PlayLand`
  needs a `face:` option.
- Helm of the Host (copies the equipped creature at the beginning of combat, no legendary rule): an equipment trigger that
  makes a token copy; arena just shows a token. Needs the same token-copy piece as Brudiclad.
- Any "reveal a card from hand" cost (Furycalm Snarl): a pick prompt on cast/play (`ChoicePrompt` wraps it).
- Tokens that are copies need art: the card image for a token copy should use the copied card's image.

## Verification

1. Every card: a spec; `bundle exec rspec` green.
2. `bin/rails runner script/audit_stats.rb`, `audit_castable.rb`, `audit_deck.rb` with `DECK=jeskai`: silent.
3. Seeded sims `DECK=jeskai bin/rails runner script/simulate.rb <seed>` for seeds 1–50. Fix every `BUG` line with a
   spec, as for the elves deck (`arena/docs/elves-deck-playtest.md`).
4. Arena test: add a jeskai game to `TableTest`; record the findings in `arena/docs/jeskai-deck-playtest.md`.

## Order of work

1. Add the deck file and `Deck` entry; list the `missing` names it reports (should be the 66).
2. Batch 2 and 1 (quick, unlock land fixing for the mana base).
3. Batch 3 in chunks of 8 with a sim sweep after each.
4. Batch 4, one card per sitting.
5. Batch 5 only for what the sims actually hit.
