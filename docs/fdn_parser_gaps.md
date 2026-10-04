# FDN (Foundations) — CardParser gaps

What stops `Magic::CardParser` + `Magic::CardGenerator` from producing a card for each
Foundations (`fdn`) card, grouped by mechanic, with the cards behind each group. Read
`docs/card_parser.md` first for how rules, effects and `EffectList` fit together. Snapshot
taken 2026-10-02, against `data/oracle-cards-20260908210154.jsonl`.

## How this was measured

```bash
bundle exec rake 'coverage[fdn]'              # bucket table (quote it: zsh globs the brackets)
bundle exec ruby script/coverage.rb fdn --lines   # failing rules lines per bucket
bundle exec ruby script/coverage.rb fdn --cards   # every card with its bucket(s)
```

`script/coverage.rb` (roadmap L1) takes the cards of the set from `Magic::Oracle#cards_in_set`,
skips those that already have a `lib/magic/cards/` file, and for each of the rest tries
`CardParser.parse` + `CardGenerator.generate`. A card that passes is "Ready to generate"; for
one that fails, every rules line no `Rule` accepts is sorted into a bucket by regex (first
match wins). Buckets are approximate and a card failing on two lines counts once in each.
**Sole** = cards blocked only by that bucket, i.e. how many cards fixing it alone unlocks.

## Headline numbers

427 FDN cards, 25 implemented, 402 not. Of those 402:

- **131** are "Ready to generate": `rake parse_card` already produces them.
- **271** are blocked by the buckets below.

| Cards | Sole | Bucket |
|---|---|---|
| 52 | 37 | Unclassified (no regex matched; see below) |
| 33 | 29 | Life / damage / draw compound effects |
| 32 | 22 | Graveyard recursion / reanimation / put onto battlefield from hand |
| 31 | 23 | ETB/dies triggers with unsupported effects |
| 23 | 16 | Tokens with unsupported shape (copies, Shapeshifter, conditional counts) |
| 18 | 13 | X-based / count-based pump |
| 17 | 12 | Conditional static keywords/abilities (as long as, during your turn) |
| 10 | 10 | Modal spells / modal ETB |
| 8 | 6 | Conditional attack/block triggers |
| 8 | 6 | Alternative / additional casting costs and cast permissions |
| 7 | 4 | Combat restrictions & evasion |
| 6 | 4 | Bounce / blink / exile effects |
| 6 | 4 | Activated abilities with limits or non-cost restrictions |
| 5 | 5 | Tribal-qualified triggers/effects |
| 5 | 0 | Planeswalker loyalty abilities (and the same 5 under "Planeswalker card kind") |
| 5 | 4 | Look at the top N cards (dig) |
| 4 | 2 | Complex mana abilities |
| 4 | 2 | Choose a creature type |
| 4 | 4 | Treasure tokens |
| 4 | 3 | Removal variants (destroy attacking/blocking, edicts) |
| 4 | 1 | Exile from top of a library, may play/cast |
| 3 | 1 | Aura/equipment restrictions and characteristic setting |
| 3 | 1 | Casting triggers with conditions |
| 2 | 1 | Legacy keywords (persist, wither, conspire, affinity) |
| 2 | 2 | Copy effects |
| 1 each | 1 each | Surveil, tuck, changeling, global replacement/prevention, mill, counterspells |
| 1 each | 0 | Ward with non-mana costs, `*` P/T, tap/untap triggers and tap-creature costs |

Nine cards fall in **no** bucket and still fail: the nine Guildgates (Azorius, Boros, Dimir,
Gruul, Izzet, Orzhov, Rakdos, Selesnya, Simic). The failure is card-level, not a rules line:
`UnsupportedCard: unsupported land:  Gate` from `CardGenerator#land_kind` (a land with a
subtype other than a basic land type). Worth a look: nine cards for one fix, and several
other FDN cards care about Gates.

## Progress log

- **2026-10-02**: `DealDamage` accepts "each creature with[out] flying" (Seismic Rupture);
  `Bite` accepts "creature or planeswalker you don't control" / "creature an opponent
  controls" (Bite Down); `EffectList::CLAUSE` splits "X and draw …" (Vampiric Rites'
  "You gain 1 life and draw a card"). Implemented: Seismic Rupture, Bite Down, Vampiric
  Rites. The new clause split also moved other cards out of the ETB/dies bucket: "Ready to
  generate" went 131 → 136, life/damage/draw 33 → 30 (26 sole), ETB/dies 31 → 28.
  Felling Blow still fails: a counter and a bite share one target ("that creature deals…"),
  which `Bite`'s two-target shape doesn't model.

- **2026-10-02 (later)**: generated all 136 "Ready to generate" cards in one pass (`rake
  parse_card` logic over `tmp/ready.txt`). Implemented 28 → 164 of 427. No per-card specs yet;
  they load and the existing suite passes, but nothing exercises their behaviour.
  `Zeitwerk::Loader.eager_load_all` fails on the pre-existing `Aftermath Analyst` (creature
  type `Detective` is not in `creature_types`), unrelated to these cards.

- **2026-10-02 (specs)**: every one of the 136 generated cards now has a spec in
  `spec/cards/` (one `Add spec for …` commit each). Writing them found two parser bugs, both
  fixed and the cards regenerated: `CostReduction` ("spells you cast cost {1} less") also
  discounted the opponent's spells (Archmage of Runes, Mocking Sprite), and `CounterSpell`
  read "red or green" in "counter target red or green spell" as card types instead of colours
  (Flashfreeze). Full suite: 4012 examples, 0 failures. Caveat: the specs were written from
  each card's Oracle text where it was checked and otherwise from the generated code, so a
  rules line the parser silently dropped on an unchecked card would not fail its spec.

- **2026-10-03 (life / damage / draw bucket)**: 29 of the bucket's cards now generate (or are
  hand-written) with specs: Duress, Pilfer, Chart a Course, Lunar Insight, Felling Blow, Fiery
  Annihilation, Hidetsugu's Second Rite, Twinflame Tyrant, Gratuitous Violence, Linden, Ancestor
  Dragon, Exemplar of Light, Erudite Wizard, Scrawling Crawler, Niv-Mizzet Visionary, Painful
  Quandary, Mindsparker, Perforating Artist, Dictate of Kruphix, Heartfire Immolator, Cryptic Caves,
  Mild-Mannered Librarian, Myojin of Night's Reach, Stromkirk Noble, Trygon Predator, Dragon Mage,
  Drake Hatcher, Fynn, and Drakuseth (the only hand-written one: it needs chained "up to two other
  targets" choices). Left: Kaito (planeswalker; loyalty-counter trigger, a can't-be-blocked `+1`, an
  emblem). New parser pieces are listed in `docs/card_parser.md` ("Life / damage / draw batch").
  Coverage after this batch: 202 of 427 implemented, 225 not (bucket: 33 → 1 card). Three
  engine bugs found on the way: generated `def event_handlers = { ... }` dropped what keywords add
  (prowess, ward) and `add_event_handler` wrote to a throwaway hash; `Game#start!` left the opening
  hands in turn 1's event log (broke "second card each turn"); activation restrictions were
  checked after costs (a sacrificed source no longer counted for Cryptic Caves' "five or more lands").
  The changes also moved six cards to "Ready to generate" (raid and opponent-cast triggers):
  Gorehorn Raider, Mischievous Mystic, Mold Adder, Searslicer Goblin, Skyship Buccaneer, Storm
  Fleet Spy; not generated here (they belong to the ETB/dies bucket).
- **2026-10-03 (ETB/dies bucket)**: 21 cards implemented, each with a spec: Gorehorn Raider, Storm
  Fleet Spy, Skyship Buccaneer (raid), Bloodtithe Collector, Viashino Pyromancer, Gatekeeper of
  Malakir, Fierce Empath, Micromancer, Rune-Scarred Demon, Campus Guide, Archway Angel,
  Good-Fortune Unicorn, Felidar Savior, Affectionate Indrik, Massacre Wurm, Prime Speaker Zegana,
  Arbiter of Woe, Thrill of Possibility (unlocked by the sacrifice/discard additional-cost rule),
  Pirate's Cutlass, Wildborn Preserver, Authority of the Consuls. New parser support: raid /
  "an opponent lost life this turn" intervening-ifs, "target player or planeswalker" damage, "target
  player sacrifices", library searches for any card / type unions / mana value / "then shuffle and put
  that card on top", "N life for each <count>" (Gate counts), "put a counter on that creature" for an
  entering creature, counters on "each of up to two target creatures", "have it fight", pumps on
  "creatures your opponents control", "that player loses N life", "enters with X counters, where X is
  the greatest power among other creatures you control", "draw cards equal to its power", additional
  sacrifice/discard casting costs, "discards a card and loses N life", "attach it to target Pirate",
  "you may pay {X}. When you do", "another non-<Type> creature you control enters", "creatures your
  opponents control enter tapped", "a creature an opponent controls enters". Bucket 28 -> 8 cards;
  FDN implemented 164 -> 194 of 427 (which includes the other agent's work from the merged base).
  Bug found: a card with `event_handlers` kept triggering from the graveyard after it died (fixed;
  handlers that really work from there declare `self.works_from_graveyard?`). Not done, and why:
  Venom Connoisseur (per-turn resolution count), Infernal Vessel (dies, returns as a Demon "in
  addition to its other types"), Garna ("if it was attacking" on a death), Nine-Lives Familiar
  (revival counters if cast + delayed return), Kiora (named legendary token, threshold),
  Undying Malice (grants a dies trigger until end of turn), Predator Ooze (needs "dealt damage by ~
  this turn" tracking), Hoarding Dragon (exile the searched card, return it when ~ dies). Six more cards
  now generate cleanly ("Ready to generate": Celestial Armor, Halana and Alena, Heroes' Bane, Searslicer
  Goblin, Seeker's Folly, Stromkirk Bloodthief) but were not generated or spec'd here.

- **2026-10-03 (hand size)**: the engine now enforces the maximum hand size (rule 514.1):
  `Player#maximum_hand_size` (7, or nil with a `no_maximum_hand_size?` permanent such as
  Niv-Mizzet, Visionary) and `Player#discard_down_to_maximum_hand_size!`, run from the turn's
  cleanup transition, which queues one `Choice::Discard` per excess card. Six older specs that end
  a turn holding 8+ cards now call the new `resolve_cleanup_discards!` spec helper.

- **2026-10-03 (tokens bucket)**: 20 of the bucket's cards implemented, each with a spec: Arahbo,
  Cat Collector, Dread Summons, Electroduplicate, Faebloom Trick, Hare Apparent, Heroic
  Reinforcements, High-Society Hunter, Homunculus Horde, Kiora the Rising Tide, Koma, Midnight Reaper,
  Midnight Snack, Revenge of the Rats, Spinner of Souls, Valkyrie's Call, Goblin Negotiation, Ovika,
  Abyssal Harvester, Redcap Gutter-Dweller. New parser pieces are in `docs/card_parser.md` ("Token
  shapes batch"). Left: Fishing Pole (an Equipment that grants the equipped creature an ability whose
  cost taps the Equipment, plus an untap trigger; needs granted activated abilities). Approximations: the
  Faebloom Trick tap is a real reflexive choice, but Goblin Negotiation measures "excess damage" from
  toughness and marked damage (so deathtouch / damage prevented by something other than marked damage
  isn't modelled), Abyssal Harvester's "put there this turn" reads the turn's zone-change log, and
  "SacrificePermanent" reads a bare "Sacrifice another creature." as optional, so it must only follow a
  "you may". Engine changes: `Choice::SacrificePermanent`, `Choice::Ward` now takes mana and life together.
  Tokens bucket 22 -> 1; FDN 251 of 427 implemented (176 not), including other agents' merged work.
- **2026-10-04 (graveyard recursion bucket)**: 28 of the bucket's 32 cards implemented, each with a spec:
  Zombify, Cemetery Recruitment, Macabre Waltz, Sanguine Indulgence, Raise the Past, Rise of the Dark
  Realms, Driver of the Dead, Nullpriest of Oblivion, Sun-Blessed Healer, Fiendish Panda, Alesha,
  Ambush Wolf, Angel of Finality, Soul-Shackled Zombie, Immersturm Predator, Cephalid Inkmage, Ghitu
  Lavarunner, Enigma Drake, Vile Entomber, Feldon's Cane, Sphinx of Forgotten Lore, Zul Ashur, Darksteel
  Colossus, Progenitus, Dryad Militant, Flamewake Phoenix, Gate Colossus, Genesis Wave. FDN coverage
  231 -> 259 of 427 implemented (bucket 32 -> 4). New parser pieces are in `docs/card_parser.md`
  ("Graveyard recursion batch"). Engine changes: graveyard replacement effects from any zone
  (`zone_replacement_effects`), `Effects::ShuffleIntoLibrary`, "attacks each combat if able"
  (`must_attack?`, `CombatPhase#validate_attackers!`), granted flashback / graveyard cast permissions,
  `Library#mill` no longer removes the card itself. Bugs found: `.to_a.each` over a zone skipped cards
  when exiling a whole graveyard (Bojuka Bog's `graveyard.cards.each(&:exile!)` has the same problem, not
  changed); a naive "all cards in all zones" scan for replacement effects made the suite take 16 minutes
  instead of 6 seconds (fixed with a per-game registry). Not done, and why: **Wilt-Leaf Liege** (its discard
  replacement needs to know a discard was caused by an opponent's spell or ability; discards don't carry a
  cause, and `Choice::Discard` bypasses `Card#discard!`), **Quilled Greatwurm** ("cast from your graveyard by
  removing six counters from among creatures you control" is a new additional-cost-plus-zone-permission
  shape), **Tinybones** (no discard event exists; also stash counters on cards in exile and a conditional
  play-from-exile static), **Finale of Revelation** (X-threshold "instead" branch, "untap up to five lands",
  a permanent no-maximum-hand-size flag and self-exile in one card).

## Cards by bucket

Cards listed under every bucket they appear in.

- **Graveyard recursion / reanimation**: Alesha Who Laughs at Fate, Ambush Wolf, Angel of
  Finality, Cemetery Recruitment, Cephalid Inkmage, Darksteel Colossus, Driver of the Dead,
  Dryad Militant, Enigma Drake, Feldon's Cane, Fiendish Panda, Finale of Revelation, Flamewake
  Phoenix, Gate Colossus, Genesis Wave, Ghitu Lavarunner, Immersturm Predator, Macabre Waltz,
  Nullpriest of Oblivion, Progenitus, Quilled Greatwurm, Raise the Past, Rise of the Dark
  Realms, Sanguine Indulgence, Soul-Shackled Zombie, Sphinx of Forgotten Lore, Sun-Blessed
  Healer, Tinybones Bauble Burglar, Vile Entomber, Wilt-Leaf Liege, Zombify, Zul Ashur Lich Lord.
- **ETB/dies triggers with unsupported effects**: Affectionate Indrik, Arbiter of Woe, Archway
  Angel, Authority of the Consuls, Bloodtithe Collector, Campus Guide, Cloudblazer, Felidar
  Savior, Fierce Empath, Garna, Gatekeeper of Malakir, Good-Fortune Unicorn, Gorehorn Raider,
  Hoarding Dragon, Infernal Vessel, Inspiring Overseer, Kiora the Rising Tide, Massacre Wurm,
  Micromancer, Nine-Lives Familiar, Pirate's Cutlass, Predator Ooze, Prime Speaker Zegana,
  Rune-Scarred Demon, Skyship Buccaneer, Storm Fleet Spy, Tatyova Benthic Druid, Undying
  Malice, Venom Connoisseur, Viashino Pyromancer, Wildborn Preserver.
- **Tokens with unsupported shape**: Abyssal Harvester, Arahbo, Cat Collector, Dread Summons,
  Electroduplicate, Faebloom Trick, Fishing Pole, Goblin Negotiation, Hare Apparent,
  Heroic Reinforcements, High-Society Hunter, Homunculus Horde, Kiora the Rising Tide, Koma,
  Midnight Reaper, Midnight Snack, Mischievous Mystic, Ovika, Redcap Gutter-Dweller, Revenge
  of the Rats, Searslicer Goblin, Spinner of Souls, Valkyrie's Call.
- **X-based / count-based pump**: Battle-Rattle Shaman, Blanchwood Armor, Death Baron,
  Empyrean Eagle, Goblin Oriflamme, Halana and Alena, Heraldic Banner, Heroes' Bane, Lyra
  Dawnbringer, Massacre Wurm, Midnight Snack, Prime Speaker Zegana, Regal Caracal, Ruby Daring
  Tracker, Tempest Djinn, Tragic Banshee, Wilt-Leaf Liege.
- **Conditional static keywords/abilities**: Celestial Armor, Crystal Barricade, Divine
  Resilience, Elenda, Inspiring Paladin, Kargan Dragonrider, Kellan Planar Trailblazer, Kitesail
  Corsair, Knight of Grace, Knight of Malice, Myojin of Night's Reach, Quick-Draw Katana,
  Quilled Greatwurm, Skyknight Squire, Tinybones, Twinblade Paladin, Wishclaw Talisman.
- **Modal spells / modal ETB**: Boros Charm, Bushwhack, Charming Prince, Deadly Plot, Demonic
  Pact, Kykar, Seeker's Folly, Strongbox Raider, Sylvan Scavenging, Wardens of the Cycle.
- **Conditional attack/block triggers**: Ashroot Animist, Courageous Goblin, Frenzied Goblin,
  High-Society Hunter, Predator Ooze, Savage Ventmaw, Vampire Gourmand.
- **Alternative / additional casting costs**: Arbiter of Woe, Ballyrush Banneret, Ghalta,
  Harbinger of the Tides, Luminous Rebuke, Sanguine Indulgence, Thrill of Possibility, Tolarian
  Terror.
- **Combat restrictions & evasion**: Gate Colossus, Gateway Sneak, Goblin Smuggler, Joraga
  Invocation, Juggernaut, Sower of Chaos, Stromkirk Noble.
- **Bounce / blink / exile**: Aetherize, Arcanis the Omnipotent, Finale of Revelation, Hoarding
  Dragon, Maze's End, River's Rebuke.
- **Activated abilities with limits**: Ayli, Carnelian Orb of Dragonkind, Heraldic Banner,
  Hungry Ghoul, Ravenous Amulet, Zimone.
- **Tribal-qualified**: Crawling Barrens, Dropkick Bomber, Kalastria Highborn, Vengeful
  Bloodwitch, Volley Veteran.
- **Planeswalkers**: Ajani Caller of the Pride, Chandra Flameshaper, Kaito Cunning Infiltrator,
  Liliana Dreadhorde General, Vivien Reid. The card kind and loyalty abilities both fail, so
  fixing planeswalkers unlocks nothing alone; each also has a hard ability.
- **Dig**: Curator of Destinies, Gutless Plunderer, Loot, Squad Rallier, Vizier of the Menagerie.
- **Complex mana**: Giada, New Horizons, Ramos, Three Tree Mascot.
- **Chosen type**: Adaptive Automaton, Banner of Kinship, Diamond Mare, Heraldic Banner.
- **Treasure**: An Offer You Can't Refuse, Brass's Bounty, Fake Your Own Death, Goldvein Pick.
- **Removal variants**: Blasphemous Edict, Deathmark, Demolition Field, Hero's Downfall.
- **Exile top, may play**: Etali, Kellan, Redcap Gutter-Dweller, Vizier of the Menagerie.
- **Aura/equipment restrictions**: Eaten by Piranhas, Fishing Pole, Witness Protection.
- **Casting triggers with conditions**: Diamond Mare, Gnarlback Rhino, Ramos.
- **Legacy keywords**: Claws Out (affinity), Gate Colossus.
- **Copy effects**: Teach by Example, Thousand-Year Storm.
- **One-offs**: Inspiration from Beyond (mill), Soulstone Sanctuary (changeling), Giant
  Cindermaw (global replacement), Sphinx of the Final Word (counterspell), Uncharted Voyage
  (tuck), Vanguard Seraph (surveil), Ovika (ward with non-mana cost), Crusader of Odric (`*`
  P/T), Immersturm Predator (tap/untap trigger).

## "Unclassified" (37 sole)

No regex matched the failing line, so this bucket hides about ten distinct families.
Reading the card text:

1. **Intervening-if end-step / combat triggers (7)**: morbid ("if a creature died this turn"):
   Cackling Prowler, Needletooth Pack, Slumbering Cerberus (also "doesn't untap during your
   untap step"); "if an opponent lost life this turn": Stromkirk Bloodthief; "if you control
   another creature with power 4 or greater": Nessian Hornbeetle; formidable (total power 8+):
   Surrak the Hunt Caller.
2. **Attack-count triggers (2)**: Armasaur Guide ("attack with three or more creatures"),
   Aurelia the Warleader (first attack each turn, untap all, additional combat phase).
3. **Enters-with-counters variants (3)**: raid ("if you attacked this turn"): Goblin Boarders;
   kicked "enters with two counters" plus "each creature with a +1/+1 counter has trample":
   Gnarlid Colony; X counters plus "whenever counters are put on another creature":
   Wildwood Scourge.
4. **Rule-bending statics (7)**: High Fae Trickster (cast as though flash), Omniscience
   (cast free from hand), Herald of Eternal Dawn (can't lose / can't win), Angel of Vitality
   (lifegain +1 replacement plus conditional +2/+2), Fog Bank (prevent combat damage to and by
   itself), Sorcerous Spyglass (choose a name, disable activated abilities), Leyline Axe
   (opening-hand start).
5. **Opponent-event triggers (2)**: Bloodthirsty Conqueror ("whenever an opponent loses life,
   you gain that much"), Mold Adder ("opponent casts a blue or black spell").
6. **Library search variants (4)**: Circuitous Route (basic and/or Gate, tapped), Grow from the
   Ashes (kicked "instead search for two"), Mystical Teachings (instant or flash card, plus
   flashback), Ordeal of Nylea (Aura, sacrifice trigger, then search).
7. **One-off spell effects (9)**: Biogenic Upgrade (distribute counters, then double), Time Stop
   (end the turn), Fleeting Flight (prevent combat damage to target), Exsanguinate (X life
   loss, gain equal), Devout Decree (color-filtered exile plus scry), Day of Judgment (destroy
   all creatures), Tribute to Hunger (edict plus gain toughness), Bulk Up (double power plus
   flashback), Harmless Offering (opponent gains control).
8. **Control-change Aura (1)**: Confiscate ("You control enchanted permanent").
9. **Self-sacrifice at end step (1)**: Ball Lightning ("at the beginning of the end step,
   sacrifice this creature"). Probably the cheapest in the bucket.
10. **Odd one-offs (2)**: Cultivator's Caravan (Vehicle with Crew and a mana ability),
    Desecration Demon ("any opponent may sacrifice a creature…").

Other unclassified-and-also-blocked cards: Alesha, Authority of the Consuls, Crusader of
Odric, Crystal Barricade, Flamewake Phoenix, Giada, Hare Apparent, Juggernaut, Myojin of
Night's Reach, Nine-Lives Familiar, Niv-Mizzet Visionary, Progenitus, Vizier of the
Menagerie, Zimone.

## "Life / damage / draw compound effects" (29 sole, 33 total)

Also a grab-bag. The buckets below are what the 34 card texts actually need; "Done" notes are
added as they ship (see the git log for `docs/fdn_parser_gaps.md`).

- **Hand-disruption "reveal, you choose, discard" (2)**: Duress, Pilfer.
- **Draw with a conditional follow-up (1)**: Chart a Course ("then discard a card unless you
  attacked this turn").
- **Count-based draw (1)**: Lunar Insight ("a card for each different mana value among
  nonland permanents you control").
- **"Creature deals damage equal to its power" (3)**: Bite Down, Felling Blow (counter first,
  then damage), Heartfire Immolator (`{R}, sacrifice: it deals damage equal to its power`).
- **Damage spells with riders (3)**: Seismic Rupture (each creature without flying), Fiery
  Annihilation (exile Equipment, exile instead of dying), Hidetsugu's Second Rite (exactly 10
  life).
- **Multi-target damage on attack (1)**: Drakuseth.
- **Damage doubling replacement (2)**: Twinflame Tyrant, Gratuitous Violence.
- **Combat-damage-to-player triggers (6)**: Stromkirk Noble (counter), Trygon Predator
  (destroy artifact/enchantment), Dragon Mage (wheel), Drake Hatcher (incubation counters, then
  Drake), Fynn (poison for deathtouch), Kaito (loyalty counter; planeswalker).
- **Lifegain triggers (3)**: Ancestor Dragon (attackers), Linden (white attacker), Exemplar of
  Light (counter, then draw once a turn).
- **Draw/opponent-event triggers (6)**: Scrawling Crawler (each player draws; opponent draw =
  lose 1), Erudite Wizard (second draw each turn), Niv-Mizzet Visionary (noncombat damage =
  draw), Painful Quandary (lose 5 unless discard), Mindsparker (white/blue instant or sorcery),
  Perforating Artist (raid, "unless" choice).
- **Draw-step replacement (1)**: Dictate of Kruphix.
- **Activated draw/sacrifice (3)**: Vampiric Rites, Cryptic Caves ("only if five or more
  lands"), Mild-Mannered Librarian ("only once", becomes Werewolf).
- **Myojin of Night's Reach (1)**: divinity counter, conditional indestructible, opponent
  discards hand.
