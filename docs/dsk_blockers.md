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
