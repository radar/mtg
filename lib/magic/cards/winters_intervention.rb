module Magic
  module Cards
    WintersIntervention = Instant("Winter's Intervention") do
      cost generic: 1, black: 1
    end

    class WintersIntervention < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 2)
        gain_life(2)
      end
    end
  end
end
