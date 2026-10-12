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
        deal_damage(3, to: target)
        gain_life(2)
      end
    end
  end
end
