module Magic
  module Cards
    PrideOfThePerfect = Enchantment("Pride of the Perfect") do
      cost generic: 3, black: 1
    end

    class PrideOfThePerfect < Enchantment
      class PowerModification < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 0

        def applicable_targets
          source.controller.creatures.by_any_type("Elf")
        end
      end

      def static_abilities = [PowerModification]
    end
  end
end
