module Magic
  module Cards
    FleetingDistraction = Instant("Fleeting Distraction") do
      cost blue: 1
    end

    class FleetingDistraction < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:modify_power_toughness, target: target, power: -1, toughness: 0)
        trigger_effect(:draw_card)
      end
    end
  end
end
