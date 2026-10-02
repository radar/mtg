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
        trigger_effect(:deal_damage, target: target, damage: 3)
        trigger_effect(:gain_life, target: controller, life: 1)
      end
    end
  end
end
