module Magic
  module Cards
    OrnithopterOfParadise = Creature("Ornithopter of Paradise") do
      cost generic: 2
      artifact_creature_type "Thopter"
      keywords :flying
      power 0
      toughness 2
    end

    class OrnithopterOfParadise < Creature
      class ManaAbility < Magic::TapManaAbility
        choices :all
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
