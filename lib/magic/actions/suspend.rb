module Magic
  module Actions
    # Suspend (rule 702.62a): a special action. Pay the suspend cost to exile the card from your hand with its time counters
    # instead of casting it. Legal whenever the card could be cast (an instant any time, anything else at sorcery speed).
    class Suspend < Action
      # What suspend mana is being spent on, as `Costs::Mana#for_use`. Suspending is a special action: it is neither
      # casting a spell nor activating an ability, so spell and ability mana restrictions refuse it.
      Use = Data.define(:card)

      attr_reader :card

      def initialize(card:, **args)
        @card = card
        super(**args)
      end

      def inspect = "#<Actions::Suspend card: #{card.name}, player: #{player.inspect}>"
      def name = "Suspend (#{card.name})"
      def uses_priority? = false

      def mana_cost
        @mana_cost ||= Costs::Mana.new(card.suspend_cost.dup).tap { |cost| cost.for_use = Use.new(card: card) }
      end

      def pay_mana(payment)
        mana_cost.pay(player: player, payment: payment)
        self
      end

      def can_perform?
        mana_cost.can_pay?(player)
      end

      def illegal_reason
        return "#{card.name} has no suspend" unless card.respond_to?(:suspend_cost)
        return "#{card.name} is not in #{player.inspect}'s hand" unless card.zone&.hand? && card.owner == player
        return if card.instant? || card.flash?

        "#{card.name} can only be suspended at sorcery speed" unless game.current_turn.main_phase? && game.stack.empty? && game.current_turn.active_player == player
      end

      def perform
        mana_cost.finalize!(player)
        card.exile!
        card.time_counters = card.suspend_count
      end
    end
  end
end
