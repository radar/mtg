module Magic
  module Cards
    ThreeTreeRootweaver = Creature("Three Tree Rootweaver") do
      cost generic: 1, green: 1
      creature_type("Mole Druid")
      power 1
      toughness 3
    end

    class ThreeTreeRootweaver < Creature
      class ManaAbility < Magic::TapManaAbility
        choices :all
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
