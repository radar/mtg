module Magic
  module Cards
    CanopyTactician = Creature("Canopy Tactician") do
      cost generic: 3, green: 1
      creature_type "Elf Warrior"
      power 3
      toughness 3
    end

    class CanopyTactician < Creature
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        other_creatures "Elf"
      end

      def static_abilities = [PowerAndToughnessModification]

      class ManaAbility < Magic::TapManaAbility
        def resolve!
          source.controller.add_mana(green: 3)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
