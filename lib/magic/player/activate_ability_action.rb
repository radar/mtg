module Magic
  class Player
    class ActivateAbilityAction
      attr_reader :player, :ability

      def initialize(player:, ability:)
        @player = player
        @ability = ability
      end

      def can_be_activated?(player)
        ability.can_be_activated?(player)
      end

      def pay(cost_type, payment)
        ability.pay(player, cost_type, payment)
      end

      def activate!
        ability.finalize!(player)
        ability.activate!
      end
    end
  end
end
