module Magic
  module Cards
    VolcanicGeyser = Instant("Volcanic Geyser") do
      cost x: 1, red: 2
    end

    class VolcanicGeyser < Instant
      def target_choices = game.any_target

      # "Volcanic Geyser deals X damage to any target."
      def resolve!(target:, value_for_x: 0)
        deal_damage(value_for_x, to: target)
      end
    end
  end
end
