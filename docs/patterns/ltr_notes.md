# LTR notes

Engine notes gathered while implementing The Lord of the Rings: Tales of Middle-earth.

- Per-actor once-per-turn triggers must override `triggered_this_turn?` / `mark_triggered_this_turn!` to use `actor.triggered_once_this_turn?(self.class)` / `actor.trigger_once_this_turn!(self.class)`.
- Resetting once-per-turn state in a spec needs two full turn cycles.
- `Permanent#controller=` is the gain-control path.
- Mode specs need two candidates (a lone legal target auto-resolves).
- Food: "enters or leaves the battlefield" is two triggers, `etb_triggers` plus `ltb_triggers`, each calling `create_token(token: Tokens::Food)`; the token goes to the trigger's controller even when the source has left (example: `BrandywineFarmer`). Count Food with `permanents.select { _1.type?("Food") }`.
