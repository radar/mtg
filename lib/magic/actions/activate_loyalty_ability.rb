module Magic
  module Actions
    class ActivateLoyaltyAbility < Action
      attr_reader :ability, :planeswalker, :targets, :x_value

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

      def value_for_x(value)
        @x_value = value
        self
      end

      def perform
        loyalty_change = if ability.loyalty_change == :X
          -(x_value)
        else
          ability.loyalty_change
        end

        planeswalker.change_loyalty!(loyalty_change)
        game.stack.add(self)
      end

      def resolve!
        if targets.any?
          if ability.single_target?
            ability.resolve!(target: targets.first)
          else
            ability.resolve!(targets: targets)
          end
        else
          if x_value
            ability.resolve!(value_for_x: x_value)
          else
            ability.resolve!
          end
        end
      end
    end
  end
end
