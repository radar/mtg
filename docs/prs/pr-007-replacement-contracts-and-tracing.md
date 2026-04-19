# PR 7: Replacement contracts and tracing hardening

## Summary
This PR tightens the `ReplacementEffect` contract and adds structured tracing around replacement candidate discovery and application.

It improves diagnostics and guards against subtle contract violations when implementing new replacement effects.

## Why
Replacement behavior was functionally working, but contracts were implicit and logging was unstructured. That made failures harder to diagnose and made it easy to accidentally return invalid values from replacement hooks.

## What Changed
1. Hardened replacement contract surface:
- `lib/magic/replacement_effect.rb`
- `applies?` and `call` now raise `NotImplementedError` with explicit method expectations.
- Added `InvalidApplicabilityResult` when `applies?` does not return boolean.
- Added `InvalidReplacementResult` when `call` does not return an effect-like object responding to `resolve!`.

2. Added structured tracing in resolver:
- `lib/magic/game/replacement_effect_resolver.rb`
- Logs candidate sets, selected replacement, and applied result payloads with stable labels:
  - `REPLACEMENT_CANDIDATES`
  - `REPLACEMENT_SELECTED`
  - `REPLACEMENT_APPLIED`

3. Hardened replacement context derivation:
- `lib/magic/game/replacement_effect_context.rb`
- Safer target/controller derivation to avoid nil/NoMethodError edge cases during chooser tracing.

4. Added contract tests:
- `spec/replacement_effect_spec.rb`
- Verifies base interface raises `NotImplementedError`.
- Verifies validation errors for invalid `applies?` and invalid `call` return values.

## Behavior Notes
- Existing replacement cards continue to work.
- Contract violations now fail fast with descriptive errors.
- Replacement traces are easier to follow in debug logs.

## Files Included In This PR
- `lib/magic/replacement_effect.rb`
- `lib/magic/game/replacement_effect_resolver.rb`
- `lib/magic/game/replacement_effect_context.rb`
- `spec/replacement_effect_spec.rb`

## Test Evidence
Targeted:
- `bundle exec rspec spec/replacement_effect_spec.rb spec/game/integration/replacement_effect_choice_order_spec.rb spec/game/integration/replacement_effect_semantic_applicability_spec.rb spec/game/integration/replacement_effect_source_eligibility_spec.rb`
- Result: passing

Regression re-check after context safety fixes:
- `bundle exec rspec spec/game/integration/combat/nine_lives_damage_prevented_spec.rb spec/replacement_effect_spec.rb`
- Result: passing

Full suite:
- `bundle exec rspec`
- Result: 534 examples, 0 failures

## Follow-up
- Consider serializing replacement trace payloads in a machine-parsable format for tooling.
- Add optional trace IDs to correlate replacement chains across nested effect resolution.
