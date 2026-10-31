# LTR notes

Engine notes gathered while implementing The Lord of the Rings: Tales of Middle-earth.

- Per-actor once-per-turn triggers must override `triggered_this_turn?` / `mark_triggered_this_turn!` to use `actor.triggered_once_this_turn?(self.class)` / `actor.trigger_once_this_turn!(self.class)`.
- Resetting once-per-turn state in a spec needs two full turn cycles.
- `Permanent#controller=` is the gain-control path.
- Mode specs need two candidates (a lone legal target auto-resolves).
- "Up to N target X": `number_of_targets` is exact, so use `multi_target? = true` with `target_choices` returning N lists (zero to N targets accepted, N+1 raises `Cast::InvalidTarget`) and `resolve!(targets: [])` (example: `SecondBreakfast`).
- Food in specs: `Magic::Tokens::Food.new(game: game, owner: p1).resolve!` puts one on the battlefield (`ResolvePermanent("Food")` does not work for tokens). "You may sacrifice a Food. If you do ... Otherwise ...": a plain `Magic::Choice` over the controller's Foods with `resolve!(sacrifice:)` for the "if you do" branch and `decline!` for "otherwise"; skip the choice when there is no Food (example: `PippinsBravery`).
- "Sacrifice a Food" is a `costs` string (`Costs::Parser`); `Costs::Sacrifice` does not validate the chosen permanent, so spec `ability.costs` choices. "Whenever you create a token" is `Events::EnteredTheBattlefield` with `event.permanent.token? && under_your_control?` (`RosieCottonOfSouthLane`). "If you sacrificed a Food this turn" scans `game.current_turn.events` for `PermanentSacrificed` (`ElanorGardner`). Sorcery-speed activation: `activate_only_as_sorcery`; illegal reason matches `/requirements to activate/`.
- "Until end of turn, target creature assigns combat damage equal to its toughness": `Permanent#assign_toughness_damage_this_turn!` (cleared in `cleanup!`, read via `combat_damage_amount`); `BillThePony`. Its ETB makes two Foods with `create_token(token: Tokens::Food, amount: 2)`.
- Reflexive "create a Food token. When you do, target creature ... for each Food you control": the trigger's `call` creates the token then `game.add_choice` a `Choice::Targeted` subclass (needs `def choice_amount = 1`) that counts Foods in `resolve!` (`EastfarthingFarmer`).
- Food: "enters or leaves the battlefield" is two triggers, `etb_triggers` plus `ltb_triggers`, each calling `create_token(token: Tokens::Food)`; the token goes to the trigger's controller even when the source has left (example: `BrandywineFarmer`). Count Food with `permanents.select { _1.type?("Food") }`.
