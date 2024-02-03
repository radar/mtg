module Magic
  module Cards
    Prismite = Creature("Prismite") do
      artifact_creature_type "Golem"
      power 2
      toughness 1
    end

    class Prismite < Creature
      class ManaAbility < ManaAbility
        choices :all

        costs "{2}"
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
