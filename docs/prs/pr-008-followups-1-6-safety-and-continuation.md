# PR 8: Follow-ups 1-6 continuation with loop safety

## Summary
This PR restarts the post-merge follow-up work with an explicit safety fix for replacement resolution loops, then continues the agreed items in a controlled way.

The key fix is a resolver-level guard that prevents the same replacement source/class pair from being applied repeatedly, even for non-permanent replacement providers.

## Why
A new rule-level replacement provider used in tests could repeatedly re-apply itself because it did not honor `applied_replacement_keys`. That created an infinite replacement chain and hanging tests.

## What Changed
1. Added resolver-level applied-key filtering:
- `lib/magic/game/replacement_effect_resolver.rb`
- `applicable_replacement_effects` now rejects replacement effects already present in context-applied keys.
- Added helper `replacement_already_applied?`.

2. Continued source-registry follow-up coverage:
- `spec/game/integration/replacement_effect_source_registry_layers_spec.rb`
- Includes a rule-level replacement provider test and lost-player source exclusion assertion.

3. Continued canonical damage-event transition follow-up:
- `lib/magic/effects/deal_combat_damage.rb`
- Removed legacy `CombatDamageDealt` emission.
- `lib/magic/events/combat_damage_dealt.rb` removed.
- `spec/game/integration/damage_event_deprecation_spec.rb` ensures only canonical `DamageDealt` is used for combat damage tracking.

4. Continued replacement source layering:
- `lib/magic/game.rb`
- Added `rule_effect_sources` and `add_rule_effect_source`.
- `lib/magic/game/replacement_effect_sources.rb`
- Added rule-level source layer and lost-player filtering.

5. Continued replacement trace improvements:
- `lib/magic/game/replacement_effect_context.rb`
- Added `trace_id` and iteration tracking.
- `lib/magic/game/replacement_effect_resolver.rb`
- JSON-structured trace logs with stage, trace_id, iteration.

## Safety Outcome
- Infinite loop condition eliminated for repeated self-replacing rule-level providers.
- Replacement chain termination is now enforced centrally in resolver, not only by provider correctness.

## Files Included In This PR
- `lib/magic/game/replacement_effect_resolver.rb`
- `lib/magic/game/replacement_effect_context.rb`
- `lib/magic/game/replacement_effect_sources.rb`
- `lib/magic/game.rb`
- `lib/magic/effects/deal_combat_damage.rb`
- `lib/magic/events/combat_damage_dealt.rb` (deleted)
- `spec/game/integration/replacement_effect_source_registry_layers_spec.rb`
- `spec/game/integration/damage_event_deprecation_spec.rb`

## Test Evidence
Focused safety test:
- `bundle exec rspec spec/game/integration/replacement_effect_source_registry_layers_spec.rb`
- Result: passing

Focused follow-up set:
- `bundle exec rspec spec/game/integration/damage_event_deprecation_spec.rb spec/game/integration/damage_event_normalization_spec.rb spec/game/integration/replacement_effect_source_eligibility_spec.rb spec/game/integration/replacement_effect_choice_order_spec.rb`
- Result: passing

Full suite:
- `bundle exec rspec`
- Result: 537 examples, 0 failures

## Follow-up
- Continue remaining parts of items 3, 5, and 6 in smaller PR slices if desired (source registry enrichment, would-enter depth, trace ID propagation across nested chains).
