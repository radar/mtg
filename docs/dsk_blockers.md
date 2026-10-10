# DSK blockers

Cards skipped because they need an engine feature that doesn't exist yet.

- Skullsnap Nuisance: Eerie needs a "you fully unlock a Room" event; the engine has no Room (split enchantment, door unlocking) support.
- Victor, Valgavoth's Seneschal: same Eerie/Room-unlock event, plus a per-turn resolution counter for the ability's three stages.
- Manifest Dread: manifest dread needs face-down 2/2 permanents (no name, types or abilities, turn-face-up for mana cost if a creature card); the engine has no face-down permanent support. Also blocks Defiant Survivor, Innocuous Rat, Unwanted Remake and Oblivious Bookworm.
- Defiant Survivor: Survival trigger is easy (see Cautious Survivor) but its effect is manifest dread; same missing face-down permanent support.
- Cult Healer: Eerie needs the "you fully unlock a Room" event; the engine has no Room (split enchantment, door unlocking) support. Also blocks Balemurk Leech.
- Overlord of the Mistmoors: Impending needs an alternative cost that enters with time counters, makes the permanent not a creature until the last is removed, and removes a counter at your end step; the engine has no impending support. Also blocks the other DSK Overlords.
- Erratic Apparition: Eerie needs the "you fully unlock a Room" event; the engine has no Room (split enchantment, door unlocking) support.
- Entity Tracker: Eerie needs the "you fully unlock a Room" event; the engine has no Room (split enchantment, door unlocking) support. Also blocks Gremlin Tamer, Dashing Bloodsucker, Infernal Phantom, Scrabbling Skullcrab and Stalked Researcher.
- Waltz of Rage: needs a player-level delayed triggered ability ("until end of turn, whenever a creature you control dies"); the engine only has per-permanent turn triggers (`Permanent#add_turn_trigger`), nothing registered on the game with no source permanent.
- Inquisitive Glimmer: "Unlock costs you pay cost {1} less" needs Room/door unlocking; the engine has no Room support (the enchantment-spell cost reduction alone would leave the card half-implemented).
- Resurrected Cultist: needs a finality counter ("if a creature with a finality counter would die, exile it instead"); the engine has no finality counter type or die-to-exile replacement keyed on it.
- Leyline of the Void: "If this card is in your opening hand, you may begin the game with it on the battlefield" needs a pregame opening-hand step; the engine has none. Also blocks the other Leylines (Hope, Mutation, Resonance, Transformation).
- Balustrade Wurm: Delirium reanimation returns it "with a finality counter on it"; the engine has no finality counter or die-to-exile replacement keyed on it (same gap as Resurrected Cultist).
- Rampaging Soulrager: "two or more unlocked doors among Rooms you control" needs Room/door unlocking; the engine has no Room support.
- Unable to Scream: "as long as enchanted creature is face down, it can't be turned face up" needs face-down permanents; the engine has no face-down permanent support (same gap as Manifest Dread).
- Toby, Beastie Befriender: the Beast token "can't attack or block alone" needs a check on the whole declared attacker/blocker set; combat declares attackers one at a time (`can_attack?` only sees the single creature), so there is no hook for a group-level restriction.
- Cathartic Parting: "up to four target cards from your graveyard" alongside a separate target artifact/enchantment; casting supports one target per list (`multi_target?`) but no variable-count ("up to N") target list.
- Creeping Peeper: "Spend this mana only to cast an enchantment spell, unlock a door, or turn a permanent face up" needs Room unlocking and face-down permanents (the spend restriction itself is supported). Also blocks Overgrown Zealot's second ability (turn permanents face up).
- Say Its Name: "Exile this card and two other cards named Say Its Name from your graveyard" needs a cost that exiles chosen other cards from the graveyard (the only exile costs are `SelfExile` and the hand-based alternative cost), and `ActivateAbility` has no `pay_*` for it; the ability then searches graveyard, hand and library for Altanak.
- Fear of Abduction: "As an additional cost, exile a creature you control" has no cost class, and "put each card exiled with it into its owner's hand" needs the creature exiled as a cost linked to the permanent the spell becomes (`exile_with_this!` only works from a permanent that already exists, and `Cast` has no hook that hands paid-cost cards to the resolved permanent).
