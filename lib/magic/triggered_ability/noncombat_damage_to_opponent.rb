module Magic
  class TriggeredAbility
    # "Whenever a source you control deals noncombat damage to an opponent" (Chandra's Pyreling, Chandra's Incinerator).
    # Listen for `Events::DamageDealt`; `event.damage` is the amount and `event.target` the damaged opponent.
    class NoncombatDamageToOpponent < TriggeredAbility
      def should_perform?
        return false if event.combat?
        return false unless opponents.include?(event.target)

        event.source.respond_to?(:controller) && event.source.controller == controller
      end
    end
  end
end
