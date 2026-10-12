# Bloomburrow (BLB) Mechanics

How the set's named mechanics are modelled. Part of the card-implementation pattern catalog — see `docs/card_patterns.md` for the index.

- **Valiant**: `TriggeredAbility::Valiant`, wired with `ValiantTrigger.handlers` from `event_handlers`. It listens for `Events::BecameTarget`, fired when a spell is cast or an ability activated with a permanent as a target, and when a triggered ability's `Choice::Targeted` target is chosen (`Stack#resolve_choice!`). Once per turn via `trigger_once_this_turn!`. Example: `HeartfireHero`. `TriggeredAbility::GrantedWard` and `PawpatchRecruit` use the same event.
- **Expend N**: `Player#pay_mana` fires `Events::ManaSpent` (with the turn's running total); `TriggeredAbility::Expend` subclasses define `threshold`. Example: `TeapotSlinger`, `MuerraTrashTactician` (two thresholds).
- **Gift**: `gift :card | :food | :treasure | :tapped_fish` on the card; `action.promise_gift` while casting (before targeting, since `target_choices` may depend on `gift_promised?`). The gift is given as the spell resolves (`Cast#give_gift!`, `Events::GiftGiven`); a spell reads `gift_promised?`, a permanent's ETB reads `actor.gift_promised?`. Example: `IntoTheFloodMaw` (targets), `Scrapshooter` (ETB).
- **Forage**: `Player#forage!(three graveyard cards | a Food)`, `Costs::Forage` ("{2}, Forage"), `Costs::ForageOrMana` (Feed the Cycle), `Choice::Forage` for "you may forage. If you do". `Events::Forage` for "whenever you forage".
- **Offspring**: pre-existing `offspring generic: 2` macro.
- **Class enchantments**: `Cards::ClassEnchantment` with `level_costs 2 => "{2}{R}", 3 => ...`; `Permanent#level`/`#level_up!`, `Events::ClassLevelGained` for "when this Class becomes level N". Later-level abilities check `actor.level` (triggers) or `source.level` (statics and replacements). Example: `StormchasersTalent`, `InnkeepersTalent` (replacement), `BlacksmithsTalent` (static).
- **Threshold**: `controller.graveyard.count >= 7` inside `applicable_targets`/`requirements_met?`.
- **Seasons**: `Mode` subclasses declare `points n`; the card declares `modes_budget 5`. `Cast#choose_mode` then allows repeats until the budget is spent.
- **"Opponent lost life this turn"**: `game.current_turn.opponent_lost_life?(controller)`; also `life_lost_by_player`, `mana_spent_by_player`.
- **Finality counters**: `counters: { "finality" => 1 }` on `:return_target_from_graveyard_to_battlefield`; `Permanent#counter_replacements` exiles the creature instead of letting it die.
- **Delayed returns**: `game.subscribe(DelayedReturn.new(game:, cards:, counters: {}))` returns exiled cards at the next end step (Parting Gust, Salvation Swan, Skyskipper Duo).
- **Free casts**: `Choice::FreeCast.start(actor:, card:)` (asks for a target if needed, exiles the spell afterwards via `Card#exile_once!`); `game.play_permissions.grant_while_exiled(card:, player:, any_mana: true)` for Cruelclaw's Heist.
- **Equipment tokens**: `Tokens::EquipmentToken.build("Sword", power: 1, toughness: 1, equip: "{2}")` (Sword, Cragflame).
- **Static ability gaps filled for this set**: `Abilities::Static::KeywordRemoval` (Starforged Sword), `GrantFlash` (Valley Floodcaller), `damage_cant_be_prevented?` (Sunspine Lynx), `ReplacementEffect::DamageIncreaser`, `Cast#reprice_for_targets!` (a card answering `targets_chosen(targets)` can change its own cost, Dire Downdraft), `{X}{X}` costs (`cost x: 2`), `permits_casting_from_graveyard?` on battlefield statics (Festival of Embers).
- **Test names**: `Card("Ral, Crackling Wit")` lowercases nothing — write every word capitalised, "Of"/"The" included (`"Season Of The Burrow"`), except a lowercase "of" which the helper handles.
