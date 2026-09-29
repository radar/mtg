module Magic
  module Costs
    # "As an additional cost to cast this spell, blight X. X can't be greater than the greatest
    # toughness among creatures you control." Paid with `Cast#pay_blight_x(creature, x)`; X is
    # remembered on the spell's card as `x_blighted` for its effect to read.
    class BlightX
      attr_reader :source

      def initialize(source)
        @source = source
      end

      def can_pay?(player) = Magic::Choice::Blight.possible?(player, source.game)

      def maximum(player) = player.creatures.map(&:toughness).max.to_i

      def pay(player:, payment:)
        creature, x = payment
        raise "#{creature&.name} isn't a creature #{player.inspect} controls" unless creature&.creature? && creature.controller == player
        raise "X must be between 0 and #{maximum(player)}" unless x.between?(0, maximum(player))

        creature.add_counter(Counters::Minus1Minus1, amount: x) if x.positive?
        source.x_blighted = x
      end

      def finalize!(_player)
      end
    end
  end
end
