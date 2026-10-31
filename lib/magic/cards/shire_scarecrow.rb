module Magic
  module Cards
    ShireScarecrow = Creature("Shire Scarecrow") do
      artifact_creature_type "Scarecrow"
      cost generic: 2
      power 0
      toughness 3
      keywords :defender
    end

    class ShireScarecrow < Creature
      # "{1}: Add one mana of any color. Activate only once each turn."
      class ManaAbility < Magic::ManaAbility
        choices :all
        costs "{1}"
        once_each_turn
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
