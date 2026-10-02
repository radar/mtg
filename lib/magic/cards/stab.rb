module Magic
  module Cards
    Stab = Instant("Stab") do
      cost black: 1
    end

    class Stab < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:modify_power_toughness, target: target, power: -2, toughness: -2)
      end
    end
  end
end
