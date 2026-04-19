# PR 2: Explicit chooser-driven replacement ordering

## Summary
This PR introduces an explicit replacement-effect chooser step during replacement resolution.

When multiple replacement effects apply to the same effect, the engine now delegates selection to a chooser determined from the affected object/player, rather than relying on incidental battlefield iteration order.

## Why
PR 1 added iterative re-checking. However, replacement selection still implicitly depended on traversal order.

Rules behavior requires a choice point for ordering when multiple replacements apply. This PR makes that ordering explicit and testable.

## What Changed
1. Added chooser hook in game:
- `lib/magic/game.rb`
- New `choose_replacement_effect(effect:, replacement_effects:)`
- New chooser inference (`replacement_effect_chooser_for`) from affected target/permanent/controller.

2. Added default chooser behavior for players:
- `lib/magic/player.rb`
- New `choose_replacement_effect(effect:, replacement_effects:)` default strategy returns first option (deterministic baseline).

3. Updated replacement resolver to gather all current candidates and delegate choice:
- `lib/magic/game/replacement_effect_resolver.rb`
- Replaced single next-effect fetch with candidate list + chooser selection.

4. Added ordering-sensitive integration test:
- `spec/game/integration/replacement_effect_choice_order_spec.rb`
- Uses `Doubling Season` + `Conclave Mentor` on a `+1/+1` counter effect.
- Verifies different chooser preference yields different outcomes (3 vs 4 counters).

## Behavior Notes
- Replacement resolution remains iterative from PR 1.
- Selection among currently applicable replacements is now explicit via chooser.
- Default chooser remains deterministic for now; richer user-facing choice UX can be layered in later.

## Files Included In This PR
- `lib/magic/game.rb`
- `lib/magic/player.rb`
- `lib/magic/game/replacement_effect_resolver.rb`
- `spec/game/integration/replacement_effect_choice_order_spec.rb`

## Test Evidence
Targeted:
- `bundle exec rspec spec/game/integration/replacement_effect_choice_order_spec.rb spec/cards/doubling_season_spec.rb spec/cards/conclave_mentor_spec.rb spec/cards/nine_lives_spec.rb`
- Result: passing

Full suite:
- `bundle exec rspec`
- Result: 522 examples, 0 failures

## Follow-up
Potential PR 3+ enhancements:
- Replace default deterministic chooser with proper choice prompts.
- Expand chooser inference into a richer replacement-context object.
- Cover APNAP and cross-controller interactions with dedicated integration tests.
