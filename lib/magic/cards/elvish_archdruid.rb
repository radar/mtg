module Magic
  module Cards
    ElvishArchdruid = Creature("Elvish Archdruid") do
      power 2
      toughness 2
      cost generic: 1, green: 2
      creature_type "Elf Druid"
    end

    class ElvishArchdruid < Creature
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        other_creatures "Elf"
      end

      class ManaAbility < Magic::TapManaAbility
        def resolve!
          # "for each Elf you control": any Elf permanent counts, not only creatures.
          source.controller.add_mana(green: source.controller.permanents.count { _1.type?("Elf") })
        end
      end

      def activated_abilities = [ManaAbility]

      def static_abilities = [PowerAndToughnessModification]
    end
  end
end
