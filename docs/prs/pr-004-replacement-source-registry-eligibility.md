# PR 4: Replacement source registry and eligibility filtering

## Summary
This PR centralizes replacement effect source discovery behind a dedicated registry and adds eligibility filtering for inactive sources.

The immediate behavior change is that phased-out permanents are excluded from replacement source scanning.

## Why
Replacement source discovery previously lived inside the resolver and implicitly assumed battlefield permanents only. This made it harder to extend to other source layers and harder to enforce eligibility consistently.

## What Changed
1. Added source registry:
- `lib/magic/game/replacement_effect_sources.rb`
- Provides `all` replacement sources from active battlefield permanents, emblems, and players.

2. Added game entry point:
- `lib/magic/game.rb`
- New `replacement_effect_sources` method delegates to the registry.

3. Updated resolver source scanning:
- `lib/magic/game/replacement_effect_resolver.rb`
- Uses `game.replacement_effect_sources`.
- Applies only to sources that implement `replacement_effect_for`.

4. Added eligibility regression coverage:
- `spec/game/integration/replacement_effect_source_eligibility_spec.rb`
- Verifies a normal battlefield source (`Doubling Season`) applies.
- Verifies phased-out source is ignored.

## Behavior Notes
- Replacement discovery is now centralized and extensible.
- Phased-out permanents no longer contribute replacement effects.
- Existing replacement APIs remain unchanged.

## Files Included In This PR
- `lib/magic/game.rb`
- `lib/magic/game/replacement_effect_sources.rb`
- `lib/magic/game/replacement_effect_resolver.rb`
- `spec/game/integration/replacement_effect_source_eligibility_spec.rb`

## Test Evidence
Targeted:
- `bundle exec rspec spec/game/integration/replacement_effect_source_eligibility_spec.rb spec/game/integration/replacement_effect_semantic_applicability_spec.rb spec/game/integration/replacement_effect_choice_order_spec.rb spec/cards/doubling_season_spec.rb spec/cards/nine_lives_spec.rb`
- Result: passing

Full suite:
- `bundle exec rspec`
- Result: 526 examples, 0 failures

## Follow-up
- Expand registry with additional source layers as they are introduced (for example explicit player-level or emblem-level replacement providers).
- Add richer eligibility rules as phasing and layer interactions grow.
