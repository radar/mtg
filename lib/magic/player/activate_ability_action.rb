module Magic
  class Player
    class ActivateAbilityAction
      attr_reader :player, :ability, :cost

      def initialize(player:, ability:)
        @player = player
        @ability = ability
        @cost = Costs::Mana.new(ability.cost.dup)
      end

      def pay(payment)
        cost.pay(player, payment)
      end

      def activate!
        cost.finalize!(player)
        ability.activate!
      end
    end
  end
end
