module Magic
  class TriggeredAbility
    # "When you cast this spell, ..." (rule 603.2, 702.xx-style self-cast triggers). A card lists these in
    # `cast_triggers`; `Actions::Cast#perform` queues them once the spell is on the stack, so they resolve before it.
    # The event is the `Events::SpellCast` for the spell itself. `should_perform?` is the place for an
    # intervening "if" (it is checked as the spell is cast, with `mana_spent` already known).
    class CastThisSpell < TriggeredAbility
      # The card being cast (`actor` is the same card).
      def spell = event.spell

      # The mana paid for the spell as `{ color => amount }` (generic and X payments by the colour spent), `{}` when
      # the spell was cast without paying mana.
      def mana_spent = event.mana_spent

      # How many of `color` was spent ("if {U}{U} was spent to cast it").
      def spent(color) = mana_spent.fetch(color, 0)

      def x_value = event.x_value

      def cast_targets = event.targets
    end
  end
end
