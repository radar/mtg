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

        pump first_creature, 0, 2
        pump second_creature, -2
      end
    end
  end
end
