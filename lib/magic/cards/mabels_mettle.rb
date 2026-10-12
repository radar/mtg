module Magic
  module Cards
    MabelsMettle = Instant("Mabel's Mettle") do
      cost generic: 1, white: 1
    end

    class MabelsMettle < Instant
      def multi_target? = true

      def target_choices
        [
          battlefield.creatures,
          (battlefield.creatures - [self]),
        ]
      end

      def resolve!(targets:)
        trigger_effect(:modify_power_toughness, target: targets[0], power: 2, toughness: 2)
        trigger_effect(:modify_power_toughness, target: targets[1], power: 1, toughness: 1)
      end
    end
  end
end
