module Magic
  module Cards
    DeadlyRiposte = Instant("Deadly Riposte") do
      cost generic: 1, white: 1
    end

    class DeadlyRiposte < Instant
      def target_choices
        battlefield.creatures.select(&:tapped?)
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 3)
        gain_life(2)
      end
    end
  end
end
