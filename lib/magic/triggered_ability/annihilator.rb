module Magic
  class TriggeredAbility
    # Annihilator N (rule 702.86): "Whenever this creature attacks, defending player sacrifices N permanents." Works for
    # a printed keyword (`keywords Keywords::Annihilator.new(2)`) and for a granted one (`KeywordGrant` with
    # `Keywords::Annihilator.new(2)`); a card with only a granted keyword adds
    # `Events::CreatureAttacked => TriggeredAbility::Annihilator` to its own `event_handlers`.
    #
    # Each instance of the keyword triggers separately (702.86b). The handler is registered once; when it triggers it
    # takes the first instance's N and queues (or runs) a sibling ability for every further instance. N is recorded
    # when the trigger fires (113.7a), not re-read at resolution.
    class Annihilator < TriggeredAbility
      def initialize(event:, actor:, amount: nil)
        super(event:, actor:)
        @amount = amount
      end

      # N for this trigger, fixed when it triggered.
      attr_reader :amount

      # One N per instance of annihilator the attacker has right now. Subclasses with a computed N ("annihilator X")
      # override this.
      def instance_amounts
        actor.keywords.grep(Keywords::Annihilator).map(&:amount)
      end

      def trigger!
        return false unless event.attacker == actor

        amounts = instance_amounts.select(&:positive?)
        return false if amounts.empty?

        @amount = amounts.first
        amounts.drop(1).each do |extra|
          sibling = self.class.new(event:, actor:, amount: extra)
          game.queue_triggers? ? game.queue_trigger!(sibling) : sibling.call
        end
        true
      end

      def should_perform? = event.attacker == actor && instance_amounts.any?(&:positive?)

      # The player being attacked, or the controller of the attacked planeswalker. (The engine has no battles.)
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
