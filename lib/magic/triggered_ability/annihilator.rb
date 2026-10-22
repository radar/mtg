module Magic
  class TriggeredAbility
    # Annihilator N (rule 702.86): "Whenever this creature attacks, defending player sacrifices N permanents." Works for
    # a printed keyword (`keywords Keywords::Annihilator.new(2)`) and for a granted one (`KeywordGrant` with
    # `Keywords::Annihilator.new(2)`); a card with only a granted keyword adds
    # `Events::CreatureAttacked => TriggeredAbility::Annihilator` to its own `event_handlers`.
    class Annihilator < TriggeredAbility
      def should_perform? = event.attacker == actor && amount.positive?

      def amount
        actor.keywords.grep(Keywords::Annihilator).sum(&:amount)
      end

      # The player being attacked, or the controller of the attacked planeswalker or battle.
      def defending_player
        target = event.target
        target.is_a?(Player) ? target : target.controller
      end

      def call
        Choice::SacrificePermanents.for(actor: actor, player: defending_player, amount: amount)
      end
    end
  end
end
