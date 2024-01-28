module Magic
  module Cards
    RookieMistake = Instant("Rookie Mistake") do
      cost blue: 1

      def multi_target? = true

      def target_choices
        [
          battlefield.creatures, # target creature
          battlefield.creatures, # another target creature
        ]
      end

      def resolve!(targets:)
        first_creature, second_creature = targets

        trigger_effect(:modify_power_toughness, target: first_creature, toughness: 2)
        trigger_effect(:modify_power_toughness, target: second_creature, power: -2)
      end
    end
  end
end
