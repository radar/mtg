module Magic
  module Cards
    GoobbueGardner = Creature("Goobbue Gardener") do
      power 1
      toughness 3
      cost generic: 1, green: 1
      creature_type "Plant Beast"
    end

    class GoobbueGardner < Card
      class ManaAbility < Magic::TapManaAbility
        choices :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
