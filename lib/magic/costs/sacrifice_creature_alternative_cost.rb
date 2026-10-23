module Magic
  module Costs
    # "You may sacrifice a nontoken <color> creature rather than pay this spell's mana cost" (the Flare cycle). Same
    # duck-typed interface as Costs::SacrificeAlternativeCost, but it picks from the player's nontoken creatures of
    # `color`.
    class SacrificeCreatureAlternativeCost
      def initialize(color:)
        @color = color
        @paid = false
      end

      def zero? = false

      def can_pay?(player) = candidates(player).any?

      def pay(player:, payment:)
        raise "Invalid creature chosen for sacrifice cost" unless candidates(player).include?(payment)

        payment.sacrifice!
        @paid = true
      end

      def finalize!(_player)
      end

      def paid? = @paid

      def x = nil

      private

      def candidates(player)
        player.creatures.select { !_1.token? && _1.colors.include?(@color) }
      end
    end
  end
end
