module Magic
  module Actions
    class ActivateLoyaltyAbility < Action
      attr_reader :ability, :planeswalker, :targets, :x_value

      def initialize(ability:, **args)
        @planeswalker = ability.source
        @ability = ability
        @targets = []
        super(**args)
      end

      def inspect
        "#<Actions::Actions::ActivateLoyaltyAbility planeswalker: #{planeswalker.name}, ability: #{ability.class}>"
      end

      def can_be_activated?(player)
        ability.can_be_activated?(player)
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
        resolver = ability.method(:resolve!)
        args = {}
        args[:target] = targets.first if resolver.parameters.include?([:keyreq, :target])
        args[:targets] = targets if resolver.parameters.include?([:keyreq, :targets])
        args[:value_for_x] = x_value if x_value && resolver.parameters.include?([:keyreq, :value_for_x])
        ability.resolve!(**args)
      end
    end
  end
end
