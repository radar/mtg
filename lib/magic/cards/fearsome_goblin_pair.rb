module Magic
  module Cards
    FearsomeGoblinPair = Creature("Fearsome Goblin Pair") do
      cost generic: 2, black_or_red: 1
      creature_type("Goblin Soldier")
      power 1
      toughness 1
    end

    class FearsomeGoblinPair < Creature
      class DiesTrigger < TriggeredAbility::Death
        def call
          Magic::Amass.call(source: actor, controller: controller, amount: 4)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
