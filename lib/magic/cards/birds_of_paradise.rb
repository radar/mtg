module Magic
  module Cards
    BirdsOfParadise = Creature("Birds of Paradise") do
      cost green: 1
      creature_type "Bird"
      power 0
      toughness 1
      keywords :flying
    end

    class BirdsOfParadise < Creature
      # "{T}: Add one mana of any color."
      class ManaAbility < Magic::TapManaAbility
        choices :all
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
