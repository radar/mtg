# PR 3: Replacement context and semantic applicability

## Summary
This PR introduces a replacement context object and shifts replacement applicability matching away from exact class equality toward semantic base-class compatibility.

The goal is to reduce coupling between replacement behavior and concrete Ruby effect class identity while preserving backward compatibility for existing cards.

## Why
Current replacement registration uses class-keyed mappings. Exact class matching is brittle and can miss valid replacements when effect subclasses or wrappers are used.

This PR keeps current card APIs (`replacement_effects` hash) but makes matcher evaluation semantic (`is_a?`) and introduces a context object to carry affected-object metadata through replacement resolution.

## What Changed
1. Added replacement context object:
- `lib/magic/game/replacement_effect_context.rb`
- Carries current effect and applied replacement keys, plus derived affected target/player/controller helpers.

2. Updated replacement resolver to use context:
- `lib/magic/game/replacement_effect_resolver.rb`
- Builds a context each iteration.
- Chooses replacement with `replacement_context` available.
- Applies replacement via `call_with_context`.

3. Extended replacement base API with context-aware defaults:
- `lib/magic/replacement_effect.rb`
- Added `applies_with_context?(context)` defaulting to `applies?(context.effect)`.
- Added `call_with_context(context)` defaulting to `call(context.effect)`.

4. Reworked permanent replacement lookup:
- `lib/magic/permanent.rb`
- Iterates all declared replacement entries.
- Uses semantic matcher behavior (`effect.is_a?(ClassMatcher)`).
- Maintains applied-key guardrails.

5. Propagated optional context to chooser interfaces:
- `lib/magic/game.rb`
- `lib/magic/player.rb`
- Chooser methods now accept optional `replacement_context:` while remaining deterministic by default.

## Behavior Notes
- Existing replacement cards continue to work unchanged.
- Replacement mapping is now robust to subclassed effect instances for class matchers.
- Chooser resolution remains deterministic unless overridden.

## Files Included In This PR
- `lib/magic/replacement_effect.rb`
- `lib/magic/game/replacement_effect_context.rb`
- `lib/magic/game/replacement_effect_resolver.rb`
- `lib/magic/permanent.rb`
- `lib/magic/game.rb`
- `lib/magic/player.rb`
- `spec/game/integration/replacement_effect_semantic_applicability_spec.rb`

## Test Evidence
Targeted:
- `bundle exec rspec spec/game/integration/replacement_effect_semantic_applicability_spec.rb spec/game/integration/replacement_effect_choice_order_spec.rb spec/cards/doubling_season_spec.rb spec/cards/conclave_mentor_spec.rb spec/cards/nine_lives_spec.rb`
- Result: passing

Full suite:
- `bundle exec rspec`
- Result: 524 examples, 0 failures

## Follow-up
Potential next steps:
- Introduce richer matcher forms (predicate/lambda or explicit matcher objects).
- Expand replacement source registry beyond battlefield-only scanning.
- Add structured replacement trace metadata for debugging complex chains.
