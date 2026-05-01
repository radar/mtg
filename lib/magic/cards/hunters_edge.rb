module Magic
  module Cards
    HuntersEdge = Sorcery("Hunter's Edge") do
      cost generic: 3, green: 1

      def multi_target? = true

      def target_choices
        [
          battlefield.creatures.controlled_by(controller),
          battlefield.creatures.not_controlled_by(controller),
        ]
      end

      def resolve!(targets:)
        first_creature, second_creature = targets

        trigger_effect(
          :add_counter,
          target: first_creature,
          counter_type: "+1/+1",
        )

        game.tick!

        trigger_effect(
          :deal_damage,
          source: first_creature,
          target: second_creature,
          damage: first_creature.power,
        )
      end
    end
  end
end
