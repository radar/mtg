module Magic
  module Cards
    GreatForestDruid = Creature("Great Forest Druid") do
      cost generic: 1, green: 1
      creature_type("Treefolk Druid")
      power 0
      toughness 4
    end

    class GreatForestDruid < Creature
      class ManaAbility < Magic::TapManaAbility
        choices :all
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
