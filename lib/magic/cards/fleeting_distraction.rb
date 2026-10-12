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
        pump(target, -1, 0)
        trigger_effect(:draw_card)
      end
    end
  end
end
