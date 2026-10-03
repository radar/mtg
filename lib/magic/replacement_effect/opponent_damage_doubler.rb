module Magic
  class ReplacementEffect
    # "If a source you control would deal damage to an opponent or a permanent an opponent controls, it deals
    # double that damage instead." (Twinflame Tyrant.) Any source of yours (creature, spell, ability), but damage to
    # you or to your own permanents isn't doubled.
    class OpponentDamageDoubler < DamageDoubler
      private

      def recipient_applies?(target) = damaged_player(target) != receiver.controller
    end
  end
end
