# Card Implementation Patterns — Index

Split out of `CLAUDE.md` to keep that file small, then split again by topic so
`implement-card` only has to load the file(s) relevant to the card at hand instead of
one large catalog. See `.claude/skills/implement-card/SKILL.md` for how this is used.

## Topic files

- `docs/patterns/triggers.md` — ETB, attack, upkeep, landfall, lifecycle, once-per-turn,
  delayed triggers; plus the `TriggeredAbility::*` subclass list.
- `docs/patterns/choices.md` — `Magic::Choice` subclasses: targeting, modal, may,
  search/scry, distribute, copy-spell/storm, redirect targets.
- `docs/patterns/static_abilities.md` — keyword grants, CDA power/toughness, type
  changes, replacement effects, continuous modifiers; plus the `Abilities::Static::*`
  subclass list.
- `docs/patterns/costs.md` — activation/casting costs: sacrifice, kicker, discard,
  exile-self, alternative costs, mana production.
- `docs/patterns/zones_and_state.md` — zone moves, zone-check pitfalls, per-permanent
  instance state (`attr_accessor`s), `CardList`/`Zone` filtering.
- `docs/patterns/mechanics.md` — whole named mechanics spanning trigger+cost+static
  (Monarch, the Ring tempts you, Blitz, Adventure, additional combat, engine gotchas).

Grep across all of them at once with `rg -i "<keyword>" docs/patterns/` when unsure
which file covers a given ability shape.

## CardList Helper Methods

`Magic::CardList` (`lib/magic/card_list.rb`) wraps arrays of cards/permanents with filtering helpers. Use these instead of manual `select` with type checks:

- `.creatures` — cards/permanents where `creature?` is true
- `.lands` — `land?`
- `.enchantments` — `enchantment?`
- `.planeswalkers` — `planeswalker?`
- `.artifacts` — via `.by_any_type(T::Artifact)`
- `.basic_lands` — `basic_land?`
- `.shrines` — subtype "Shrine"
- `.controlled_by(player)` / `.not_controlled_by(player)` — filter by controller
- `.by_name(name)` — filter by card name
- `.by_any_type(*types)` — filter by one or more type constants
- `.cmc_lte(n)` — mana value ≤ n
- `.nonland` / `.nontoken` — exclusion filters
- `.except(target)` — exclude a specific card/permanent
- `.tapped` / `.attacking` — combat/state filters

These return a new `CardList`, so they chain: `source.exiled_cards.creatures.flat_map(&:activated_abilities)`. Prefer these over `select { |c| c.types.include?(T::Creature) }` or similar manual filters.
