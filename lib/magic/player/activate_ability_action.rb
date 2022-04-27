module Magic
  class Player
    class ActivateAbilityAction
      attr_reader :game, :player, :ability, :targets

      def initialize(game:, player:, ability:)
        @game = game
        @player = player
        @ability = ability
      end

      def can_be_activated?(player)
        ability.can_be_activated?(player)
      end

      def countered?
        false
      end

      def name
        ability
      end

      def targeting(*targets)
        @targets = targets
        self
      end

      def pay(cost_type, payment)
        ability.pay(player, cost_type, payment)
      end

      def activate!
        ability.finalize!(player)
        game.stack.add(self)
      end

      def resolve!
        if targets
          ability.activate!(targets: targets)
        else
          ability.activate!
        end
      end
    end
  end
end
