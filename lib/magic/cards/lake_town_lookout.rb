module Magic
  module Cards
    LakeTownLookout = Creature("Lake-town Lookout") do
      cost white: 1
      creature_type "Human Scout"
      power 1
      toughness 1
    end

    class LakeTownLookout < Creature
      # "When this creature dies, recruit."
      class DiesTrigger < TriggeredAbility::Death
        def call
          Magic::Recruit.call(player: controller)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
