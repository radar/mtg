module Magic
  module Cards
    JoustThrough = Instant("Joust Through") do
      cost white: 1
    end

    class JoustThrough < Instant
      def target_choices
        battlefield.creatures.select { game.current_turn.attacking?(_1) || game.current_turn.blocking?(_1) }
      end

      def resolve!(target:)
        deal_damage(3, to: target)
        gain_life(1)
      end
    end
  end
end
