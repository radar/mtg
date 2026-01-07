module Magic
  module Cards
    GoobbueGardener = Creature("Goobbue Gardener") do
      power 1
      toughness 3
      cost generic: 1, green: 1
      creature_type "Plant Beast"
    end

    class GoobbueGardener < Creature
      class ManaAbility < Magic::TapManaAbility
        choices :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
