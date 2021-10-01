module Magic
  class Player
    class ActivateAbilityAction
      include PayableAction
      attr_reader :player, :ability

      def initialize(player:, ability:)
        @player = player
        @ability = ability
      end

      def activate!
        perform!(ability.cost) do
          ability.activate!
        end
      end
    end
  end
end
