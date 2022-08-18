module Magic
  module Actions
    class ActivateLoyaltyAbility < Action
      attr_reader :ability, :planeswalker, :targets

      def initialize(planeswalker:, ability:, **args)
        @planeswalker = planeswalker
        @ability = ability.new(planeswalker: planeswalker)
        @targets = []
        super(**args)
      end

      def inspect
        "#<Actions::Actions::ActivateLoyaltyAbility planeswalker: #{planeswalker.name}, ability: #{ability.class}>"
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

      def perform(value_for_x: 0)
        loyalty_change = if ability.loyalty_change == :X
          -(value_for_x)
        else
          ability.loyalty_change
        end

        planeswalker.change_loyalty!(loyalty_change)
        game.stack.add(self)
      end

      def resolve!
        if targets.any?
          ability.resolve!(targets: targets)
        else
          ability.resolve!
        end
      end
    end
  end
end
