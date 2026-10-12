module Magic
  module Cards
    GraspingLongneck = Creature("Grasping Longneck") do
      cost generic: 2, green: 1
      enchantment_creature_type("Horror")
      keywords :reach
      power 4
      toughness 2
    end

    class GraspingLongneck < Creature
      class DiesTrigger < TriggeredAbility::Death
        def call
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
