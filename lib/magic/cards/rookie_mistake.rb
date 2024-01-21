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

        first_creature.modify_power_toughness!(toughness: 2)
        second_creature.modify_power_toughness!(power: -2)
      end
    end
  end
end
