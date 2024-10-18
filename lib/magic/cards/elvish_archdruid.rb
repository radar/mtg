module Magic
  module Cards
    ElvishArchdruid = Creature("Elvish Archdruid") do
      power 2
      toughness 2
      cost generic: 1, green: 2
      creature_type "Elf Druid"

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        def initialize(source:)
          @source = source
        end

        def power
          1
        end

        def toughness
          1
        end

        def applicable_targets
          source.controller.creatures.by_type("Elf") - [source]
        end
      end

      class ManaAbility < Magic::TapManaAbility
        def resolve!
          source.controller.add_mana(green: source.controller.creatures.by_type("Elf").count)
        end
      end

      def activated_abilities = [ManaAbility]

      def static_abilities = [PowerAndToughnessModification]
    end
  end
end
