module Magic
  module Cards
    ElvishMystic = Creature("Elvish Mystic") do
      cost green: 1
      power 1
      toughness 1
      creature_type "Elf Druid"
    end

    class ElvishMystic < Creature
      class ManaAbility < Magic::ManaAbility
        costs "{T}"
        choices :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
