# PR 11: Extract reflection-based resolve! argument passing

## Summary

Four `resolve!` implementations in the action layer all used identical reflection logic to build a keyword-argument hash from a receiver's method signature before calling `resolve!`. A signature change in any card or ability's `resolve!` would silently pass wrong arguments at all four sites. This PR extracts the logic into a single `ResolvesWithArgs` module.

## Why

The docs note in improvement #4:

> Using `.method().parameters` to decide what arguments to pass is fragile — a signature change silently breaks the call — and the duplication means fixes need applying twice.

With the helper centralised, any fix or additional argument (e.g. a future `mode:` or `zone:` keyword) is added in one place.

## What Changed

**`lib/magic/resolves_with_args.rb`** (new file)
- Defines `Magic::ResolvesWithArgs` with a single private method `resolve_with_args(receiver, **available)`
- Introspects `receiver.method(:resolve!).parameters` and filters `available` to only the keys the method declares (both `:keyreq` and `:key` parameter kinds)
- Calls the method with the filtered args

**`lib/magic/action.rb`**
- `include ResolvesWithArgs` — covers `Cast`, `ActivateAbility`, `ActivateLoyaltyAbility`

**`lib/magic/actions/cast/mode.rb`**
- `include Magic::ResolvesWithArgs` — `Mode` does not inherit from `Action` so it includes the module directly

**`lib/magic/actions/cast.rb`**
- `resolve!` replaced 6-line reflection block with `resolve_with_args(card, target:, targets:, kicked:, value_for_x:)`

**`lib/magic/actions/activate_ability.rb`**
- `resolve!` replaced 4-line reflection block with `resolve_with_args(ability, target:, targets:)`

**`lib/magic/actions/activate_loyalty_ability.rb`**
- `resolve!` replaced 5-line reflection block with a 2-line form; `value_for_x` is added to the pool only when non-nil (preserving the original guard)

**`lib/magic/actions/cast/mode.rb`**
- `resolve!` replaced 4-line reflection block with `resolve_with_args(mode, target:, targets:)`

## Invariants Preserved

- The filtering logic is identical to the original: a keyword arg is passed only if the receiver's `resolve!` declares it (required or optional)
- The `value_for_x` nil guard in `ActivateLoyaltyAbility` is preserved — X is excluded from the pool when it was not set, so no ability receives `value_for_x: nil` unexpectedly
- All 534 tests pass
