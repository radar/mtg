module Magic
  module Cards
    PrimalMight = Sorcery("Primal Might") do
      cost green: 1, x: 1

      def multi_target? = true

      def target_choices
        [
          battlefield.creatures.controlled_by(controller),
          battlefield.creatures.not_controlled_by(controller),
        ]
      end

      def resolve!(targets:, value_for_x:)
        first_creature, second_creature = targets

        trigger_effect(
          :modify_power_toughness,
          target: first_creature,
          power: value_for_x,
          toughness: value_for_x
        )

        first_creature.fight(second_creature)
      end
    end
  end
end
