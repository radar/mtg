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
        deal_damage(2, to: target)
        gain_life(2)
      end
    end
  end
end
