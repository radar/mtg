# DSK blockers

Cards skipped because they need an engine feature that doesn't exist yet.

- Toby, Beastie Befriender: the Beast token "can't attack or block alone" needs a check on the whole declared attacker/blocker set; combat declares attackers one at a time (`can_attack?` only sees the single creature), so there is no hook for a group-level restriction.
- Valgavoth, Terror Eater: ward-sacrifice-three-nonland-permanents has no non-mana ward cost, and "you may play cards exiled with Valgavoth" paying life instead of the mana cost needs a linked-exile cast permission with an alternative cost.
- Kaito, Bane of Nightmares: needs ninjutsu (unblocked-attacker return cost, put onto the battlefield attacking), a planeswalker that is also a creature during your turn only, and a Ninja emblem; the engine has none of these.
- The Jolly Balloon Man: the token copy of another creature "except it's a 1/1 red Balloon creature in addition to its other colors and types and has flying and haste" needs a copy token with characteristic overrides (`CreateTokenCopy` only sets base P/T for offspring) and a sacrifice at the beginning of the next end step registered for a token with no source trigger.
- Niko, Light of Hope: needs Shard tokens that later "become copies" of an exiled creature until the next end step, plus a blink returning at the next end step; the engine has no temporary become-a-copy effect for existing permanents.
- The Tale of Tamiyo: chapter IV exiles cards from the graveyard, copies them as spells and casts the copies, and the mill-and-repeat chapters need shared-type checks on milled cards; the engine has no copy-a-card-and-cast-the-copy support.
