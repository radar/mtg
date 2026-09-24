# ECL (Lorwyn Eclipsed) — CardParser gaps and plan

What stops `Magic::CardParser` + `Magic::CardGenerator` from producing a card for each
face of the Lorwyn Eclipsed (`ecl`) set, the mechanics behind those failures grouped into
sets, tallies for each, and a plan for tackling them. Read `docs/card_parser.md` first for
how rules, effects and `EffectList` fit together.

## How this was measured

`script/parser_gaps.rb` (re-run it to measure progress; `--lines` shows failing lines per
mechanic, `--cards` lists every failing face):

```bash
bundle exec ruby script/parser_gaps.rb ecl
```

- Cards come from `Magic::Oracle#cards_in_set("ecl")` (the Scryfall `set` field). The data
  file holds one printing per card, so a card reprinted in ECL but whose default printing
  is elsewhere is missing, and the reverse. Basic lands are skipped. Each face of a
  double-faced card is parsed on its own.
- A face passes if `CardParser.parse` and `CardGenerator.generate` both succeed. For a
  failing face every rules line is tried against every `Rule`; the lines no rule accepts
  are sorted into mechanics by the regexes in `MECHANICS` (first match wins), and
  card-level structure (hybrid mana, Kindred, planeswalker) adds more.
- The buckets are approximate; they exist to plan work, not to be exact. A face that fails
  on two mechanics counts once in each. **Sole** = the only mechanic blocking that face,
  i.e. how many faces implementing it alone would unlock. Unlock numbers assume the
  effects those lines use are otherwise parseable, which is optimistic (see Caveats).

## Headline numbers

| | Faces |
|---|---|
| ECL faces surveyed (262 cards) | 269 |
| Parse and generate cleanly today | 15 (6%) |
| Fail | 254 (94%) |
| Fail on exactly one mechanic | 135 |
| Fail on two or fewer | 232 |
| Fail on three or fewer | 252 |

Most faces are one or two mechanics away, so unlocking is incremental: no single mechanic
is a wall, but there are about 45 of them.

## Progress

Last re-run: 269 faces, **36** generate cleanly (was 15); 151 failing faces have a single
remaining blocker (was 135). Numbers in the tables below are from the first survey.

Done so far:

- **Hybrid mana and `{X}` in costs**: `ManaCost` (hybrid keys like `black_or_green`, `x: 1`).
  Not done: hybrid symbols inside activation-cost strings (`Costs::Parser` can't read
  `{B/G}` there yet).
- **Blight**: `Choice::Blight`, `Costs::Blight` (`pay_blight`), the `Blight` effect (you /
  each opponent / target opponent), "If you don't" / "When you do" after an optional
  effect, and the first-main-phase trigger. Six cards generated. *Not* done: blight as a
  cast cost ("As an additional cost to cast ~, you may blight N", "blight N or pay {M}",
  "blight X"), the "if the additional cost was paid ... instead" grammar, "you may pay
  {M}. If you don't, blight N", and effects that name the blighted creature (Grub).
- **Changeling**: the keyword line (`Rules::Changeling`, via the new `Rule#class_reference`).
  Not done: changeling tokens ("Shapeshifter creature token with changeling"), "is all
  creature types" on equipment, "except it has changeling".
- **Creature-type-qualified triggers and targets**: another <Type> you control dies /
  enters, "~ or another <Type> you control enters", a <Type> creature you control dies,
  ~ becomes tapped, "target [attacking] <Type> you control", plus an `Untap` effect.
  Seven cards generated. Not done: "Kithkin creatures you control also gain first
  strike", "Other tapped creatures ...", damage equal to a creature's power, and
  "of the chosen type".

Cards generated this way: Dream Seizer, Sourbread Auntie, Gutsplitter Gang, Warren
Torchmaster, Sting-Slinger, Blighted Blackthorn, Boggart Cursecrafter, Elder Auntie,
Boggart Prankster, Thoughtweft Lieutenant, Pestered Wellguard, Tributary Vaulter,
Deepchannel Duelist.

## Tally by mechanic set

Faces = failing faces containing that mechanic; Sole = faces it alone blocks.

### A. Card structure and costs

| Mechanic | Faces | Sole | Examples |
|---|---:|---:|---|
| Hybrid mana symbols in the cost (`{B/G}`, `{R/W}`, ...) | 33 | 0 | Figure of Fable, Lluwen, the First-Year legends |
| Kindred type line (Kindred Instant/Sorcery/Enchantment/Artifact) | 13 | 1 | Crib Swap, Brigid's Command, Clachan Festival |
| `{X}` in the cost | 2 | 0 | End-Blaze Epiphany, Celestial Reunion |
| Planeswalker card kind + loyalty abilities | 3 | 0 | Oko (both faces), Ajani, Outland Chaperone |
| Legendary enchantment | 1 | 0 | Mornsong Aria |
| `*/N` power/toughness (characteristic-defining) | 1 | 0 | Squawkroaster |

### B. ECL set mechanics

| Mechanic | Faces | Sole | Examples |
|---|---:|---:|---|
| Blight (additional cost, activation cost, "you may blight", "each opponent blights") | 25 | 11 | Blighted Blackthorn, Gutsplitter Gang |
| Changeling (keyword, "all creature types", changeling tokens, Mutavault token) | 20 | 4 | Mutable Explorer, Omni-Changeling |
| Convoke (keyword, and "creature spells you cast have convoke") | 16 | 3 | Sun-Dappled Celebrant |
| Vivid ("colors among permanents you control") | 14 | 8 | Bloom Tender, Aurora Awakener |
| Pay-to-transform / double-faced cards ("you may pay {B}. If you do, transform ~") | 14 | 6 | Grub, Ashling, Eirdu |
| Choose a creature type / "of the chosen type" | 12 | 4 | Dawn-Blessed Pennant, Gathering Stone |
| Behold (additional cost) | 12 | 2 | Champion of the Weird |
| Evoke (with hybrid cost) | 5 | 0 | Vibrance, Catharsis, Deceit |
| "If {R}{R} was spent to cast it" (the Evoke incarnations' ETB) | 5 | 0 | Vibrance, Catharsis |

### C. Trigger and condition grammar

| Mechanic | Faces | Sole | Examples |
|---|---:|---:|---|
| Creature-type-qualified triggers and effects ("another Goblin you control", "Kithkin creatures you control") | 17 | 10 | Boggart Prankster, Gallant Fowlknight |
| "Becomes tapped" triggers, "untap/tap it", tap-N-creatures costs | 9 | 7 | Goatnap, Silvergill Peddler |
| ETB/dies triggers whose effect isn't supported (fight, tap enchanted creature, ...) | 9 | 2 | Pitiless Fists, Blossombind |
| Casting triggers with conditions (mana value 4 or greater, during an opponent's turn) | 4 | 3 | Enraged Flamecaster |
| Conditional attack/block triggers (attacks alone, ...) | 4 | 2 | Gravelgill Scoundrel |
| Optional-payment triggers ("you may pay {X}. If you do, ...") | 16 | — | Grub (shares its bucket with transform) |
| "Up to N targets", "any number of targets" | 20 | — | Pitiless Fists, Liminal Hold |
| Delayed / "until your next turn" effects | 9 | — | End-Blaze Epiphany |

The last three rows cut across the buckets above (a face is counted under its main
mechanic); they are grammar the effect parser needs, not separate mechanics.

### D. Effects

| Mechanic | Faces | Sole | Examples |
|---|---:|---:|---|
| Modal spells ("Choose one —", "Choose one or both", bulleted modes, "choose both if the additional cost was paid") | 15 | 9 | Taster of Wares, Brigid's Command |
| Graveyard recursion / reanimation / put onto the battlefield from hand | 10 | 8 | Dundoolin Weaver, Gloom Ripper |
| Tokens with an unsupported shape (Shapeshifter with changeling, copies of a creature, conditional counts) | 12 | 5 | Bitterbloom Bearer |
| Bounce / blink / exile-until effects | 9 | 1 | Flock Impostor, Morningtide's Light |
| Life / damage / draw compound effects ("2 damage to any target and 1 to another", "draw three, then discard unless") | 6 | 4 | Boulder Dash, Thirst for Identity |
| X-based / count-based pump ("where X is ...") | 5 | 4 | Thoughtweft Charge |
| Treasure tokens | 3 | 2 | Flamekin Gildweaver, Reckless Ransacking |
| Copy effects (copy a permanent, spell or triggered ability) | 2 | 1 | Mirrorform, Kirol |
| Counterspells | 4 | 1 | Spell Snare |
| Tuck / put a permanent into its owner's library | 3 | 0 | Swat Away, Mornsong Aria |
| Removal variants (destroy attacking/blocking, edicts) | 1 | 0 | |

### E. Library and zone effects

| Mechanic | Faces | Sole | Examples |
|---|---:|---:|---|
| Surveil | 7 | 3 | Twilight Diviner, Wary Farmer |
| Exile the top card(s) and let the player play/cast them | 7 | 1 | Bre of Clan Stoutarm, Maralen |
| Look at the top N cards and take one (dig) | 5 | 0 | the Eclipsed cycle |
| Mill | 4 | 3 | |

### F. Counters

| Mechanic | Faces | Sole | Examples |
|---|---:|---:|---|
| -1/-1 counter interactions ("while ~ has a -1/-1 counter on it", "when it dies, if it had a -1/-1 counter") | 10 | 9 | Retched Wretch, Reluctant Dounguard |
| Other counter mechanics (remove any/N counters as a cost, stun, charge, dream, keyword counters, "can't have counters") | 15 | 7 | Loch Mare, Glen Elendra Guardian |

### G. Static and continuous effects, keywords, mana

| Mechanic | Faces | Sole | Examples |
|---|---:|---:|---|
| Conditional statics ("as long as", "during your turn", hexproof from colours, becomes all colours) | 11 | 4 | Adept Watershaper, Bark of Doran |
| Alternative/additional casting costs and permissions (cost reductions, "may cast from among cards exiled with ~") | 13 | 2 | Maralen, Cinder Strike |
| Combat restrictions and evasion ("can't be blocked by power 2 or less", "must be blocked if able", "can't block") | 7 | 0 | Vinebred Brawler |
| Legacy keywords (persist, wither, conspire, affinity) | 6 | 3 | Barbed Bloodletter |
| Complex mana abilities (X mana, "spend only on ...", "becomes that color") | 6 | 2 | Springleaf Drum |
| Activation limits and "becomes a P/T creature until end of turn" | 4 | 0 | Figure of Fable |
| Ward with a non-mana cost ("Ward—Pay 2 life") | 4 | 1 | Hexing Squelcher |
| Global replacement / prevention (double damage, "triggers an additional time") | 2 | 0 | |
| Landcycling variants | 2 | 1 | |
| Extra land drop | 1 | 0 | |
| Aura/equipment restrictions and characteristic setting | 1 | 1 | |

## What "smoothly" means per mechanic

For each mechanic below, "engine" means whether `lib/magic` already models it (so the work
is parsing plus generating), and "gap" means the engine needs new work too. Follow the
`docs/card_parser.md` conventions: one rule/effect per file, a `spec/card_parser/...` unit
spec, a generated-in-play spec, and a card implemented with the `implement-card` skill for
each new capability.

### Phase 1 — structure that unlocks many cards at once (cheap)

1. **Hybrid mana in costs** (33 faces, blocks nothing alone; it gates the whole first-year
   legend and Eclipsed cycles). Engine: supported (`Costs::Mana` hybrid keys; cards like
   `LluwenImperfectNaturalist` use `cost "{B/G}{B/G}"`). Gap: `CardParser::ManaCost.parse`
   raises on `{B/G}`. Plan: teach `ManaCost` a hybrid representation, and have
   `CardGenerator` emit the string form (`cost "{2}{B/G}"`) whenever a hybrid symbol is
   present (the hash form can't express it). Add hybrid to `TapForMana`/activation `COST`
   regexes. Also `{X}` in the cost (2 faces): check `Costs::Mana` `x` support and emit
   `cost "{X}{R}"` the same way.
2. **Kindred** (13 faces). Engine: `T::Kindred` exists (`type T::Kindred, T::Sorcery`).
   Gap: `CardGenerator#kind` rejects two-type lines. Plan: treat Kindred as a modifier on
   an instant/sorcery/enchantment/artifact (and creature) card, keep the subtypes as
   creature types, and emit `type T::Kindred, T::Instant, T::Creatures["Goblin"]`. Unlocks
   only 1 by itself; its value is removing a blocker from the modal and changeling cards.
3. **Modal spells** (15 faces, 9 sole). `Rules::Modal` exists for "Choose one —" with
   bulleted modes; the failures are the variants: "Choose one or both", "Choose two", modes
   with targets ("Target opponent reveals their hand..."), a modal ETB ("When ~ enters,
   choose one —"), and "choose both instead if the additional cost was paid" (Commands,
   Kindred). Plan: parse the choose-count line into the mode-count the `modes` macro
   understands (`docs/card_parser.md` notes the count isn't enforced today, so enforce
   it in `Choice`/`Cast` first), then let each bullet use the full `EffectList` including
   targeted effects, then add the ETB form via a `Choice` on a trigger.
4. **Planeswalkers** (3 faces: Oko x2, Ajani) — lowest priority. Engine has loyalty
   abilities. Gap: a `:planeswalker` kind, loyalty header, and a `LoyaltyAbility` rule
   (`+1: ...`, `−3: ...`). Defer until phases 2-3 leave these cards with no other blocker.
5. **Small structure items** (one face each): `*/N` power/toughness (a CDA rule feeding
   `PowerAndToughnessModification`), legendary enchantment (`legendary_enchantment`-style
   macro in the generator), extra land drop (`Abilities::Static` for lands per turn).

Expected unlock after Phase 1: modal cards (+10 sole) and the structural blockers
(+~14 once combined with hybrid/Kindred faces' other mechanics are done).

### Phase 2 — the high-tally ECL mechanics

6. **Blight** (25 faces, 11 sole — the single best return). "Blight N" = put N -1/-1
   counters on a creature you control. Four shapes: additional cost ("you may blight 2",
   "blight 1 or pay {3}"), activation cost ("{T}, Blight 1: ..." / "Pay 1 life, Blight 2:"),
   effect ("each opponent blights 1", "you may blight 1. If you do, ..."), and trigger
   text ("At the beginning of your first main phase, you may blight 1"). Engine gap: a
   `Costs::Blight` (choose one of your creatures, add -1/-1 counters, can't pay without a
   creature), and `Actions::Cast` additional-cost plumbing (optional and "or pay" costs;
   kicker is the nearest existing pattern in `costs.md`). Parser: a `Blight` effect, a
   cost entry in `ActivatedAbility::COST`, an `AdditionalCost` rule
   ("As an additional cost to cast ~, ..."), and the "if the additional cost was paid,
   instead ..." grammar (5 faces: Cinder Strike, Pyrrhic Strike, ...).
7. **-1/-1 counters** (10 faces, 9 sole; pairs naturally with Blight). Most lines are
   conditions on counters ("while ~ has a -1/-1 counter on it", "if it had a -1/-1
   counter on it") and triggers ("Whenever another creature enters while ..."). Engine:
   `Counters::Minus1Minus1` exists. Plan: a small `Condition` vocabulary shared by
   triggers and statics (`has_counter?(type)`, "if it had ... on it" reading the last
   known information for dies triggers), plus "put a -1/-1 counter on up to one target
   creature" in `AddCounters`, and "remove a -1/-1 counter from ~".
8. **Creature-type-qualified triggers and effects** (17 faces, 10 sole). Extend the trigger
   `Kind` table with a `<type>` slot: "Whenever another Goblin you control dies",
   "Whenever ~ or another Kithkin you control enters", "Whenever you attack, target
   attacking Goblin you control gets ...", plus effects targeting "target Elf you control".
   Plan: a `CreatureType` matcher (`lib/magic/card_parser/creature_type.rb` already exists)
   used by `PermanentTarget` and by trigger conditions (`event.permanent.type?("Goblin")`);
   the "~ or another X you control" form becomes two condition branches in one
   `should_perform?`.
9. **Vivid** (14 faces, 8 sole). A `Count` for "the number of colors among permanents you
   control" (`Count.parse`, `docs/card_parser.md`), used by ETB draws/damage/tokens/life
   loss ("where X is the number of colors among permanents you control") and by the
   cost-reduction form ("costs {1} less for each color"). Engine: a `colors_among`
   helper over `battlefield.controlled_by(controller)` (`Permanent#colors` exists).
   Cost reduction needs the `ManaCostAdjustment` static ability, which exists.
10. **Changeling** (20 faces, 4 sole). Engine gap: `Keywords::CHANGELING` — "is every
    creature type" must make `type?(x)` true for every creature subtype, which touches
    the type checks the type-qualified rules in step 8 depend on. Do it after step 8 so
    the qualified matchers are exercised against it. Parser: the keyword, "with
    changeling" on tokens (`CreateToken` keyword list already exists), "is all creature
    types" on equipment/auras (`CharacteristicSetting` from Kenrith's Transformation
    handles "sets types", extend it with "adds all creature types").
11. **Pay-to-transform / double-faced cards** (14 faces, 6 sole). Engine: `Permanent#transform!`
    exists (`transform!(card:)`); the parser has no notion of a second face. Plan: extend
    `CardParser` input to two faces (a `//` or blank-line separated block), generate one
    card class with a back face, and add a `PayToTransform` trigger rule ("At the beginning
    of your first main phase, you may pay {B}. If you do, transform ~") plus the
    "Whenever ~ enters or transforms into ~" trigger. This is the largest single parser
    change; do the engine side (back face characteristics after `transform!`) with a
    hand-written card first, then generalise.
12. **Convoke** (16 faces, 3 sole) and **Evoke** (5, needs hybrid) and **Behold** (12): three
    alternative-cost keywords.
    - Convoke: an `Actions::Cast` cost source ("tap an untapped creature you control to
      pay {1} or one mana of that creature's colour"); plus "creature spells you cast have
      convoke" as a static ability granting it.
    - Evoke: an alternative cost plus "if it was evoked, sacrifice it when it enters"
      (the sacrifice is a trigger); the incarnation ETBs need "if {R}{R} was spent to cast
      it" — track mana spent on `Actions::Cast` and expose it as a trigger condition
      (see `Events::SpellCast#mana_cost`, which already carries the cost).
    - Behold: "As an additional cost, behold a Goblin and exile it" — reveal a matching
      card from hand or choose a matching permanent, optionally exile it, and "when ~
      leaves the battlefield, return the exiled card". Reuses the exiled-cards pattern
      (`Permanent#exiled_cards`, `FightRigging`).
    Add a shared `AlternativeCost`/`AdditionalCost` abstraction on `Actions::Cast`
    before starting any of them; Blight (step 6) already needs its additional-cost part.
13. **Choose a creature type** (12 faces, 4 sole): "As ~ enters, choose a creature type"
    and "of the chosen type". Engine: `Permanent#chosen_creature_type` exists (Roaming
    Throne). Plan: a `ChooseCreatureType` rule producing the enter-choice
    (`Choice::CreatureType` exists) and a `Count`/`PermanentTarget` qualifier "of the
    chosen type" reading `source.chosen_creature_type`.

### Phase 3 — general effect and trigger grammar

14. **Tap/untap** (9 faces, 7 sole): effects "Tap target creature", "Untap it", "Untap
    target Merfolk you control", the "Whenever ~ becomes tapped" trigger
    (`Events::PermanentTapped` — check it exists), and "tap N untapped creatures you
    control" costs (`Costs::MultiTap` exists).
15. **Graveyard recursion / reanimation** (10 faces, 8 sole). `Reanimate` and
    `ReturnFromGraveyard` exist; extend to "up to one target <type> card with mana
    value N or less from your graveyard to the battlefield/hand", "another target Elf
    card", and "put a creature card ... from your hand onto the battlefield". Needs a
    small `CardFilter` (type, subtype, mana value ≤ N, power ≤ N) shared with the
    library search effect.
16. **Counters as costs / other counter mechanics** (15 faces, 7 sole): "Remove a counter
    from ~" with any counter type (the cost form of `RemoveCounter` currently needs a
    named type), "Remove any number of counters from target creature", stun counters
    (`Counters::Stun` exists), "Put a flying/first strike/lifelink counter" (keyword
    counters: new `Counters` that grant keywords through `ContinuousEffects`), and
    "can't have counters put on it" (a replacement effect).
17. **Alternative/additional casting costs and permissions** (13 faces): the `Cast`
    abstraction from step 12 also carries "costs {N} less if you control a Kithkin" (a
    conditional `ManaCostAdjustment`), "You may cast ~ as though it had flash if ...",
    and "cast from among cards exiled with ~" (Maralen; same shape as
    `CunningRhetoric`).
18. **ETB/dies triggers with unsupported effects** (9 faces): mostly Auras — "enchanted
    creature fights up to one target creature an opponent controls" (`Fight` effect),
    "tap enchanted creature", "enchanted creature gains X until end of turn", "exile up
    to one target nonland permanent an opponent controls until ~ leaves the battlefield"
    (a linked exile, `Permanent#exiled_cards` + an `ltb_triggers` return). The generic
    fix is `EffectList` support for the "enchanted creature" referent (add
    `Effect::ENCHANTED` next to `Effect::THIS`).
19. **Conditional statics** (11 faces): "As long as ...", "During your turn", "each other
    creature you control has hexproof from each of its colours". Generalise `StaticBuff`
    with a `Condition` (the same vocabulary as step 7) and a keyword-grant with a filter;
    `Abilities::Static::KeywordGrant#conditions { ... }` already supports the runtime
    side.
20. **Casting triggers with conditions and conditional attack/block triggers** (8 faces):
    add slots to the `SpellCast` `Kind` ("with mana value 4 or greater", "during an
    opponent's turn"), and to `AttacksTrigger` ("attacks alone", "attacks or blocks").
21. **Tokens with unsupported shape** (12 faces): named tokens (Treasure — 3 faces —
    exists in engine as a per-card `Token.create`; extract a shared `Tokens::Treasure` and
    parse "create a Treasure token"), "1/1 colorless Shapeshifter creature token with
    changeling" (needs step 10), "create a token that's a copy of target ... you control"
    (`CopyTokens` exists; add the "except it has haste" variants only if cheap), and
    Mutavault. Also token counts by `Count` ("create X ... tokens").
22. **Bounce / blink / exile effects** (9 faces): "Return up to one other target creature
    to its owner's hand", "Exile ... until ~ leaves the battlefield" (step 18),
    "exile any number of target creatures, return them at the next end step" (delayed
    trigger — the engine has `register_turn_trigger`).
23. **Life / damage / draw compound effects** and **X-based pump** (11 faces): multi-target
    damage ("2 damage to any target and 1 damage to any other target" needs the
    two-target support the EffectList currently refuses), "deals X damage to each
    opponent and each creature they control", "draw three cards, then discard two
    unless you discard a creature card", "Target creature gets +3/+3. If a creature
    entered the battlefield under your control this turn, draw a card" (conditional
    tail using `game.current_turn.events`).
24. **Library and zone effects** (23 faces across the four rows): add `Surveil` (effect
    like `Scry`, choice `Choice::Surveil` exists), `Mill` (`MoveCardZone` from the
    library top), `Dig` ("look at the top N, you may reveal a <filter> card and put it
    into your hand, the rest on the bottom" — `SearchLibrary`'s filter machinery, plus
    the Nessian Wanderer pattern), "exile the top card, you may play it until end of
    your next turn" (cast-permission with an expiry turn, `SerpentsSoulJar` pattern), and
    tucking ("owner puts it second from the top or on the bottom").

### Phase 4 — long tail (each ≤ 6 faces)

25. **Legacy keywords**: persist, wither, conspire, affinity — engine work per keyword
    (persist and wither are combat/death replacements; conspire is a copy-on-cast cost;
    affinity is a `ManaCostAdjustment`). Add them to `Rules::Keywords` as each lands.
26. **Combat restrictions**: "can't block", "must be blocked if able", "can't be blocked
    by creatures with power 2 or less/by more than one creature". The engine notes
    (`docs/patterns/static_abilities.md`) say `can_block?` is not consulted by the real
    combat engine, so fix that first, then add the static abilities.
27. **Complex mana abilities**: "Add X {G} or X {W}, where X is ...", "Spend this mana
    only to cast ...", "becomes that color". Needs mana-with-restriction tracking on
    `ManaPool`; do last of the mana work.
28. **Ward with a life cost**, **landcycling**, **counterspells** (targeted "Counter
    target spell [with mana value 2]", "can't be countered"), **copy effects** ("copy
    target triggered ability", "copy it" on cast — `CopyEffect` exists),
    **global replacement effects** (double damage, extra trigger — the
    `TriggeredAbilityDoubler` static ability exists), **activation limits** ("Activate
    only once each turn", "Activate only if there are five colors among permanents you
    control") and **animation** ("becomes a 4/4 artifact creature until end of turn",
    Figure of Fable's levelling).

### Suggested order and expected unlocks

The greedy order below picks, at each step, the mechanic that completes the most faces
given what is already done (from `script/parser_gaps.rb`). It is the ordering of value,
not of difficulty; combine it with the phases above (do the cheap structural items
first, and share machinery — the `Condition` vocabulary, `AdditionalCost`, `CardFilter`).

| # | Mechanic | Faces unlocked | Cumulative faces |
|---:|---|---:|---:|
| 1 | Blight | 11 | 11 |
| 2 | Creature-type-qualified triggers | 11 | 22 |
| 3 | Modal spells | 10 | 32 |
| 4 | -1/-1 counter interactions | 9 | 41 |
| 5 | Vivid | 8 | 49 |
| 6 | Tap/untap | 8 | 57 |
| 7 | Graveyard recursion | 8 | 65 |
| 8 | Other counter mechanics | 8 | 73 |
| 9 | Casting costs/permissions | 8 | 81 |
| 10 | Pay-to-transform / DFC | 7 | 88 |
| 11 | Kindred | 7 | 95 |
| 12 | Changeling | 7 | 102 |
| 13 | Hybrid mana | 10 | 112 |
| 14 | Unsupported ETB/dies effects | 7 | 119 |
| 15 | Conditional statics | 7 | 126 |
| 16 | Life/damage/draw compound | 6 | 132 |
| 17 | Legacy keywords | 6 | 138 |
| 18 | Convoke | 6 | 144 |
| 19 | Choose a creature type | 9 | 153 |
| 20 | Token shapes | 7 | 160 |
| 21 | Surveil | 6 | 166 |
| 22 | Complex mana abilities | 6 | 172 |
| 23 | Combat restrictions | 6 | 178 |
| 24–46 | the remainder, one to five faces each | | 246 |

The last 8 faces (Evoke, "if {R}{R} was spent", dig, planeswalkers) only unlock together
with other mechanics, so they aren't in the greedy table; they are the Phase 2/3 items
above and complete the set at 254.

Practical grouping for implementation sessions:

- **Session 1 (cheap, foundational)**: hybrid mana, Kindred, `{X}`, modal variants.
- **Session 2 (Blight + -1/-1 + counters)**: one `AdditionalCost`/`Cost` abstraction,
  the `Condition` vocabulary, all counter mechanics. ~30 faces.
- **Session 3 (type-qualified + changeling + chosen type)**: the type matcher shared by
  all three. ~35 faces.
- **Session 4 (Vivid, tap/untap, recursion, library effects)**: independent effect
  additions, parallelisable. ~40 faces.
- **Session 5 (double-faced cards)**: a design pass, then the parser change.
- **Session 6+ (long tail)**: keywords and mana restrictions as needed.

Re-run `script/parser_gaps.rb ecl` after each session and update the tallies here.

## Caveats

- Unlock counts assume every other line on a card parses. A face also needs its other
  effects (many use "up to one target", multi-target, "then if" clauses, conditional
  tails) supported, so real unlock is lower than the table until step 23 lands. Treat the
  numbers as an upper bound on cards completed by each step.
- Buckets come from regexes over the failing lines; a line matching two mechanics is
  assigned to the first in `MECHANICS`, so a few counts are skewed (for example some
  Kindred faces list "changeling" lines under Changeling, and hybrid faces list the
  cost only under hybrid). Edit `MECHANICS` and re-run if a bucket looks wrong.
- The oracle data has one printing per card, so the "ecl" set membership is approximate:
  cards reprinted in ECL whose default printing is another set are missed.
- Passing `CardParser.parse` and `CardGenerator.generate` means a card is generated, not
  that it is correct in play; every new rule needs the in-play spec described in
  `docs/card_parser.md`.

## Appendix — every failing face and its blockers

Generated with `script/parser_gaps.rb ecl --cards`.

- Abigale, Eloquent First-Year — Conditional static keywords/abilities (as long as, during your turn); Hybrid mana symbols in cost
- Adept Watershaper — Conditional static keywords/abilities (as long as, during your turn)
- Ajani, Outland Chaperone — Planeswalker loyalty abilities; Planeswalker card kind
- Appeal to Eirdu — Convoke; X-based / count-based pump
- Aquitect's Defenses — Conditional static keywords/abilities (as long as, during your turn)
- Ashling's Command — Modal spells / modal ETB; Kindred type line
- Ashling, Rekindled — Pay-to-transform / double-faced cards
- Ashling, Rimebound — Pay-to-transform / double-faced cards
- Assert Perfection — X-based / count-based pump
- Auntie's Sentence — Modal spells / modal ETB
- Aurora Awakener — Vivid
- Barbed Bloodletter — Legacy keywords (persist, wither, conspire, affinity)
- Bark of Doran — Conditional static keywords/abilities (as long as, during your turn)
- Bile-Vial Boggart — -1/-1 counter interactions
- Bitterbloom Bearer — Tokens with unsupported shape (copies, Shapeshifter, conditional counts)
- Blighted Blackthorn — Blight
- Bloodline Bidding — Convoke; Choose a creature type (chosen-type effects)
- Bloom Tender — Vivid
- Blossombind — ETB/dies triggers with unsupported effects; Counter mechanics (remove any, charge, dream, stun, no-counters)
- Boggart Cursecrafter — Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Boggart Mischief — Blight; Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...); Kindred type line
- Boggart Prankster — Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Bogslither's Embrace — Blight
- Boldwyr Aggressor — Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Boulder Dash — Life / damage / draw compound effects
- Brambleback Brute — Counter mechanics (remove any, charge, dream, stun, no-counters)
- Bre of Clan Stoutarm — Exile from top of a library, may play/cast
- Brigid's Command — Modal spells / modal ETB; Kindred type line
- Brigid, Clachan's Heart — Pay-to-transform / double-faced cards
- Brigid, Doun's Mind — Complex mana abilities (spend-only, X, any combination, tap-creature costs); Pay-to-transform / double-faced cards
- Bristlebane Battler — Ward with non-mana costs; -1/-1 counter interactions
- Bristlebane Outrider — Combat restrictions & evasion (can't block, must be blocked, can't attack); Conditional static keywords/abilities (as long as, during your turn)
- Burdened Stoneback — Counter mechanics (remove any, charge, dream, stun, no-counters)
- Burning Curiosity — Blight; Alternative / additional casting costs and cast permissions
- Catharsis — Mana spent to cast ("if {R}{R} was spent to cast it"); Evoke; Hybrid mana symbols in cost
- Celestial Reunion — Behold; Choose a creature type (chosen-type effects); {X} in mana cost
- Champion of the Clachan — Behold; Bounce / blink / exile effects
- Champion of the Path — Behold; Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...); Bounce / blink / exile effects
- Champion of the Weird — Behold; Blight; Bounce / blink / exile effects
- Champions of the Perfect — Behold; Bounce / blink / exile effects
- Champions of the Shoal — Behold; Counter mechanics (remove any, charge, dream, stun, no-counters); Bounce / blink / exile effects
- Changeling Wayfinder — Changeling; ETB/dies triggers with unsupported effects
- Chaos Spewer — Blight; Hybrid mana symbols in cost
- Chitinous Graspling — Changeling; Hybrid mana symbols in cost
- Chomping Changeling — Changeling; ETB/dies triggers with unsupported effects
- Chronicle of Victory — Choose a creature type (chosen-type effects)
- Cinder Strike — Blight; Alternative / additional casting costs and cast permissions
- Clachan Festival — Kindred type line
- Collective Inferno — Convoke; Choose a creature type (chosen-type effects)
- Creakwood Safewright — -1/-1 counter interactions
- Crib Swap — Changeling; Kindred type line
- Curious Colossus — Ward with non-mana costs
- Darkness Descends — -1/-1 counter interactions
- Dawn-Blessed Pennant — Choose a creature type (chosen-type effects)
- Dawnhand Dissident — Blight; Alternative / additional casting costs and cast permissions
- Dawnhand Eulogist — Mill
- Deceit — Mana spent to cast ("if {R}{R} was spent to cast it"); Evoke; Hybrid mana symbols in cost
- Deepchannel Duelist — Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Deepway Navigator — Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Disruptor of Currents — Convoke; Bounce / blink / exile effects
- Doran, Besieged by Time — Alternative / additional casting costs and cast permissions; Conditional attack/block triggers
- Dose of Dawnglow — Blight
- Dream Harvest — Exile from top of a library, may play/cast; Hybrid mana symbols in cost
- Dream Seizer — Blight
- Dundoolin Weaver — Graveyard recursion / reanimation / put onto battlefield from hand
- Eclipsed Boggart — Look at the top N cards (dig); Hybrid mana symbols in cost
- Eclipsed Elf — Look at the top N cards (dig); Hybrid mana symbols in cost
- Eclipsed Flamekin — Look at the top N cards (dig); Hybrid mana symbols in cost
- Eclipsed Kithkin — Look at the top N cards (dig); Hybrid mana symbols in cost
- Eclipsed Merrow — Look at the top N cards (dig); Hybrid mana symbols in cost
- Eclipsed Realms — Choose a creature type (chosen-type effects)
- Eirdu, Carrier of Dawn — Convoke; Pay-to-transform / double-faced cards
- Emptiness — Mana spent to cast ("if {R}{R} was spent to cast it"); Evoke; Hybrid mana symbols in cost
- Encumbered Reejerey — -1/-1 counter interactions
- End-Blaze Epiphany — Exile from top of a library, may play/cast; {X} in mana cost
- Enraged Flamecaster — Casting triggers with conditions
- Evershrike's Gift — Blight
- Explosive Prodigy — Vivid
- Feed the Flames — Life / damage / draw compound effects
- Feisty Spikeling — Changeling; Conditional static keywords/abilities (as long as, during your turn); Hybrid mana symbols in cost
- Figure of Fable — Activated abilities with limits or non-cost restrictions; Hybrid mana symbols in cost
- Firdoch Core — Changeling; Activated abilities with limits or non-cost restrictions; Kindred type line
- Flamebraider — Complex mana abilities (spend-only, X, any combination, tap-creature costs)
- Flamekin Gildweaver — Treasure tokens
- Flaring Cinder — ETB/dies triggers with unsupported effects; Hybrid mana symbols in cost
- Flitterwing Nuisance — Counter mechanics (remove any, charge, dream, stun, no-counters)
- Flock Impostor — Changeling; Bounce / blink / exile effects
- Foraging Wickermaw — Surveil; Complex mana abilities (spend-only, X, any combination, tap-creature costs)
- Formidable Speaker — ETB/dies triggers with unsupported effects; Tap/untap triggers and tap-creature costs
- Gallant Fowlknight — Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Gangly Stompling — Changeling; Hybrid mana symbols in cost
- Gathering Stone — Choose a creature type (chosen-type effects)
- Giantfall — Modal spells / modal ETB
- Gilt-Leaf's Embrace — Conditional static keywords/abilities (as long as, during your turn)
- Glamer Gifter — Changeling
- Glamermite — Modal spells / modal ETB
- Glen Elendra Guardian — Counter mechanics (remove any, charge, dream, stun, no-counters)
- Glen Elendra's Answer — Counterspells; Tokens with unsupported shape (copies, Shapeshifter, conditional counts)
- Glister Bairn — Vivid; Hybrid mana symbols in cost
- Gloom Ripper — Graveyard recursion / reanimation / put onto battlefield from hand
- Gnarlbark Elm — Counter mechanics (remove any, charge, dream, stun, no-counters)
- Goatnap — Tap/untap triggers and tap-creature costs
- Goldmeadow Nomad — Alternative / additional casting costs and cast permissions
- Goliath Daydreamer — Counter mechanics (remove any, charge, dream, stun, no-counters); Alternative / additional casting costs and cast permissions
- Gravelgill Scoundrel — Conditional attack/block triggers
- Graveshifter — Changeling
- Gristle Glutton — Blight
- Grub's Command — Modal spells / modal ETB; Kindred type line
- Grub, Notorious Auntie — Blight; Pay-to-transform / double-faced cards
- Grub, Storied Matriarch — Pay-to-transform / double-faced cards
- Gutsplitter Gang — Blight
- Harmonized Crescendo — Convoke; Choose a creature type (chosen-type effects)
- Heirloom Auntie — -1/-1 counter interactions
- Hexing Squelcher — Counterspells; Ward with non-mana costs
- High Perfect Morcant — Blight; Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Hovel Hurler — Counter mechanics (remove any, charge, dream, stun, no-counters); Hybrid mana symbols in cost
- Illusion Spinners — Alternative / additional casting costs and cast permissions; Conditional static keywords/abilities (as long as, during your turn)
- Iron-Shield Elf — Tap/untap triggers and tap-creature costs
- Isilu, Carrier of Twilight — Legacy keywords (persist, wither, conspire, affinity); Pay-to-transform / double-faced cards
- Keep Out — Modal spells / modal ETB
- Kinbinding — X-based / count-based pump
- Kindle the Inner Flame — Tokens with unsupported shape (copies, Shapeshifter, conditional counts); Behold; Kindred type line
- Kinsbaile Aspirant — Behold
- Kinscaer Sentry — Graveyard recursion / reanimation / put onto battlefield from hand
- Kirol, Attentive First-Year — Copy effects (permanents, spells, abilities); Hybrid mana symbols in cost
- Kithkeeper — Vivid; Tap/untap triggers and tap-creature costs
- Kulrath Mystic — Casting triggers with conditions
- Kulrath Zealot — Exile from top of a library, may play/cast; Cycling variants (landcycling)
- Lasting Tarfire — Life / damage / draw compound effects
- Lavaleaper — Conditional static keywords/abilities (as long as, during your turn); Complex mana abilities (spend-only, X, any combination, tap-creature costs)
- Liminal Hold — ETB/dies triggers with unsupported effects
- Lluwen, Imperfect Naturalist — Mill; Tokens with unsupported shape (copies, Shapeshifter, conditional counts); Hybrid mana symbols in cost
- Loch Mare — Counter mechanics (remove any, charge, dream, stun, no-counters)
- Lofty Dreams — Convoke
- Luminollusk — Vivid
- Lys Alana Dignitary — Behold; Graveyard recursion / reanimation / put onto battlefield from hand
- Lys Alana Informant — Surveil
- Maralen, Fae Ascendant — Exile from top of a library, may play/cast; Alternative / additional casting costs and cast permissions
- Meanders Guide — Graveyard recursion / reanimation / put onto battlefield from hand
- Meek Attack — Graveyard recursion / reanimation / put onto battlefield from hand
- Merrow Skyswimmer — Convoke; Hybrid mana symbols in cost
- Midnight Tilling — Mill
- Mirrorform — Copy effects (permanents, spells, abilities)
- Mirrormind Crown — Tokens with unsupported shape (copies, Shapeshifter, conditional counts)
- Mischievous Sneakling — Changeling; Hybrid mana symbols in cost
- Mistmeadow Council — Alternative / additional casting costs and cast permissions
- Moon-Vigil Adherents — Graveyard recursion / reanimation / put onto battlefield from hand
- Moonglove Extractor — Conditional attack/block triggers
- Moonlit Lamenter — Counter mechanics (remove any, charge, dream, stun, no-counters)
- Moonshadow — -1/-1 counter interactions
- Morcant's Eyes — Surveil; Tokens with unsupported shape (copies, Shapeshifter, conditional counts); Kindred type line
- Morcant's Loyalist — Graveyard recursion / reanimation / put onto battlefield from hand
- Morningtide's Light — Bounce / blink / exile effects; Global replacement / prevention effects
- Mornsong Aria — Global replacement / prevention effects; Tuck / put a permanent into its owner's library; Legendary enchantment
- Mudbutton Cursetosser — Behold; Combat restrictions & evasion (can't block, must be blocked, can't attack); ETB/dies triggers with unsupported effects
- Mutable Explorer — Changeling; Tokens with unsupported shape (copies, Shapeshifter, conditional counts)
- Nameless Inversion — Changeling; Kindred type line
- Nightmare Sower — -1/-1 counter interactions
- Noggle Robber — Treasure tokens; Hybrid mana symbols in cost
- Noggle the Mind — Aura/equipment restrictions and characteristic setting
- Oko, Lorwyn Liege — Pay-to-transform / double-faced cards; Changeling; Planeswalker loyalty abilities; Planeswalker card kind
- Oko, Shadowmoor Scion — Pay-to-transform / double-faced cards; Planeswalker loyalty abilities; Choose a creature type (chosen-type effects); Planeswalker card kind
- Omni-Changeling — Changeling; Convoke
- Perfect Intimidation — Modal spells / modal ETB
- Personify — Changeling
- Pestered Wellguard — Tokens with unsupported shape (copies, Shapeshifter, conditional counts)
- Pitiless Fists — ETB/dies triggers with unsupported effects
- Prideful Feastling — Changeling; Hybrid mana symbols in cost
- Prismabasher — Vivid
- Prismatic Undercurrents — Vivid; Extra land drops
- Protective Response — Convoke; Conditional attack/block triggers
- Puca's Eye — ETB/dies triggers with unsupported effects; Life / damage / draw compound effects
- Pummeler for Hire — Ward with non-mana costs; Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Pyrrhic Strike — Blight; Modal spells / modal ETB
- Raiding Schemes — Legacy keywords (persist, wither, conspire, affinity)
- Reaping Willow — Counter mechanics (remove any, charge, dream, stun, no-counters); Hybrid mana symbols in cost
- Reckless Ransacking — Treasure tokens
- Reluctant Dounguard — -1/-1 counter interactions
- Requiting Hex — Blight; Alternative / additional casting costs and cast permissions
- Retched Wretch — -1/-1 counter interactions
- Rhys, the Evermore — Legacy keywords (persist, wither, conspire, affinity); Counter mechanics (remove any, charge, dream, stun, no-counters)
- Rime Chill — Vivid; Counter mechanics (remove any, charge, dream, stun, no-counters)
- Rimefire Torque — Choose a creature type (chosen-type effects); Counter mechanics (remove any, charge, dream, stun, no-counters)
- Rimekin Recluse — Bounce / blink / exile effects
- Riverguard's Reflexes — Tap/untap triggers and tap-creature costs
- Rooftop Percher — Changeling; Graveyard recursion / reanimation / put onto battlefield from hand
- Run Away Together — Modal spells / modal ETB
- Safewright Cavalry — Combat restrictions & evasion (can't block, must be blocked, can't attack); Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Sanar, Innovative First-Year — Vivid; Hybrid mana symbols in cost
- Sapling Nursery — Legacy keywords (persist, wither, conspire, affinity); Conditional static keywords/abilities (as long as, during your turn)
- Scarblade Scout — Mill
- Scarblade's Malice — Tokens with unsupported shape (copies, Shapeshifter, conditional counts)
- Scuzzback Scrounger — Blight
- Selfless Safewright — Convoke; Choose a creature type (chosen-type effects)
- Shadow Urchin — Blight; Exile from top of a library, may play/cast; Hybrid mana symbols in cost
- Shimmercreep — Vivid
- Shimmerwilds Growth — Choose a creature type (chosen-type effects); Complex mana abilities (spend-only, X, any combination, tap-creature costs)
- Shinestriker — Vivid
- Shore Lurker — Surveil
- Silvergill Mentor — Behold
- Silvergill Peddler — Tap/untap triggers and tap-creature costs
- Sizzling Changeling — Changeling; Exile from top of a library, may play/cast
- Slumbering Walker — Graveyard recursion / reanimation / put onto battlefield from hand
- Soul Immolation — Blight; Life / damage / draw compound effects
- Soulbright Seeker — Behold; Activated abilities with limits or non-cost restrictions
- Sourbread Auntie — Blight
- Spell Snare — Counterspells
- Spinerock Tyrant — Legacy keywords (persist, wither, conspire, affinity)
- Spiral into Solitude — Combat restrictions & evasion (can't block, must be blocked, can't attack); Blight
- Springleaf Drum — Complex mana abilities (spend-only, X, any combination, tap-creature costs)
- Spry and Mighty — X-based / count-based pump
- Squawkroaster — Vivid; P/T with * (characteristic-defining)
- Stalactite Dagger — Changeling
- Sting-Slinger — Blight
- Stoic Grove-Guide — Alternative / additional casting costs and cast permissions; Hybrid mana symbols in cost
- Stratosoarer — Cycling variants (landcycling)
- Sun-Dappled Celebrant — Convoke
- Sunderflock — Alternative / additional casting costs and cast permissions; Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Swat Away — Alternative / additional casting costs and cast permissions; Tuck / put a permanent into its owner's library
- Sygg's Command — Modal spells / modal ETB; Kindred type line
- Sygg, Wanderbrine Shield — Combat restrictions & evasion (can't block, must be blocked, can't attack); Pay-to-transform / double-faced cards
- Sygg, Wanderwine Wisdom — Combat restrictions & evasion (can't block, must be blocked, can't attack); Pay-to-transform / double-faced cards
- Tam, Mindful First-Year — Conditional static keywords/abilities (as long as, during your turn); Activated abilities with limits or non-cost restrictions; Hybrid mana symbols in cost
- Tanufel Rimespeaker — Casting triggers with conditions
- Taster of Wares — Modal spells / modal ETB
- Temporal Cleansing — Convoke; Tuck / put a permanent into its owner's library
- Tend the Sprigs — Tokens with unsupported shape (copies, Shapeshifter, conditional counts)
- Thirst for Identity — Life / damage / draw compound effects
- Thoughtweft Charge — X-based / count-based pump
- Thoughtweft Imbuer — Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Thoughtweft Lieutenant — Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Tributary Vaulter — Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Trystan's Command — Modal spells / modal ETB; Kindred type line
- Trystan, Callous Cultivator — Pay-to-transform / double-faced cards
- Trystan, Penitent Culler — Pay-to-transform / double-faced cards
- Twilight Diviner — Surveil; Tokens with unsupported shape (copies, Shapeshifter, conditional counts)
- Twinflame Travelers — Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Unbury — Modal spells / modal ETB
- Unexpected Assistance — Convoke
- Unforgiving Aim — Modal spells / modal ETB
- Unwelcome Sprite — Surveil
- Vibrance — Mana spent to cast ("if {R}{R} was spent to cast it"); Evoke; Hybrid mana symbols in cost
- Vinebred Brawler — Combat restrictions & evasion (can't block, must be blocked, can't attack); Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)
- Voracious Tome-Skimmer — Casting triggers with conditions; Hybrid mana symbols in cost
- Wanderbrine Preacher — Tap/untap triggers and tap-creature costs
- Wanderbrine Trapper — Tap/untap triggers and tap-creature costs
- Wanderwine Distracter — Tap/untap triggers and tap-creature costs
- Wanderwine Farewell — Convoke; Tokens with unsupported shape (copies, Shapeshifter, conditional counts); Kindred type line
- Warren Torchmaster — Blight
- Wary Farmer — Surveil; Hybrid mana symbols in cost
- Wild Unraveling — Blight; Counterspells
- Wildvine Pummeler — Vivid
- Winnowing — Convoke; Removal variants (destroy attacking/blocking, edicts)
- Wistfulness — Mana spent to cast ("if {R}{R} was spent to cast it"); Evoke; Hybrid mana symbols in cost
