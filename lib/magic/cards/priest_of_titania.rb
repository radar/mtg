module Magic
  module Cards
    PriestOfTitania = Creature("Priest of Titania") do
      cost generic: 1, green: 1
      creature_type "Elf Druid"
      power 1
      toughness 1
    end

    class PriestOfTitania < Creature
      class ManaAbility < Magic::TapManaAbility
        def resolve!
          source.controller.add_mana(green: game.battlefield.creatures.by_type("Elf").count)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
